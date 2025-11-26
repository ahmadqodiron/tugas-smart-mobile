import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await ApiService().getCart();
    } catch (e) {
      _items = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(Product product, int quantity) async {
    try {
      await ApiService().addToCart(product.id, quantity);
      await loadCart(); // Reload cart after adding
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    try {
      await ApiService().updateCart(cartItemId, quantity);
      await loadCart(); // Reload cart after updating
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      await ApiService().removeFromCart(cartItemId);
      await loadCart(); // Reload cart after removing
    } catch (e) {
      rethrow;
    }
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}