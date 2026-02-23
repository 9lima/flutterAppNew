import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_conn_ckecking/internet_conn_checking.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';

// Step 1: Create a Mock class
class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late MockInternetConnectionChecker mockInternetChecker;
  late InternetConnectionApi datasource;

  setUp(() {
    mockInternetChecker = MockInternetConnectionChecker();
    datasource = InternetConnectionApi(
      internetConnectionChecker: mockInternetChecker,
    );
  });

  test('emits "true" when connection status is connected', () async {
    // Step 2: Mock the onStatusChange stream
    when(
      () => mockInternetChecker.onStatusChange,
    ).thenAnswer((_) => Stream.value(InternetConnectionStatus.connected));

    // Step 3: Listen to the datasource stream
    final result = await datasource.isConnected().first;

    expect(result, 'true');
  });

  test('emits "false" when connection status is disconnected', () async {
    when(
      () => mockInternetChecker.onStatusChange,
    ).thenAnswer((_) => Stream.value(InternetConnectionStatus.disconnected));

    final result = await datasource.isConnected().first;

    expect(result, 'false');
  });

  test('emits "slow" when connection status is slow', () async {
    when(
      () => mockInternetChecker.onStatusChange,
    ).thenAnswer((_) => Stream.value(InternetConnectionStatus.slow));

    final result = await datasource.isConnected().first;

    expect(result, 'slow');
  });

  test('emits distinct values', () async {
    // Simulate a stream with repeated values
    when(() => mockInternetChecker.onStatusChange).thenAnswer(
      (_) => Stream.fromIterable([
        InternetConnectionStatus.connected,
        InternetConnectionStatus.connected,
        InternetConnectionStatus.disconnected,
      ]),
    );

    final results = await datasource.isConnected().toList();

    // Expect repeated 'connected' to be filtered out
    expect(results, ['true', 'false']);
  });
}
