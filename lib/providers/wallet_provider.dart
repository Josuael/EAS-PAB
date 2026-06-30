import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  int _balance = 150000; 
  bool _isHidden = false; 

  int get balance => _balance;
  bool get isHidden => _isHidden;

  void toggleVisibility() {
    _isHidden = !_isHidden;
    notifyListeners();
  }

  void topUp(int amount) {
    _balance += amount;
    notifyListeners();
  }

  bool pay(int amount) {
    if (_balance >= amount) {
      _balance -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }
}
