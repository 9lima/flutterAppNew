import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnectionApi {
  InternetConnectionApi({InternetConnectionChecker? internetConnectionChecker})
    : internetConnectionChecker =
          internetConnectionChecker ??
          InternetConnectionChecker.createInstance(
            checkInterval: const Duration(seconds: 2),

            addresses: [
              // AddressCheckOption(uri: Uri.parse('https://www.google.com')),
              AddressCheckOption(uri: Uri.parse('http://10.0.2.2:8000')),
            ],

            // localhost 10.0.2.2
            slowConnectionConfig: SlowConnectionConfig(
              enableToCheckForSlowConnection: true,
              slowConnectionThreshold: const Duration(milliseconds: 2000),
            ),
            requireAllAddressesToRespond: true,
          );
  final InternetConnectionChecker internetConnectionChecker;

  Stream<String> isConnected() {
    return internetConnectionChecker.onStatusChange
        .map((status) {
          switch (status) {
            case InternetConnectionStatus.connected:
              return 'true';
            case InternetConnectionStatus.disconnected:
              return 'false';
            case InternetConnectionStatus.slow:
              return 'slow';
          }
        })
        .distinct()
        .asBroadcastStream();
  }

  Future<String> checkNow() {
    return internetConnectionChecker.connectionStatus.then((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          return 'true';
        case InternetConnectionStatus.disconnected:
          return 'false';
        case InternetConnectionStatus.slow:
          return 'slow';
      }
    });
  }
}
