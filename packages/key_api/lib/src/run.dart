import 'dart:math';

import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  // 1️⃣ Initialize X25519
  final x25519 = X25519();
  final AesGcm aesGcm = AesGcm.with256bits();

  // 2️⃣ Generate random data (replace with your functions)
  final hdfkNonce = generateHkdfNonce(); // List<int>
  final aesNonce = aesGcm.newNonce(); // List<int>

  // 3️⃣ Generate X25519 key pair
  final x25519KeyPair = await x25519.newKeyPair();
  final x25519PubKey = (await x25519KeyPair.extractPublicKey()).bytes;

  // 4️⃣ Make a copy of the public key
  var x25519PubKeyCopy = List<int>.from(x25519PubKey);

  // 5️⃣ Save the original last bytes (before replacement)
  var hdfkNonceCopy = x25519PubKey.sublist(
    x25519PubKey.length - hdfkNonce.length,
    x25519PubKey.length,
  );

  // 6️⃣ Replace the last bytes with HKDF nonce
  x25519PubKeyCopy.replaceRange(
    x25519PubKeyCopy.length - hdfkNonce.length,
    x25519PubKeyCopy.length,
    hdfkNonce,
  );

  print(hdfkNonce);
  print(x25519PubKey);
  print(hdfkNonceCopy);
  print(x25519PubKeyCopy);
}

List<int> generateHkdfNonce() {
  final List<int> hkdfNonce = [];

  for (int i = 0; i < 16; i++) {
    hkdfNonce.add(Random.secure().nextInt(256));
  }
  return hkdfNonce;
}
