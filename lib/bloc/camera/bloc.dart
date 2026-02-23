import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_1/bloc/barrel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repository/models/repository.dart';
import 'package:repository/repository.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final Repository repository;

  PictureBloc({required this.repository}) : super(PictureState.initial()) {
    on<LoadKeys>(_loadKeys, transformer: sequential());
    on<PictureInit>(_onInit, transformer: droppable());
    on<PictureTaken>(_onTaken);
    on<PickPictureFromGallery>(_onPickFromGallery, transformer: droppable());
    on<PictureUpload>(_onPictureUpload, transformer: droppable());
  }

  Future<void> _loadKeys(LoadKeys event, Emitter emit) async {
    try {
      final String? getKeys = await repository.getKey();
      if (getKeys != null) {
        emit(
          state.copyWith(status: PictureStatus.error, errorMessage: getKeys),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: PictureStatus.error, errorMessage: '$e'));
    }
  }

  // ////////////// //
  Future<void> _onInit(PictureInit event, Emitter emit) async {
    try {
      if (state.controller != null && !state.controller!.value.isInitialized) {
        state.controller == null;
      }
      final RepositoryDatasource controller = await repository.openCamera();
      if (controller.pictureDatasource!.controller == null) {
        emit(
          state.copyWith(
            status: PictureStatus.error,
            errorMessage:
                controller.pictureDatasource?.errorMessage ??
                'Camera is not available',
          ),
        );
      }

      emit(
        state.copyWith(
          status: PictureStatus.init,
          controller: controller.pictureDatasource!.controller,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PictureStatus.error, errorMessage: '$e'));
    }
  }

  Future<void> _onTaken(PictureTaken event, Emitter emit) async {
    try {
      final RepositoryDatasource image = await repository.takePicture();

      if (image.pictureDatasource!.errorMessage != null ||
          image.pictureDatasource!.image == null) {
        emit(
          state.copyWith(
            status: PictureStatus.error,
            errorMessage:
                image.pictureDatasource!.errorMessage ?? 'take Picture failed',
          ),
        );
      }
      emit(
        state.copyWith(
          status: PictureStatus.loading,
          image: image.pictureDatasource!.image,
        ),
      );

      final String? enc = await repository.encrypt();
      if (enc != null) {
        emit(state.copyWith(status: PictureStatus.error, errorMessage: enc));
      }
      emit(
        state.copyWith(
          status: PictureStatus.taken,
          image: image.pictureDatasource!.image,
        ),
      );
    } on CameraException catch (e) {
      emit(state.copyWith(status: PictureStatus.error, errorMessage: '$e'));
    } catch (e) {
      emit(state.copyWith(status: PictureStatus.error, errorMessage: '$e'));
    }
  }

  Future<void> _onPickFromGallery(
    PickPictureFromGallery event,
    Emitter emit,
  ) async {
    try {
      final RepositoryDatasource image = await repository.openGallery();
      if (image.pictureDatasource!.errorMessage != null) {
        emit(
          state.copyWith(
            status: PictureStatus.error,
            errorMessage: image.pictureDatasource!.errorMessage,
          ),
        );
      }
      if (image.pictureDatasource!.image == null) return;
      emit(
        state.copyWith(
          status: PictureStatus.loading,
          image: image.pictureDatasource!.image,
        ),
      );

      final String? enc = await repository.encrypt();
      if (enc != null) {
        emit(state.copyWith(status: PictureStatus.error, errorMessage: enc));
      }
      emit(
        state.copyWith(
          status: PictureStatus.galleryPicked,
          image: image.pictureDatasource!.image,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PictureStatus.error, errorMessage: '$e'));
    }
  }

  // ////////////// //
  Future<void> _onPictureUpload(PictureUpload event, Emitter emit) async {
    try {
      emit(state.copyWith(status: PictureStatus.uploading));
      final RepositoryDatasource res = await repository.sendRequest(
        '/dataa',
        state.image!,
      );

      emit(
        state.copyWith(
          status: PictureStatus.uploaded,
          response: res.requestDatasource!.response,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PictureStatus.error, errorMessage: '$e'));
    }
  }
}
