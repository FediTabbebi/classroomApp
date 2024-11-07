import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  int currentIndex = 1;

  void updatePageIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
