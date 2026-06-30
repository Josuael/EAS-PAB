import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  int get totalPrice {
    int total = 0;
    for (var item in _items) {
      total += (item['price'] as int) * (item['quantity'] as int);
    }
    return total;
  }

  void addToCart(Map<String, dynamic> product) {
    // Cek apakah item sudah ada di keranjang, jika ada tambah quantity
    int index = _items.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      _items[index]['quantity'] += 1;
    } else {
      _items.add({...product, 'quantity': 1});
    }
    notifyListeners();
  }

  // FUNGSI INI YANG SEBELUMNYA ERROR KARENA BELUM TER-COPY
  void removeFromCart(String id) {
    _items.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
