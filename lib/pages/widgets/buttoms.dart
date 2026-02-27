import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/barrel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PictureActionButtons extends StatelessWidget {
  const PictureActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => context.read<PictureBloc>().add(PictureInit()),
          child: const Text('Camera'),
        ),
        const SizedBox(width: 12),

        ElevatedButton(
          onPressed: () =>
              context.read<PictureBloc>().add(PickPictureFromGallery()),
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
              final status = context.read<PictureBloc>().state.status;

              return ElevatedButton(
                onPressed: () {
                  context.read<PictureBloc>().add(PictureUpload());
                },
                child: status == PictureStatus.uploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Upload'),
              );
            }

            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 12),

        BlocListener<ConnectivityBloc, ConnectivityState>(
          listener: (context, state) {
            if (state.status == ConnectivityStatus.disconnected) {
              showMessage(
                context,
                msg: 'not connected ...',
                status: Status.error,
              );
            } else {
              showMessage(
                context,
                msg: 'Connected',
                status: Status.success,
                duration: 2,
              );
            }
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ****************

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
