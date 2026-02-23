import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:key_api/key_api.dart';
import 'package:mt19937/mt19937.dart';
import 'models/models.dart';

Future<AESDataModel> encryptIsolate(List<int> msg, KeyModel keymodel) async {
  final AesGcm aesGcm = AesGcm.with256bits();

  try {
    final secretBox = await aesGcm.encrypt(
      msg,
      secretKey: keymodel.aesSecretKey!,
      nonce: keymodel.aesNonce,
    );

    var seed = Random().nextInt(145236);
    final concat = [
      ...secretBox.nonce,
      ...secretBox.mac.bytes,
      ...await keymodel.aesSecretKey!.extractBytes(),
    ];

    final maxValue = concat.length - 1;
    final count = concat.length;

    final randomList = uniqueRandomNumberss(seed, maxValue, count);

    final finallist = List<int>.filled(count, 0);
    for (int i = 0; i < count; i++) {
      finallist[randomList[i]] = concat[i];
    }

    final List<int> NMMvCS = [
      aesGcm.nonceLength,
      aesGcm.macAlgorithm.macLength,
      maxValue,
      count,
      seed,
    ];

    return AESDataModel(
      ownerId: keymodel.ownerId,
      ciphertext: secretBox.cipherText,
      NMMvCS: NMMvCS,
      finalList: finallist,
    );
  } catch (e) {
    return AESDataModel(error: e.toString());
  }
}

List<int> uniqueRandomNumberss(int seed, int maxValue, int count) {
  final rng = MersenneTwister(seed: seed);
  final numbers = List.generate(maxValue + 1, (i) => i);
  for (int i = numbers.length - 1; i > 0; i--) {
    final j = rng.genRandInt32() % (i + 1);

    final tmp = numbers[i];
    numbers[i] = numbers[j];
    numbers[j] = tmp;
  }

  return numbers.sublist(0, count);
}
