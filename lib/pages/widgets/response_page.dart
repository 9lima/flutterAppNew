import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/barrel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraView extends StatelessWidget {
  final CameraController? controller;
  final Size size;

  const CameraView({super.key, required this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    FlashMode? currentFlashMode = controller!.value.flashMode;

    return Scaffold(
      appBar: AppBar(title: Text("Camera")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              controller != null && controller!.value.isInitialized
                  ? Transform.scale(
                      alignment: Alignment.topCenter,
                      scaleY: 0.90,
                      child: Stack(
                        children: [
                          CameraPreview(controller!),
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: () => context.read<PictureBloc>().add(
                                  PictureTaken(),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Text('No Camera available'),

              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.read<PictureBloc>().add(PictureChangeFlash());
                        },
                        child: currentFlashMode == FlashMode.always
                            ? const Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 40,
                              )
                            : const Icon(
                                Icons.flash_off,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          context.read<PictureBloc>().add(PictureChangeLens());
                        },
                        child: const Icon(
                          Icons.change_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
