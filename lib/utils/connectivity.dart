import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class UvidAppConnectivity {
  UvidAppConnectivity._();
  static final _instance = UvidAppConnectivity._();
  final connectivity = Connectivity();
  var _connectivityController = StreamController.broadcast();
  Stream get connectivityStream => _connectivityController.stream;
  bool isAvailable = false;
  factory UvidAppConnectivity() {
    return _instance;
  }

  void initialise() async {
    if (_connectivityController.isClosed) {
      _connectivityController = StreamController.broadcast();
    }
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      isAvailable = isOnline;
    } on SocketException {
      isOnline = false;
    }
    isAvailable = isOnline;
    _connectivityController.sink.add({result: isOnline});
  }

  void disposeStream() => _connectivityController.close();
}
