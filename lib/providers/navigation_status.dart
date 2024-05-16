import 'package:flutter/material.dart';

class NavigationStatus extends ChangeNotifier {
  int currentPageIndex = 0;

  void changePageIndex(int index) {
    currentPageIndex = index;
    notifyListeners();
  }
}
