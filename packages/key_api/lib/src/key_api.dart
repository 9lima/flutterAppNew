import 'dart:async';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:key_api/src/models/models.dart';
import 'package:dio/dio.dart';

base class ClientKeyFailure implements Exception {}

base class KeyApi {
  final AesGcm aesGcm;
  KeyModel? keymodel;

  KeyApi({AesGcm? aesGcm, KeyModel? keymodel})
    : aesGcm = aesGcm ?? AesGcm.with256bits(),
      keymodel = keymodel ?? KeyModel();
  // aes
  Future<KeyModel> getClientKey() async {
    try {
      final aesSecretKey = await aesGcm.newSecretKey();
      final ownerId = randomstr();
      final aesNonce = aesGcm.newNonce();

      return KeyModel(
        ownerId: ownerId,
        aesSecretKey: aesSecretKey,
        aesNonce: aesNonce,
        error: null,
      );
    } catch (e) {
      print('Unexpected error in KeyApi: $e');
      return KeyModel(
        ownerId: null,
        aesSecretKey: null,
        aesNonce: null,
        error: e.toString(),
      );
    }
  }

  // x25519
  Future<KeyModel> getClientXKey() async {
    try {
      final X25519 x25519 = X25519();

      final randomString = randomstr(length: 7);
      final hdfkNonce = generateHkdfNonce();
      final aesNonce = aesGcm.newNonce();
      final x25519KeyPair = await x25519.newKeyPair();
      final x25519PubKey = (await x25519KeyPair.extractPublicKey()).bytes;

      var x25519PubKeyCopy = List<int>.from(x25519PubKey);

      // Save the original last bytes and Replace the last bytes with HKDF nonce
      var hdfkNonceCopy = x25519PubKey.sublist(
        x25519PubKey.length - hdfkNonce.length,
        x25519PubKey.length,
      );

      x25519PubKeyCopy.replaceRange(
        x25519PubKeyCopy.length - hdfkNonce.length,
        x25519PubKeyCopy.length,
        hdfkNonce,
      );

      final Map<String, Object> payload = {
        'ownerId': randomString,
        'x25519PubKey': x25519PubKeyCopy,
        'hkdfNonce': hdfkNonceCopy,
      };
      Dio dio = Dio();
      dio.options.baseUrl = 'http://10.0.2.2:8000/';
      dio.options.contentType = 'application/json';

      final response = await dio.post('/key', data: payload);

      final Map<String, dynamic> data = response.data;

      if (response.statusCode != 200 ||
          !data.containsKey('pubKey') ||
          data['ownerId'] != randomString) {
        throw ClientKeyFailure();
      }
      final serverPubKey = (data['pubKey'] as List<dynamic>?)?.cast<int>();
      print(serverPubKey);
      if (serverPubKey!.isEmpty) {
        throw ClientKeyFailure();
      }

      final serverPublicKey = SimplePublicKey(
        serverPubKey,
        type: KeyPairType.x25519,
      );
      final sharedSecret = await x25519.sharedSecretKey(
        keyPair: x25519KeyPair,
        remotePublicKey: serverPublicKey,
      );

      final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

      final aesKey = await hkdf.deriveKey(
        secretKey: sharedSecret,
        nonce: hdfkNonce,
      );

      return KeyModel(
        ownerId: randomString,
        aesSecretKey: aesKey,
        aesNonce: aesNonce,
        error: null,
      );
    } catch (e) {
      print('Unexpected error in KeyApi: $e');
      return KeyModel(error: e.toString());
    }
  }
}

String randomstr({int length = 7}) {
  const String chars =
      '0123456789abcd?[\\]^_`{|}efghijklmnouvwxOPQRSTUVWXYZ!"#\$%pqrst&\'()*+,-.yzABCDEFGHIJKLMN/:;<=>~ ';
  Random random = Random();

  final randomString = String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
  return randomString;
}

List<int> generateHkdfNonce() {
  final List<int> hkdfNonce = [];

  for (int i = 0; i < 16; i++) {
    hkdfNonce.add(Random.secure().nextInt(256));
  }
  return hkdfNonce;
}
