import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/GetIt/dependency_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/barrel.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PictureBloc>(create: (context) => getIt<PictureBloc>()),
        BlocProvider<ConnectivityBloc>(
          create: (context) => getIt<ConnectivityBloc>(),
        ),
      ],
      child: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1));
    context.read<PictureBloc>().add(LoadKeys());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ✅ ALWAYS VISIBLE BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PictureBloc>().add(PictureInit()),
                    child: const Text('Camera'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.read<PictureBloc>().add(
                      PickPictureFromGallery(),
                    ),
                    child: const Text('Gallery'),
                  ),

                  const SizedBox(width: 12),
                  BlocSelector<PictureBloc, PictureState, bool>(
                    selector: (state) {
                      return state.status == PictureStatus.galleryPicked ||
                          state.status == PictureStatus.taken;
                    },
                    builder: (context, showButton) {
                      if (showButton) {
                        return ElevatedButton(
                          onPressed: () {
                            context.read<PictureBloc>().add(PictureUpload());
                          },
                          child:
                              context.read<PictureBloc>().state.status ==
                                  PictureStatus.uploading
                              ? CircularProgressIndicator()
                              : const Text('Upload'),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),
              BlocListener<ConnectivityBloc, ConnectivityState>(
                listener: (context, state) {
                  if (state.status == ConnectivityStatus.disconnected) {
                    return showMessage(
                      context,
                      msg: 'not connected ...',
                      status: Status.error,
                    );
                  } else {
                    return showMessage(
                      context,
                      msg: 'Connected',
                      status: Status.success,
                      duration: 2,
                    );
                  }
                },
                child: SizedBox.shrink(),
              ),

              // ✅ STATE-BASED UI
              BlocBuilder<PictureBloc, PictureState>(
                builder: (context, state) {
                  switch (state.status) {
                    case PictureStatus.init:
                      if (state.controller == null) {
                        return const Text('Camera not ready');
                      }
                      // final size = MediaQuery.of(context).size;
                      // final width = size.width;
                      // final height = size.height;

                      return Transform.scale(
                        alignment: Alignment.topCenter,
                        scaleY: 0.90,
                        child: Stack(
                          children: [
                            CameraPreview(state.controller!),
                            Positioned(
                              bottom: 14,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () => context
                                      .read<PictureBloc>()
                                      .add(PictureTaken()),
                                  child: const Icon(Icons.camera_alt, size: 32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                    case PictureStatus.taken:
                    case PictureStatus.galleryPicked:
                      if (kIsWeb) {
                        return Image.network(
                          state.image!.path,
                          fit: BoxFit.fill,
                        );
                      } else {
                        return Image.file(
                          File(state.image!.path),
                          fit: BoxFit.fill,
                        );
                      }

                    case PictureStatus.error:
                      return Center(child: Text(state.errorMessage ?? 'Error'));

                    case PictureStatus.empty:
                      return const Center(child: Text('Select an option'));

                    case PictureStatus.uploaded:
                      return Center(child: Text(state.response.toString()));

                    case PictureStatus.loading:
                      return Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text("loading ..."),
                          ],
                        ),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////

enum Status { success, error }

void showMessage(
  BuildContext context, {
  required String msg,
  required Status status,
  int duration = 200,
}) {
  final snackBar = SnackBar(
    content: Text(msg),
    backgroundColor: status == Status.success ? Colors.green : Colors.red,
    duration: Duration(seconds: duration),
    behavior: SnackBarBehavior.floating,
  );

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
}
