import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus {
  online,
  offline,
  unknown,
}

class ConnectivityNotifier extends StateNotifier<ConnectionStatus> {
  ConnectivityNotifier() : super(ConnectionStatus.unknown) {
    _init();
  }

  void _init() async {
    final connectivity = Connectivity();
    
    final result = await connectivity.checkConnectivity();
    _updateStatus([result]);

    connectivity.onConnectivityChanged.listen((result) {
      _updateStatus([result]);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      state = ConnectionStatus.online;
    } else if (results.contains(ConnectivityResult.none)) {
      state = ConnectionStatus.offline;
    } else {
      state = ConnectionStatus.unknown;
    }
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectionStatus>((ref) {
  return ConnectivityNotifier();
});
