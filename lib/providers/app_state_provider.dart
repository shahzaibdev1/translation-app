import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  // bool _isRunning = true;
  // String _currentRoute = "/";
  // bool _isBatchScan = false;
  // bool _isManualScan = false;
  bool _isPaid = false;
  // bool _showBanner = false;

  // get isRunning => _isRunning;
  // get currentRoute => _currentRoute;
  // get isBatchScan => _isBatchScan;
  // get isManualScan => _isManualScan;
  get isPaid => _isPaid;
  // get showBanner => _showBanner;

  // void enableRunning() {
  //   _isRunning = true;
  //   notifyListeners();
  // }

  // void disableRunning() {
  //   _isRunning = false;
  //   notifyListeners();
  // }

  // changeRoute(String newRoute) {
  //   _currentRoute = newRoute;
  //   notifyListeners();
  // }

  // toggleBatchScan() {
  //   _isBatchScan = !_isBatchScan;
  //   notifyListeners();
  // }

  // toggleManualScan() {
  //   _isManualScan = !_isManualScan;
  //   notifyListeners();
  // }

  // toggleShowBanner(bool value) {
  //   _showBanner = value;
  //   notifyListeners();
  // }

  setUnpaid() async {
    // ConfigStorage.setPaid(false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('_isPaid', false);
    _isPaid = false;

    notifyListeners();
  }

  setPaid() async {
    print("Purchased");
    // ConfigStorage.setPaid(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('_isPaid', true);
    _isPaid = true;

    notifyListeners();
  }
}
