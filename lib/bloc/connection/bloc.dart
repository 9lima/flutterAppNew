import 'dart:async';
import 'package:flutter_application_1/bloc/barrel.dart';
import 'package:flutter_application_1/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  late final StreamSubscription<String> sub;
  final AbstractRepository abstractRepository;

  ConnectivityBloc({required this.abstractRepository})
    : super(ConnectivityState.initial()) {
    sub = abstractRepository.isConnected().listen((status) {
      add(ConnectivityChanged(status));
    });
    on<ConnectivityChanged>(_onConnectivityChanged);
  }
  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter emit,
  ) async {
    try {
      if (event.status == 'true' || event.status == 'slow') {
        emit(ConnectivityState(status: ConnectivityStatus.connected));
      } else if (event.status == 'false') {
        emit(ConnectivityState(status: ConnectivityStatus.disconnected));
      }
    } catch (e) {
      emit(
        ConnectivityState(status: ConnectivityStatus.error, errorMessage: '$e'),
      );
    }
  }
}
