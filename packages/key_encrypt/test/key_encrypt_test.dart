// import 'dart:typed_data';
// import 'package:key_encrypt/src/aes_api.dart';
// import 'package:key_encrypt/src/models/key_encrypt.dart';
// import 'package:test/test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:cryptography/cryptography.dart';
// import 'package:camera/camera.dart';
// import 'package:key_api/key_api.dart';

// class MockKeyModel extends Mock implements KeyModel {}

// class MockXFile extends XFile {
//   final List<int> bytes;
//   MockXFile(this.bytes) : super('');

//   @override
//   Future<Uint8List> readAsBytes() async => Uint8List.fromList(bytes);
// }

// void main() {
//   setUpAll(() {
//     registerFallbackValue(SecretKey(Uint8List.fromList([0])));
//   });

//   group('AESDataModel JSON', () {
//     test('fromJson and toJson should work correctly', () {
//       final model = AESDataModel(
//         ciphertext: [1, 2, 3],
//         lenNonce: 12,
//         lenMac: 16,
//         mac: [4, 5, 6],
//         maxValue: 10,
//         count: 10,
//         seed: 123,
//         randomList: [0, 1, 2],
//         finalList: [7, 8, 9],
//         concat: [10, 11, 12],
//       );

//       final json = model.toJson();
//       final newModel = AESDataModel.fromJson(json);

//       expect(newModel.ciphertext, equals(model.ciphertext));
//       expect(newModel.lenNonce, equals(model.lenNonce));
//       expect(newModel.lenMac, equals(model.lenMac));
//       expect(newModel.mac, equals(model.mac));
//       expect(newModel.maxValue, equals(model.maxValue));
//       expect(newModel.count, equals(model.count));
//       expect(newModel.seed, equals(model.seed));
//       expect(newModel.randomList, equals(model.randomList));
//       expect(newModel.finalList, equals(model.finalList));
//       expect(newModel.concat, equals(model.concat));
//     });
//   });

//   group('Encryption.encrypt', () {
//     test('should produce AESDataModel with mock KeyModel', () async {
//       // Mock file
//       final message = MockXFile([1, 2, 3, 4, 5]);

//       // Mock KeyModel
//       final mockKeyModel = MockKeyModel();

//       final aesGcm = AesGcm.with256bits();
//       final secretKey = await aesGcm.newSecretKey();
//       final nonce = aesGcm.newNonce();

//       // Mock the KeyModel fields
//       when(() => mockKeyModel.aesSecretKey).thenReturn(secretKey);
//       when(() => mockKeyModel.aesNonce).thenReturn(nonce);

//       final encryption = Encryption(aesGcm: aesGcm);

//       final aesData = await encryption.encrypt(message, mockKeyModel);

//       // Basic assertions
//       expect(aesData.ciphertext, isNotEmpty);
//       expect(aesData.mac, isNotNull);
//       expect(aesData.concat, isNotNull);
//       expect(aesData.finalList, isNotNull);
//       expect(aesData.randomList, isNotNull);
//       expect(aesData.count, equals(aesData.concat!.length));
//     });
//   });
// }
