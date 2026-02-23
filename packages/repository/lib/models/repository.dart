import 'package:key_api/key_api.dart';
import 'package:key_encrypt/key_encrypt.dart';
import 'package:picture/picture.dart';
import 'package:request/request.dart';

class RepositoryDatasource {
  final Stream<String>? status;
  final KeyModel? keymodel;
  final AESDataModel? aESDataModel;
  final RequestDatasource? requestDatasource;
  final PictureDatasource? pictureDatasource;


  RepositoryDatasource({
    this.aESDataModel,
    this.requestDatasource,
    this.pictureDatasource,
    this.status,
    this.keymodel,
  
  });

  RepositoryDatasource copyWith({
    Stream<String>? status,
    KeyModel? keymodel,
    AESDataModel? aESDataModel,
    RequestDatasource? requestDatasource,
    PictureDatasource? pictureDatasource,
  }) {
    return RepositoryDatasource(
      status: status ?? this.status,
      keymodel: keymodel ?? this.keymodel,
      aESDataModel: aESDataModel ?? this.aESDataModel,
      requestDatasource: requestDatasource ?? this.requestDatasource,
      pictureDatasource: pictureDatasource ?? this.pictureDatasource
    );
  }
}
