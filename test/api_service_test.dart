import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apk_iot_gempa_warga/services/api_service.dart';
import 'package:apk_iot_gempa_warga/services/api_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('base URL targets the configured Laravel LAN host', () {
    expect(baseUrl, 'http://192.168.56.1:8000/api');
  });

  test('login posts credentials and persists session', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/login');
      expect(jsonDecode(request.body), {
        'email_or_phone': 'yusuf@example.com',
        'password': 'secret',
      });
      return http.Response(
        jsonEncode({
          'data': {
            'token': 'access-token',
            'user': {'name': 'Muhammad Yusuf'},
          },
        }),
        200,
      );
    });

    final user = await ApiService(client: client)
        .login('yusuf@example.com', 'secret');
    final preferences = await SharedPreferences.getInstance();

    expect(user['name'], 'Muhammad Yusuf');
    expect(preferences.getString('auth_token'), 'access-token');
    expect(jsonDecode(preferences.getString('session_user')!), {
      'name': 'Muhammad Yusuf',
    });
  });

  test('status endpoint maps region and node values', () async {
    final service = ApiService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/status-wilayah');
        return http.Response(
          jsonEncode({
            'data': {
              'status_wilayah': 'BAHAYA',
              'nilai_getaran': 0.2,
              'magnitudo': 4.1,
              'node_a': {'online': true},
              'node_b': 'Offline',
            },
          }),
          200,
        );
      }),
    );

    final status = await service.getStatusWilayah();

    expect(status.isDanger, isTrue);
    expect(status.intensity, '0.2');
    expect(status.magnitude, '4.1');
    expect(status.intensityLabel, '0.2 g');
    expect(status.magnitudeLabel, '4.1 M');
    expect(status.nodeA, 'Online');
    expect(status.nodeB, 'Offline');
  });

  test('resident response sends the canonical uppercase status', () async {
    final service = ApiService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/respons-warga');
        expect(jsonDecode(request.body), {'status': 'BUTUH_BANTUAN'});
        return http.Response(jsonEncode({'message': 'ok'}), 200);
      }),
    );

    await service.kirimRespons('butuh_bantuan');
  });

  testWidgets('status polling refreshes at the configured interval', (
    tester,
  ) async {
    var requestCount = 0;
    final state = ApiState(
      apiService: ApiService(
        client: MockClient((_) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'data': {'status_wilayah': 'AMAN', 'nilai_getaran': 0.02},
            }),
            200,
          );
        }),
      ),
    );

    state.startStatusPolling(interval: const Duration(seconds: 3));
    await tester.pump();
    await tester.pump(const Duration(seconds: 7));
    state.stopStatusPolling();
    await tester.pump();

    expect(requestCount, greaterThanOrEqualTo(2));
    expect(state.areaStatus?.status, 'AMAN');
    state.dispose();
  });

  test('history endpoint maps returned records', () async {
    final service = ApiService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/riwayat-gempa');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'tanggal': '2026-11-09 09:00',
                'magnitudo': 4.1,
                'durasi': '12 detik',
                'status_konsensus': 'Terverifikasi',
                'kategori': 'Gempa',
              },
            ],
          }),
          200,
        );
      }),
    );

    final history = await service.getRiwayatGempa();

    expect(history, hasLength(1));
    expect(history.single.intensity, '4.1');
    expect(history.single.category, 'Gempa');
    expect(history.single.consensus, 'Terverifikasi');
  });

  test('non-success responses surface the server message', () async {
    final service = ApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Kredensial tidak valid.'}),
          401,
        ),
      ),
    );

    expect(
      () => service.login('user', 'wrong'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Kredensial tidak valid.',
        ),
      ),
    );
  });
}
