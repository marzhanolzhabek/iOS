
import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalPrice =>
      _items.fold(0, (sum, product) => sum + product.price);

  bool isInCart(Product product) {
    return _items.any((item) => item.id == product.id);
  }

  void toggleCart(Product product) {
    if (isInCart(product)) {
      removeProduct(product);
    } else {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeProduct(Product product) {
    _items.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
