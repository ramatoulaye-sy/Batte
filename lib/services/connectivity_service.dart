import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service de connectivité (online/offline)
class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _onlineController = StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Stream<bool> get onStatusChange => _onlineController.stream;

  Future<void> initialize() async {
    final initial = await _connectivity.checkConnectivity();
    _setStatus(_mapResultToOnline(initial));

    _connectivity.onConnectivityChanged.listen((result) {
      _setStatus(_mapResultToOnline(result));
    });
  }

  bool _mapResultToOnline(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  void _setStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _onlineController.add(_isOnline);
    } else {
      _isOnline = online;
    }
  }

  void dispose() {
    _onlineController.close();
  }
}
