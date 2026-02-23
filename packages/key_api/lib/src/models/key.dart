import 'package:cryptography/cryptography.dart';

base class KeyModel {
  final String? ownerId;
  final SecretKey? aesSecretKey;
  final List<int>? aesNonce;

  final String? error;

  KeyModel({this.ownerId, this.aesSecretKey, this.aesNonce, this.error}) {}

  Future<Map<String, dynamic>> toJson() async {
    return {
      'ownerId': ownerId,
      'aesSecretKey': await aesSecretKey?.extractBytes(),
      'aesNonce': aesNonce,
      'error': error,
    };
  }
}
