import 'package:camera/camera.dart';

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
  final CameraController? controller;
  final XFile? image;
  final dynamic response;

  PictureState({
    required this.status,
    this.errorMessage,
    this.controller,
    this.image,
    this.response,
  });

  factory PictureState.initial() => PictureState(status: PictureStatus.empty);

  PictureState copyWith({
    PictureStatus? status,
    String? errorMessage,
    CameraController? controller,
    XFile? image,
    dynamic response,
  }) {
    return PictureState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      controller: controller ?? this.controller,
      image: image ?? this.image,
      response: response ?? this.response,
    );
  }
}
