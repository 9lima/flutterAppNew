enum ConnectivityStatus { connected, disconnected, error }

class ConnectivityState {
  final ConnectivityStatus status;
  final String? errorMessage;
  const ConnectivityState({required this.status, this.errorMessage});
  factory ConnectivityState.initial() =>
      ConnectivityState(status: ConnectivityStatus.disconnected);
}
