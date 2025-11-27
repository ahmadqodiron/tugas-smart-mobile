import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<String?> get token async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> _getHeaders({bool auth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> _get(String url, {bool auth = false}) async {
    if (auth) await token;
    return http.get(Uri.parse(url), headers: _getHeaders(auth: auth));
  }

  Future<http.Response> _post(String url, {Map<String, dynamic>? body, bool auth = false}) async {
    if (auth) await token;
    return http.post(
      Uri.parse(url),
      headers: _getHeaders(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> _put(String url, {Map<String, dynamic>? body, bool auth = false}) async {
    if (auth) await token;
    return http.put(
      Uri.parse(url),
      headers: _getHeaders(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> _delete(String url, {bool auth = false}) async {
    if (auth) await token;
    return http.delete(Uri.parse(url), headers: _getHeaders(auth: auth));
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String phone) async {
    final response = await _post(ApiConstants.login, body: {'phone': phone});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await setToken(data['token']);
      return data;
    }
    throw Exception('Login failed');
  }

  Future<Map<String, dynamic>> register(String name, String phone) async {
    final response = await _post(ApiConstants.register, body: {
      'name': name,
      'phone': phone,
    });
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await setToken(data['token']);
      return data;
    }
    throw Exception('Registration failed');
  }

  Future<User?> getUser() async {
    final response = await _get(ApiConstants.user, auth: true);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Product methods
  Future<List<Product>> getProducts({int? categoryId}) async {
    String url = ApiConstants.products;
    if (categoryId != null) {
      url += '?category_id=$categoryId';
    }
    final response = await _get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<Product> getProduct(int id) async {
    final response = await _get('${ApiConstants.products}/$id');
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load product');
  }

  Future<Product> addProduct(String name, String image, double price, String description, int categoryId) async {
    final response = await _post(ApiConstants.products, body: {
      'name': name,
      'image': image,
      'price': price,
      'description': description,
      'category_id': categoryId,
    }, auth: true);
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add product');
  }

  Future<List<Category>> getCategories() async {
    final response = await _get(ApiConstants.categories);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception('Failed to load categories');
  }

  // Cart methods
  Future<List<CartItem>> getCart() async {
    final response = await _get(ApiConstants.cart, auth: true);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CartItem.fromJson(json)).toList();
    }
    throw Exception('Failed to load cart');
  }

  Future<void> addToCart(int productId, int quantity) async {
    final response = await _post(ApiConstants.cartAdd, body: {
      'product_id': productId,
      'quantity': quantity,
    }, auth: true);
    if (response.statusCode != 201) {
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> updateCart(int cartItemId, int quantity) async {
    final response = await _put(ApiConstants.cartUpdate, body: {
      'cart_item_id': cartItemId,
      'quantity': quantity,
    }, auth: true);
    if (response.statusCode != 200) {
      throw Exception('Failed to update cart');
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final response = await _delete('${ApiConstants.cartRemove}/$cartItemId', auth: true);
    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart');
    }
  }

  // Favorites methods
  Future<List<Product>> getFavorites() async {
    final response = await _get(ApiConstants.favorites, auth: true);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load favorites');
  }

  Future<void> addToFavorites(int productId) async {
    final response = await _post(ApiConstants.favoritesAdd, body: {
      'product_id': productId,
    }, auth: true);
    if (response.statusCode != 201) {
      throw Exception('Failed to add to favorites');
    }
  }

  Future<void> removeFromFavorites(int productId) async {
    final response = await _delete('${ApiConstants.favoritesRemove}/$productId', auth: true);
    if (response.statusCode != 200) {
      throw Exception('Failed to remove from favorites');
    }
  }

  // Order methods
  Future<Map<String, dynamic>> prepareOrder() async {
    final response = await _post(ApiConstants.cartPrepare, auth: true);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to prepare order');
  }

  Future<Map<String, dynamic>> placeOrder(String address, String paymentMethod) async {
    final response = await _post(ApiConstants.orderPlace, body: {
      'address': address,
      'payment_method': paymentMethod,
    }, auth: true);
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to place order');
  }

  Future<List<Order>> getOrders() async {
    final response = await _get(ApiConstants.orders, auth: true);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to load orders');
  }
}