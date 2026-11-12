import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api_service.dart';

class ApiState extends ChangeNotifier {
  ApiState({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  AreaStatus? areaStatus;
  List<EarthquakeHistoryItem> earthquakeHistory = const [];
  bool loadingStatus = false;
  bool loadingHistory = false;
  String? statusError;
  String? historyError;
  String? responseInProgress;
  bool _isDisposed = false;
  bool _statusRequestInProgress = false;
  Timer? _statusPollingTimer;

  bool get isStatusPolling => _statusPollingTimer?.isActive ?? false;

  void startStatusPolling({Duration interval = const Duration(seconds: 3)}) {
    if (isStatusPolling) return;
    unawaited(refreshStatus());
    _statusPollingTimer = Timer.periodic(interval, (_) {
      unawaited(refreshStatus());
    });
  }

  void stopStatusPolling() {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = null;
  }

  Future<void> refreshStatus() async {
    if (_statusRequestInProgress || _isDisposed) return;
    _statusRequestInProgress = true;
    loadingStatus = true;
    statusError = null;
    _notifyListeners();
    try {
      areaStatus = await _apiService.getStatusWilayah();
    } on ApiException catch (error) {
      statusError = error.message;
    } finally {
      _statusRequestInProgress = false;
      loadingStatus = false;
      _notifyListeners();
    }
  }

  Future<void> refreshHistory() async {
    loadingHistory = true;
    historyError = null;
    _notifyListeners();
    try {
      earthquakeHistory = await _apiService.getRiwayatGempa();
    } on ApiException catch (error) {
      historyError = error.message;
    } finally {
      loadingHistory = false;
      _notifyListeners();
    }
  }

  Future<void> sendResidentResponse(String status) async {
    responseInProgress = status;
    _notifyListeners();
    try {
      await _apiService.kirimRespons(status);
    } finally {
      responseInProgress = null;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopStatusPolling();
    super.dispose();
  }
}
