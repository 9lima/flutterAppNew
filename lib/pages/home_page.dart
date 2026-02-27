import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/GetIt/dependency_injection.dart';
import 'package:flutter_application_1/pages/cameraview_page.dart';
import 'package:flutter_application_1/pages/widgets/buttoms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/barrel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PictureBloc>(
          create: (context) => getIt<PictureBloc>()..add(LoadKeys()),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (context) => getIt<ConnectivityBloc>(),
        ),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ✅ ALWAYS VISIBLE BUTTONS
              PictureActionButtons(),

              // ✅ STATE-BASED UI
              BlocListener<PictureBloc, PictureState>(
                listener: (context, state) async {
                  final pictureDatasource = state.pictureDatasource;

                  // Only navigate if there is a valid controller
                  if (pictureDatasource?.controller == null) return;

                  final size = MediaQuery.of(context).size;

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: context.read<PictureBloc>(),
                        child: CameraView(
                          controller: pictureDatasource!.controller!,
                          size: size,
                        ),
                      ),
                    ),
                  );
                },
                child:
                    SizedBox.shrink(), // nothing to show here, navigation is side-effect
              ),
              const SizedBox(height: 12),
              BlocBuilder<PictureBloc, PictureState>(
                builder: (context, state) {
                  switch (state.status) {
                    case PictureStatus.taken:
                    case PictureStatus.galleryPicked:
                      if (kIsWeb) {
                        return Image.network(
                          state.pictureDatasource!.image!.path,
                          fit: BoxFit.fill,
                        );
                      } else {
                        return Image.file(
                          File(state.pictureDatasource!.image!.path),
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
