import 'package:cryptography/cryptography.dart';
import 'package:key_api/key_api.dart';
import 'package:test/test.dart';

void main() {
  group('KeyModel toJson', () {
    test('should serialize all fields correctly', () async {
      // Arrange
      final secretKeyBytes = List<int>.generate(32, (i) => i);
      final secretKey = SecretKey(secretKeyBytes);
      final nonce = [1, 2, 3, 4];
      final model = KeyModel(
        ownerId: 'user123',
        aesSecretKey: secretKey,
        aesNonce: nonce,
        error: null,
      );

      final json = await model.toJson();

      expect(json['ownerId'], 'user123');

      final extractedBytes = await secretKey.extractBytes();
      expect(json['aesSecretKey'], extractedBytes);

      // Nonce
      expect(json['aesNonce'], nonce);
    });
  });
}
