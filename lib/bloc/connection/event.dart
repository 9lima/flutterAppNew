sealed class ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final String status;
  ConnectivityChanged(this.status);
}
