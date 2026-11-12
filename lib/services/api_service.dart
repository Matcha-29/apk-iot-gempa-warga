import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Ganti alamat aktif sesuai jaringan yang sedang digunakan.
// const String baseUrl = 'http://192.168.73.142:8000/api';
const String baseUrl = 'http://192.168.56.1:8000/api';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AreaStatus {
  const AreaStatus({
    required this.status,
    required this.intensity,
    required this.magnitude,
    required this.nodeA,
    required this.nodeB,
  });

  final String status;
  final String intensity;
  final String magnitude;
  final String nodeA;
  final String nodeB;

  bool get isDanger {
    final normalized = status.toUpperCase().replaceAll('_', ' ');
    return normalized.contains('BAHAYA') ||
        normalized.contains('GEMPA TERDETEKSI') ||
        normalized == 'DANGER' ||
        normalized.startsWith('DANGER ') ||
        normalized == 'EARTHQUAKE';
  }

  bool get isSafe {
    final normalized = status.toUpperCase();
    return normalized == 'AMAN' || normalized == 'SAFE';
  }

  String get intensityLabel => _withUnit(intensity, 'g');
  String get magnitudeLabel => _withUnit(magnitude, 'M');

  factory AreaStatus.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;
    final nestedStatus = _asMap(data['status_wilayah']);
    final source = nestedStatus == null
        ? data
        : <String, dynamic>{...data, ...nestedStatus};
    final rawStatus =
        source['status_wilayah'] is Map
            ? source['status'] ?? source['condition']
            : source['status_wilayah'] ?? source['status'] ?? source['condition'];
    return AreaStatus(
      status: _normalizeStatus(rawStatus),
      intensity: _stringValue(source, const [
        'nilai_getaran_g',
        'nilai_getaran',
        'nilai_g',
        'getaran_g',
        'intensitas',
        'intensity',
        'getaran',
        'acceleration',
      ], fallback: '-'),
      magnitude: _stringValue(source, const [
        'magnitudo',
        'magnitude',
        'nilai_magnitudo',
        'magnitude_m',
      ], fallback: '-'),
      nodeA: _nodeValue(
        source['node_a'] ??
            source['nodeA'] ??
            source['node_a_status'] ??
            source['status_node_a'] ??
            source['node_a_online'],
      ),
      nodeB: _nodeValue(
        source['node_b'] ??
            source['nodeB'] ??
            source['node_b_status'] ??
            source['status_node_b'] ??
            source['node_b_online'],
      ),
    );
  }
}

String _normalizeStatus(dynamic value) {
  if (value is Map) {
    final map = _asMap(value)!;
    value = map['status'] ?? map['condition'] ?? map['name'];
  }
  return value?.toString().trim().toUpperCase() ?? 'TIDAK DIKETAHUI';
}

String _withUnit(String value, String unit) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == '-') return normalized;
  return normalized.toLowerCase().endsWith(unit.toLowerCase())
      ? normalized
      : '$normalized $unit';
}

class EarthquakeHistoryItem {
  const EarthquakeHistoryItem({
    required this.date,
    required this.intensity,
    required this.duration,
    required this.consensus,
    required this.category,
  });

  final String date;
  final String intensity;
  final String duration;
  final String consensus;
  final String category;

  factory EarthquakeHistoryItem.fromJson(Map<String, dynamic> json) {
    final category = _stringValue(json, const [
      'kategori',
      'category',
      'type',
      'jenis',
    ], fallback: '');
    return EarthquakeHistoryItem(
      date: _stringValue(json, const [
        'tanggal',
        'date',
        'created_at',
        'waktu',
        'timestamp',
      ], fallback: '-'),
      intensity: _stringValue(json, const [
        'intensitas',
        'intensity',
        'magnitudo',
        'magnitude',
        'judul',
      ], fallback: 'Kejadian gempa'),
      duration: _stringValue(json, const ['durasi', 'duration'], fallback: '-'),
      consensus: _stringValue(json, const [
        'status_konsensus',
        'consensus',
        'status',
      ], fallback: 'Belum diketahui'),
      category: category.isEmpty ? 'Gempa' : category,
    );
  }
}

class ApiService {
  static final ApiService instance = ApiService();

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    final result = await _post(
      '/login',
      body: {'email_or_phone': emailOrPhone, 'password': password},
    );
    final response = _asMap(result);
    if (response == null) {
      throw const ApiException('Format respons login dari server tidak valid.');
    }
    final data = _asMap(response['data']) ?? response;
    final token =
        data['token'] ?? data['access_token'] ?? response['token'];
    final user = _asMap(data['user']) ?? data;
    final preferences = await SharedPreferences.getInstance();
    if (token != null) {
      await preferences.setString('auth_token', token.toString());
    } else {
      await preferences.remove('auth_token');
    }
    await preferences.setString('session_user', jsonEncode(user));
    return user;
  }

  Future<Map<String, dynamic>> aktivasiAkun(String kodeAktivasi) async {
    final result = await _post(
      '/aktivasi',
      body: {'kode_aktivasi': kodeAktivasi},
    );
    final response = _asMap(result);
    if (response == null) {
      throw const ApiException(
        'Format respons aktivasi dari server tidak valid.',
      );
    }
    return _asMap(response['data']) ?? response;
  }

  Future<AreaStatus> getStatusWilayah() async {
    final result = await _get('/status-wilayah');
    final json = _asMap(result);
    if (json == null) {
      throw const ApiException(
        'Format status wilayah dari server tidak valid.',
      );
    }
    return AreaStatus.fromJson(json);
  }

  Future<List<EarthquakeHistoryItem>> getRiwayatGempa() async {
    final result = await _get('/riwayat-gempa');
    final items = _extractList(result);
    return items.map(EarthquakeHistoryItem.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> kirimRespons(String status) async {
    final normalizedStatus = switch (status.trim().toUpperCase()) {
      'AMAN' => 'AMAN',
      'BUTUH BANTUAN' || 'BUTUH_BANTUAN' => 'BUTUH_BANTUAN',
      _ => throw const ApiException('Status respons warga tidak valid.'),
    };
    final result = await _post(
      '/respons-warga',
      body: {'status': normalizedStatus},
    );
    final response = _asMap(result);
    if (response == null) {
      throw const ApiException(
        'Format konfirmasi respons dari server tidak valid.',
      );
    }
    return _asMap(response['data']) ?? response;
  }

  Future<dynamic> _get(String path) async {
    try {
      final response = await _client
          .get(_uri(path), headers: await _headers())
          .timeout(const Duration(seconds: 20));
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException('Koneksi ke server melewati batas waktu.');
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa alamat API dan koneksi jaringan.',
      );
    }
  }

  Future<dynamic> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client
          .post(_uri(path), headers: await _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException('Koneksi ke server melewati batas waktu.');
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa alamat API dan koneksi jaringan.',
      );
    }
  }

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path');

  Future<Map<String, String>> _headers() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decodeResponse(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw ApiException(
            'Server mengembalikan HTTP ${response.statusCode}.',
          );
        }
        throw const ApiException('Format respons server tidak valid.');
      }
    } else {
      decoded = <String, dynamic>{};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorBody = _asMap(decoded);
      final message = errorBody == null
          ? ''
          : _stringValue(errorBody, const ['message', 'error'], fallback: '');
      throw ApiException(
        message.isEmpty
            ? 'Permintaan gagal (HTTP ${response.statusCode}).'
            : message,
      );
    }
    return decoded;
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  return null;
}

List<Map<String, dynamic>> _extractList(dynamic response) {
  dynamic value = response;
  final envelope = _asMap(response);
  if (envelope != null) {
    value = envelope['data'] ?? envelope['items'] ?? envelope['results'];
    final nested = _asMap(value);
    if (nested != null) {
      value = nested['data'] ?? nested['items'] ?? nested['results'];
    }
  }
  if (value is! List) {
    throw const ApiException('Format riwayat gempa dari server tidak valid.');
  }
  return value
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

String _stringValue(
  Map<String, dynamic> json,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

String _nodeValue(dynamic value) {
  if (value is Map) {
    final map = _asMap(value)!;
    value = map['status'] ??
        map['state'] ??
        map['online'] ??
        map['is_online'] ??
        map['aktif'];
  }
  if (value is bool) return value ? 'Online' : 'Offline';
  if (value is num) return value != 0 ? 'Online' : 'Offline';
  if (value == null) return 'Tidak diketahui';
  final normalized = value.toString().trim().toLowerCase();
  if (const ['1', 'true', 'online', 'aktif', 'connected'].contains(normalized)) {
    return 'Online';
  }
  if (const ['0', 'false', 'offline', 'nonaktif', 'disconnected'].contains(
    normalized,
  )) {
    return 'Offline';
  }
  return value.toString();
}
