import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await ApiService().token;
      if (token != null) {
        _user = await ApiService().getUser();
      }
    } catch (e) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService().login(phone);
      _user = User.fromJson(data['user']);
    } catch (e) {
      _user = null;
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService().register(name, phone);
      _user = User.fromJson(data['user']);
    } catch (e) {
      _user = null;
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService().clearToken();
    _user = null;
    notifyListeners();
  }
}