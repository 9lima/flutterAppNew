import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture/src/models/picture.dart';

class PictureApi {
  PictureApi({PictureDatasource? pictureDatasource})
    : pictureDatasource = pictureDatasource ?? PictureDatasource();
  PictureDatasource? pictureDatasource;

  Future<PictureDatasource> openCamera() async {
    try {
      if (pictureDatasource?.controller != null &&
          pictureDatasource!.controller!.value.isInitialized) {
        pictureDatasource!.controller == null;
      }
      final cameras = await availableCameras();
      final CameraDescription backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final CameraController? controller = CameraController(
        backCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      if (controller == null) {
        return pictureDatasource!.copyWith(errorMessage: 'No camera available');
      }
      await controller.initialize();
      pictureDatasource = pictureDatasource!.copyWith(
        controller: controller,
        errorMessage: null,
      );

      return pictureDatasource!;
    } on CameraException catch (e) {
      return pictureDatasource!.copyWith(
        errorMessage: 'No camera available - ${e.description}',
      );
    } catch (e) {
      return pictureDatasource!.copyWith(
        errorMessage: 'No camera available - ${e.toString()}',
      );
    }
  }

  Future<PictureDatasource> takePicture() async {
    try {
      final controller = pictureDatasource?.controller;

      if (controller == null || !controller.value.isInitialized) {
        pictureDatasource =
            pictureDatasource?.copyWith(
              errorMessage: 'Camera is not initialized',
            ) ??
            PictureDatasource(
              controller: null,
              image: null,
              errorMessage: 'Camera is not initialized',
            );
        return pictureDatasource!;
      }

      final XFile image = await controller.takePicture();

      pictureDatasource =
          pictureDatasource?.copyWith(image: image, errorMessage: null) ??
          PictureDatasource(
            controller: controller,
            image: image,
            errorMessage: null,
          );

      return pictureDatasource!;
    } catch (e) {
      pictureDatasource =
          pictureDatasource?.copyWith(errorMessage: e.toString()) ??
          PictureDatasource(
            controller: pictureDatasource?.controller,
            image: null,
            errorMessage: e.toString(),
          );

      return pictureDatasource!;
    }
  }

  // Gallery
  Future<PictureDatasource> openGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: null,
        requestFullMetadata: false,
      );
      if (image == null) {
        return pictureDatasource!;
      }
      return pictureDatasource!.copyWith(image: image, errorMessage: null);
    } catch (e) {
      return pictureDatasource!.copyWith(errorMessage: e.toString());
    }
  }
}
