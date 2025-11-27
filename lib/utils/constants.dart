import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF8B0000); // Wine red primary
  static const secondary = Color(0xFFD32F2F); // Lighter red for gradients
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const softGray = Color(0xFFF5F5F7);
  static const accentYellow = Color(0xFFFFD23F);
  static const cardBackground = Color(0xFFF9F9F9);
  static const premiumGray = Color(0xFF9E9E9E); // Premium gray for subtitles
  static const shadowColor = Color(0x1F000000); // Soft shadow
  // Navigation colors
  static const navSelected = Color(0xFF8B0000);
  static const navUnselected = Color(0xFF6D6D6D);
}

class ApiConstants {
  static const baseUrl = 'http://localhost:8000/api'; // Change to your Laravel server URL

  // Auth endpoints
  static const login = '$baseUrl/login';
  static const register = '$baseUrl/register';
  static const user = '$baseUrl/user';

  // Product endpoints
  static const products = '$baseUrl/products';
  static const categories = '$baseUrl/categories';

  // Cart endpoints
  static const cart = '$baseUrl/cart';
  static const cartAdd = '$baseUrl/cart/add';
  static const cartUpdate = '$baseUrl/cart/update';
  static const cartRemove = '$baseUrl/cart/remove';
  static const cartPrepare = '$baseUrl/order/prepare';

  // Favorites endpoints
  static const favorites = '$baseUrl/favorites';
  static const favoritesAdd = '$baseUrl/favorites/add';
  static const favoritesRemove = '$baseUrl/favorites/remove';

  // Order endpoints
  static const orders = '$baseUrl/orders';
  static const orderPlace = '$baseUrl/order/place';
  static const userAddress = '$baseUrl/user/address';
  static const payment = '$baseUrl/payment';
}