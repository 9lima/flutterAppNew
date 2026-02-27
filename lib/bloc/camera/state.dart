import 'package:picture/picture.dart';

enum PictureStatus {
  empty,
  init,
  taken,
  galleryPicked,
  error,
  uploaded,
  loading,
  uploading,
}

class PictureState {
  final PictureStatus status;
  final String? errorMessage;
  final PictureDatasource? pictureDatasource;

  final dynamic response;

  PictureState({
    required this.status,
    this.errorMessage,
    this.pictureDatasource,
    this.response,
  });

  factory PictureState.initial() => PictureState(status: PictureStatus.empty);

  PictureState copyWith({
    PictureStatus? status,
    String? errorMessage,
    PictureDatasource? pictureDatasource,
    dynamic response,
  }) {
    return PictureState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      pictureDatasource: pictureDatasource ?? this.pictureDatasource,
      response: response ?? this.response,
    );
  }
}
