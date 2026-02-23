import 'dart:async';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_conn_ckecking/Internet_conn_checking.dart';
import 'package:key_api/key_api.dart';
import 'package:key_encrypt/key_encrypt.dart';
import 'package:picture/picture.dart';
import 'package:repository/models/repository.dart';
import 'package:request/request.dart';
import 'package:worker_manager/worker_manager.dart';

base class Repository {
  Repository({
    KeyApi? keyApi,
    InternetConnectionApi? internetConnectionApi,
    PictureApi? pictureApi,
    RequestApi? requestApi,
    RepositoryDatasource? repositoryDatasource,
  }) : keyApi = keyApi ?? KeyApi(),
       internetConnectionApi = internetConnectionApi ?? InternetConnectionApi(),
       pictureApi = pictureApi ?? PictureApi(),
       requestApi = requestApi ?? RequestApi(),
       repositoryDatasource = repositoryDatasource ?? RepositoryDatasource();

  final InternetConnectionApi internetConnectionApi;
  final KeyApi keyApi;
  final PictureApi pictureApi;
  final RequestApi requestApi;
  RepositoryDatasource repositoryDatasource;

  //
  Stream<String> isConnected() async* {
    yield* internetConnectionApi.isConnected();
  }

  Future<String?> getKey() async {
    // retries if server is disconnected
    int i = 2;
    String status = await internetConnectionApi.checkNow();
    while ((status == 'false') && i > 0) {
      await Future.delayed(const Duration(seconds: 1));
      status = await internetConnectionApi.checkNow();
      i--;
    }

    try {
      if (status == 'slow' || status == 'false') {
        final KeyModel keymodel = await keyApi.getClientKey();
        repositoryDatasource = repositoryDatasource.copyWith(
          keymodel: keymodel,
        );
        final od = repositoryDatasource.keymodel!.ownerId;
        print('KeyModel with ownerId: $od');

        return keymodel.error;
      } else {
        final KeyModel keymodel = await keyApi.getClientXKey();
        repositoryDatasource = repositoryDatasource.copyWith(
          keymodel: keymodel,
        );
        final od = repositoryDatasource.keymodel!.ownerId;
        print('XKeyModel with ownerId: $od');

        return keymodel.error;
      }
    } on Exception catch (e) {
      return e.toString();
    }
  }

  // encrypt the image data 💥💥💥💥
  Future<String?> encrypt() async {
    var bytesImage =
        (await repositoryDatasource.pictureDatasource!.image!.readAsBytes())
            .toList();
    try {
      if (kIsWeb) {
        final keymodel = repositoryDatasource.keymodel;
        final cancelable = workerManager.execute<AESDataModel>(
          () => encryptIsolate(bytesImage, keymodel!),
          priority: WorkPriority.immediately,
        );

        final AESDataModel aesDataModel = await cancelable.future;

        repositoryDatasource = repositoryDatasource.copyWith(
          aESDataModel: aesDataModel,
        );

        return aesDataModel.error;
      } else {
        final keymodel = repositoryDatasource.keymodel;
        final AESDataModel aesDataModel = await Isolate.run(() async {
          return await encryptIsolate(bytesImage, keymodel!);
        });
        repositoryDatasource = repositoryDatasource.copyWith(
          aESDataModel: aesDataModel,
        );

        return aesDataModel.error;
      }
    } on Exception catch (e) {
      return e.toString();
    }
  }

  // Picture Functions 🖼️🖼️🖼️🖼️
  Future<RepositoryDatasource> openCamera() async {
    final PictureDatasource pictureDatasource = await pictureApi.openCamera();
    return repositoryDatasource.copyWith(pictureDatasource: pictureDatasource);
  }

  Future<RepositoryDatasource> takePicture() async {
    final PictureDatasource pictureDatasource = await pictureApi.takePicture();
    repositoryDatasource.copyWith(pictureDatasource: pictureDatasource);
    return repositoryDatasource;
  }

  Future<RepositoryDatasource> openGallery() async {
    final pictureDatasource = await pictureApi.openGallery();
    repositoryDatasource = repositoryDatasource.copyWith(
      pictureDatasource: pictureDatasource,
    );

    return repositoryDatasource;
  }

  // Upload
  Future<RepositoryDatasource> sendRequest(String path, XFile img) async {
    try {
      final AESDataModel? model = repositoryDatasource.aESDataModel;

      if (model == null) {
        return repositoryDatasource.copyWith(
          requestDatasource: RequestDatasource(
            response: null,
            error: "AESDataModel is null",
          ),
        );
      }

      final requestDatasource = await requestApi.sendRequest(path, img, model);

      return repositoryDatasource.copyWith(
        requestDatasource: requestDatasource,
      );
    } catch (e) {
      return repositoryDatasource.copyWith(
        requestDatasource: RequestDatasource(
          response: null,
          error: e.toString(),
        ),
      );
    }
  }
}
