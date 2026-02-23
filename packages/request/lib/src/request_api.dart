import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:key_encrypt/key_encrypt.dart';
import 'package:request/src/models/models.dart';

class RequestFailure implements Exception {}

class RequestApi {
  final Dio dio;

  RequestApi({Dio? dio}) : dio = dio ?? Dio();

  Future<RequestDatasource> sendRequest(
    String path,
    XFile img,
    AESDataModel aESDataModel,
  ) async {
    try {
      dio.options.baseUrl = 'http://10.0.2.2:8000/';
      Map<String, dynamic> datei = aESDataModel.toJson();

      final response = await dio.post(path, data: datei);
      if (response.statusCode != 200 ||
          !response.data.containsKey('response')) {
        throw RequestFailure();
      }
      return RequestDatasource(response: response.data, error: null);
    } on DioException catch (dioError) {
      // Dio-specific error
      return RequestDatasource(response: null, error: dioError.toString());
    } catch (e) {
      return RequestDatasource(response: null, error: '$e');
    }
  }
}
