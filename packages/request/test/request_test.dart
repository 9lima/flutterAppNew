import 'package:key_encrypt/key_encrypt.dart';
import 'package:request/src/models/models.dart';
import 'package:request/src/request_api.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';

// Mock Dio
class MockDio extends Mock implements Dio {}

// Fake XFile (we don't use it, but method requires it)
class FakeXFile extends Fake implements XFile {}

void main() {
  late MockDio mockDio;
  late RequestApi requestApi;

  setUpAll(() {
    registerFallbackValue(FakeXFile());
  });

  setUp(() {
    mockDio = MockDio();
    requestApi = RequestApi();
  });

  AESDataModel buildTestModel() {
    return AESDataModel(
      ciphertext: [1, 2, 3],
      NMMvCS: [16, 12, 60, 59, 42],
      finalList: [2, 1, 0],
    );
  }

  test(
    'returns RequestDatasource when response is 200 and contains response key',
    () async {
      final model = buildTestModel();

      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
          data: {'response': 'ok'},
        ),
      );

      final result = await requestApi.sendRequest('/test', FakeXFile(), model);

      expect(result, isNotNull);
      expect(result, isA<RequestDatasource>());
      expect(result.response, 200);

      // Verify correct payload was sent
      verify(
        () => mockDio.post(
          '/test',
          data: {
            'ciphertext': model.ciphertext,
            "NMMvCS": [16, 12, 60, 59, 42],
            'finalList': model.finalList,
          },
        ),
      ).called(1);
    },
  );

  test('returns null when statusCode is not 200', () async {
    final model = buildTestModel();

    when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 500,
        data: {'response': 'error'},
      ),
    );

    final result = await requestApi.sendRequest('/test', FakeXFile(), model);

    expect(result, isNull);
  });

  test('returns null when response does not contain "response" key', () async {
    final model = buildTestModel();

    when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {'wrong_key': 'nope'},
      ),
    );

    final result = await requestApi.sendRequest('/test', FakeXFile(), model);

    expect(result, isNull);
  });

  test('returns null when Dio throws exception', () async {
    final model = buildTestModel();

    when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: 'Network error',
      ),
    );

    final result = await requestApi.sendRequest('/test', FakeXFile(), model);

    expect(result, isNull);
  });
}
