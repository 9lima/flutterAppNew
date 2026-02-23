import 'package:camera/camera.dart';

class PictureDatasource {
  final CameraController? controller;
  final XFile? image;
  final String? errorMessage;

  PictureDatasource({this.controller, this.image, this.errorMessage});

  PictureDatasource copyWith({
    CameraController? controller,
    XFile? image,
    String? errorMessage,
  }) {
    return PictureDatasource(
      controller: controller ?? this.controller,
      image: image ?? this.image,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
