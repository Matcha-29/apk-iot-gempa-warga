import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Base URL API Laravel: Web localhost (127.0.0.1) atau Android LAN (192.168.1.15)
const String baseUrl =
    kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.10.19.93:8000/api';

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
    this.namaLokasi = 'RT 01 / RW 05',
    this.noTeleponPetugas = '08123456789',
    this.alarmAktif = false,
  });

  final String status;
  final String intensity;
  final String magnitude;
  final String nodeA;
  final String nodeB;
  final String namaLokasi;
  final String noTeleponPetugas;
  final bool alarmAktif;

  bool get isDanger {
    final normalized = status.toUpperCase().replaceAll('_', ' ');
    return alarmAktif ||
        normalized.contains('BAHAYA') ||
        normalized.contains('GEMPA') ||
        normalized == 'DANGER' ||
        normalized.startsWith('DANGER ') ||
        normalized == 'EARTHQUAKE';
  }

  bool get isGangguan {
    final normalized = status.toUpperCase().replaceAll('_', ' ');
    return normalized.contains('GANGGUAN');
  }

  bool get isWarning {
    final normalized = status.toUpperCase().replaceAll('_', ' ');
    return !isDanger &&
        (isGangguan ||
            normalized.contains('WASPADA') ||
            normalized == 'WARNING');
  }

  bool get isOffline {
    final normalized = status.toUpperCase().replaceAll('_', ' ');
    return normalized == 'OFFLINE' ||
        normalized.contains('NONAKTIF') ||
        normalized.contains('TIDAK AKTIF') ||
        (nodeA.toLowerCase() == 'offline' && nodeB.toLowerCase() == 'offline');
  }

  bool get isUjiCoba {
    final normalized = status.toUpperCase().replaceAll('_', ' ');
    return normalized.contains('UJI COBA') || normalized == 'UJI' || normalized == 'TEST';
  }

  bool get isTerkendali {
    final normalized = status.toUpperCase().replaceAll('_', ' ');
    return normalized.contains('TERKENDALI') || normalized.contains('PULIH');
  }

  bool get isSafe {
    return !isDanger && !isWarning && !isOffline && !isUjiCoba;
  }

  String get intensityLabel {
    final val = intensity.trim();
    if (val.isEmpty || val == '-') return '0.00 g';
    return _withUnit(val, 'g');
  }

  String get magnitudeLabel {
    final val = magnitude.trim();
    if (val.isEmpty || val == '-') return '0.0 M';
    return _withUnit(val, 'M');
  }

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

    final lokasiMap = _asMap(source['lokasi']);
    final namaLokasi = _stringValue(source, const [
      'nama_lokasi',
      'lokasi_nama',
      'wilayah',
      'nama_wilayah',
    ], fallback: lokasiMap?['nama_lokasi']?.toString() ?? 'RT 01 / RW 05');

    final noTeleponPetugas = _stringValue(source, const [
      'no_telepon_petugas',
      'nomor_petugas',
      'telepon_petugas',
      'kontak_petugas',
    ], fallback: lokasiMap?['nomor_petugas']?.toString() ?? '08123456789');

    final alarmAktif = source['alarm_aktif'] == true ||
        (source['log_alarm'] != null &&
            (_asMap(source['log_alarm'])?['status_alarm']?.toString().toLowerCase() == 'aktif'));

    final nodeAVal = source['node1_status'] ??
        source['node_1_status'] ??
        source['node_a'] ??
        source['nodeA'] ??
        source['node_a_status'] ??
        source['status_node_a'] ??
        source['ND-001'] ??
        source['node_1'];

    final nodeBVal = source['node2_status'] ??
        source['node_2_status'] ??
        source['node_b'] ??
        source['nodeB'] ??
        source['node_b_status'] ??
        source['status_node_b'] ??
        source['ND-002'] ??
        source['node_2'];

    final intensityVal = _stringValue(source, const [
      'max_g',
      'nilai_getaran_g',
      'nilai_getaran',
      'nilai_g',
      'getaran_g',
      'puncak_getaran_g',
      'intensitas',
      'intensity',
      'getaran',
    ], fallback: '-');

    final magnitudeVal = _stringValue(source, const [
      'max_magnitude',
      'magnitudo',
      'magnitude',
      'nilai_magnitudo',
      'magnitude_m',
    ], fallback: '-');

    return AreaStatus(
      status: _normalizeStatus(rawStatus),
      intensity: intensityVal,
      magnitude: magnitudeVal,
      nodeA: _nodeValue(nodeAVal),
      nodeB: _nodeValue(nodeBVal),
      namaLokasi: namaLokasi.isEmpty ? 'RT 01 / RW 05' : namaLokasi,
      noTeleponPetugas: noTeleponPetugas.isEmpty ? '08123456789' : noTeleponPetugas,
      alarmAktif: alarmAktif,
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
    this.nodeTerpicu = 'Node A & B',
    this.sumberKejadian = '',
  });

  final String date;
  final String intensity;
  final String duration;
  final String consensus;
  final String category;
  final String nodeTerpicu;
  final String sumberKejadian;

  factory EarthquakeHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawCategory = _stringValue(json, const [
      'kategori',
      'category',
      'type',
      'jenis',
    ], fallback: '');

    final date = _stringValue(json, const [
      'waktu_node_a',
      'waktu_node_b',
      'waktu_deteksi',
      'tanggal',
      'date',
      'created_at',
      'waktu',
      'timestamp',
    ], fallback: '-');

    final nodeTerpicu = _stringValue(json, const [
      'node_terpicu',
      'node',
      'triggered_node',
    ], fallback: '');

    final sumberKejadian = _stringValue(json, const [
      'sumber_kejadian',
      'source',
    ], fallback: '');

    final jenisLower = json['jenis']?.toString().toLowerCase() ?? '';
    final isGangguan = rawCategory.toLowerCase().contains('gangguan') ||
        jenisLower.contains('gangguan') ||
        sumberKejadian.contains('1 Node') ||
        nodeTerpicu == 'Node A' ||
        nodeTerpicu == 'Node B';

    final category = isGangguan
        ? 'Gangguan'
        : (rawCategory.isEmpty
            ? (jenisLower.contains('gempa') ? 'Gempa' : 'Info')
            : rawCategory);

    final intensity = _stringValue(json, const [
      'puncak_getaran_g',
      'tingkat_keparahan',
      'intensitas',
      'intensity',
      'magnitudo',
      'magnitude',
      'deskripsi',
      'judul',
    ], fallback: isGangguan ? 'Getaran lokal' : 'Kejadian gempa');

    final duration = _stringValue(json, const [
      'jeda_waktu_node',
      'durasi_detik',
      'durasi',
      'duration',
    ], fallback: '');

    final consensusVal = json['status_konsensus'];
    String consensus;
    if (isGangguan) {
      consensus = 'Gangguan';
    } else if (consensusVal is bool) {
      consensus = consensusVal ? 'Terverifikasi' : 'Tidak konsisten';
    } else {
      consensus = _stringValue(json, const [
        'status_konsensus',
        'consensus',
        'status',
      ], fallback: 'Terverifikasi');
    }

    String formattedIntensity = intensity;
    if (intensity.isNotEmpty && intensity != '-') {
      final doubleVal = double.tryParse(intensity);
      if (doubleVal != null) {
        formattedIntensity = '$intensity g';
      }
    } else {
      formattedIntensity = isGangguan ? 'Getaran 1 Node' : 'Kejadian gempa';
    }

    String formattedDuration = duration;
    if (duration.isNotEmpty && duration != '-') {
      if (!duration.endsWith('detik') && !duration.endsWith('s')) {
        formattedDuration = '$duration detik';
      }
    } else {
      formattedDuration = '';
    }

    String sourceInfo = sumberKejadian;
    if (sourceInfo.isEmpty) {
      if (isGangguan || nodeTerpicu == 'Node A' || nodeTerpicu == 'Node B') {
        sourceInfo = '1 Node (Gangguan Lokal)';
      } else {
        sourceInfo = 'Konsensus 2 Node';
      }
    }

    return EarthquakeHistoryItem(
      date: date,
      intensity: formattedIntensity,
      duration: formattedDuration,
      consensus: consensus,
      category: category,
      nodeTerpicu: nodeTerpicu.isEmpty
          ? (isGangguan ? '1 Node' : 'Node A & B')
          : nodeTerpicu,
      sumberKejadian: sourceInfo,
    );
  }

  String get subInfoText {
    final parts = <String>[];
    if (sumberKejadian.isNotEmpty) {
      parts.add(sumberKejadian);
    } else if (nodeTerpicu.isNotEmpty) {
      parts.add(nodeTerpicu);
    }
    if (duration.isNotEmpty && duration != '-') {
      parts.add(duration);
    }
    return parts.join(' · ');
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
    final identitas = emailOrPhone.trim();
    final payload = {
      'no_telepon': identitas,
      'identitas': identitas,
      'password': password,
    };
    debugPrint('Mengirim login ke $baseUrl/login: $payload');
    final result = await _post(
      '/login',
      body: payload,
    );
    final response = _asMap(result);
    if (response == null) {
      throw const ApiException('Format respons login dari server tidak valid.');
    }
    final data = _asMap(response['data']) ?? response;
    final token =
        data['token'] ?? data['access_token'] ?? response['token'] ?? response['access_token'];
    final user = _asMap(data['user']) ?? _asMap(response['user']) ?? data;
    final preferences = await SharedPreferences.getInstance();
    if (token != null) {
      await preferences.setString('auth_token', token.toString());
    } else {
      await preferences.remove('auth_token');
    }
    await preferences.setString('session_user', jsonEncode(user));
    return user;
  }

  Future<Map<String, dynamic>> aktivasiAkun({
    required String kodeAktivasi,
    required String password,
    required String passwordConfirmation,
  }) async {
    final payload = {
      'kode_aktivasi': kodeAktivasi.trim().toUpperCase(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    debugPrint('Mengirim aktivasi ke $baseUrl/aktivasi: $payload');
    final result = await _post(
      '/aktivasi',
      body: payload,
    );
    final response = _asMap(result);
    if (response == null) {
      throw const ApiException(
        'Format respons aktivasi dari server tidak valid.',
      );
    }
    final isSuccess = response['success'] ?? response['status'];
    if (isSuccess == false || isSuccess == 'error' || isSuccess == 0) {
      final message = response['message']?.toString() ??
          response['error']?.toString() ??
          'Aktivasi akun gagal dari server.';
      throw ApiException(message);
    }
    final data = _asMap(response['data']) ?? response;
    final token =
        data['token'] ?? data['access_token'] ?? response['token'] ?? response['access_token'];
    final user = _asMap(data['user']) ?? _asMap(response['user']) ?? data;
    final preferences = await SharedPreferences.getInstance();
    if (token != null) {
      await preferences.setString('auth_token', token.toString());
    }
    if (user.isNotEmpty) {
      await preferences.setString('session_user', jsonEncode(user));
    }
    return user;
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

  Future<Map<String, dynamic>?> getSessionUser() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('session_user');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return _asMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('auth_token');
    await preferences.remove('session_user');
  }

  Future<Map<String, dynamic>> kirimRespons(String status) async {
    final normalizedStatus = switch (status.trim().toUpperCase()) {
      'AMAN' => 'AMAN',
      'BUTUH BANTUAN' || 'BUTUH_BANTUAN' => 'BUTUH_BANTUAN',
      _ => throw const ApiException('Status respons warga tidak valid.'),
    };

    final user = await getSessionUser();
    final idPengguna = user?['id_pengguna'] ?? user?['id'] ?? 1;

    final result = await _post(
      '/respons-warga',
      body: {
        'id_pengguna': idPengguna,
        'status_respons': normalizedStatus,
        'status': normalizedStatus,
      },
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
    final targetUri = _uri(path);
    try {
      final response = await _client
          .get(targetUri, headers: await _headers())
          .timeout(const Duration(seconds: 15));
      return _decodeResponse(response);
    } on TimeoutException catch (e, st) {
      debugPrint('TimeoutException pada GET $targetUri (15 detik): $e\n$st');
      throw const ApiException('Koneksi ke server melewati batas waktu.');
    } on http.ClientException catch (e, st) {
      debugPrint('ClientException pada GET $targetUri: $e\n$st');
      throw ApiException(
        'Tidak dapat terhubung ke server ($targetUri): ${e.message}',
      );
    } catch (e, st) {
      debugPrint('Error pada GET $targetUri: $e\n$st');
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat terhubung ke server: $e');
    }
  }

  Future<dynamic> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final targetUri = _uri(path);
    try {
      final response = await _client
          .post(targetUri, headers: await _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _decodeResponse(response);
    } on TimeoutException catch (e, st) {
      debugPrint('TimeoutException pada POST $targetUri (15 detik): $e\n$st');
      throw const ApiException('Koneksi ke server melewati batas waktu.');
    } on http.ClientException catch (e, st) {
      debugPrint('ClientException pada POST $targetUri: $e\n$st');
      throw ApiException(
        'Tidak dapat terhubung ke server ($targetUri): ${e.message}',
      );
    } catch (e, st) {
      debugPrint('Error pada POST $targetUri: $e\n$st');
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat terhubung ke server: $e');
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
          final cleanBody = response.body.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
          final preview = cleanBody.length > 120
              ? '${cleanBody.substring(0, 120)}...'
              : cleanBody;
          throw ApiException(
            '[${response.statusCode}] ${preview.isNotEmpty ? preview : 'Server mengembalikan respons non-JSON'}',
          );
        }
        throw const ApiException('Format respons server tidak valid.');
      }
    } else {
      decoded = <String, dynamic>{};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorBody = _asMap(decoded);
      String detail = '';
      if (errorBody != null) {
        final errors = errorBody['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final errorList = <String>[];
          for (final entry in errors.entries) {
            final val = entry.value;
            if (val is List && val.isNotEmpty) {
              errorList.addAll(val.map((e) => e.toString()));
            } else if (val is String && val.isNotEmpty) {
              errorList.add(val);
            }
          }
          if (errorList.isNotEmpty) {
            detail = errorList.join(', ');
          }
        }
        if (detail.isEmpty) {
          detail = _stringValue(errorBody, const ['message', 'error'], fallback: '');
        }
      }
      if (detail.isEmpty && response.body.isNotEmpty) {
        detail = response.body;
      }
      final message = detail.isNotEmpty
          ? '[${response.statusCode}] $detail'
          : 'Permintaan gagal (HTTP ${response.statusCode}).';
      throw ApiException(message);
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
  if (value == null) return 'Offline';
  final normalized = value.toString().trim().toLowerCase();
  if (const ['1', 'true', 'online', 'aktif', 'connected'].contains(normalized)) {
    return 'Online';
  }
  return 'Offline';
}
