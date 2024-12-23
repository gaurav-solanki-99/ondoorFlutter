// ignore_for_file: constant_pattern_never_matches_value_type

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class Network {
  static bool connected = false;
  static void init() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      switch (result) {
        case ConnectivityResult.mobile:
          connected = true;
          break;
        case ConnectivityResult.wifi:
          connected = true;
          break;
        case ConnectivityResult.none:
          connected = false;
          break;
      }
      // if (result == ConnectivityResult.mobile) {
      //   connected = true;

      // } else if (result == ConnectivityResult.wifi) {
      //   connected = true;
      // } else {
      //   connected = false;
      // }
    });
  }

  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }
}

class ConnectionStatus extends ChangeNotifier {
  ConnectivityResult _status = ConnectivityResult.none;

  ConnectivityResult get status => _status;

  void updateConnectionStatus(ConnectivityResult newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
