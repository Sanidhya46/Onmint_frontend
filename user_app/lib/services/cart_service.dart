import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String medicineId;
  final String name;
  final double price;
  int quantity;
  final String? imageUrl;
  final String? variant;
  final double? discountPercentage;
  final double? originalPrice;

  CartItem({
    required this.medicineId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    this.variant,
    this.discountPercentage,
    this.originalPrice,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'variant': variant,
        'discountPercentage': discountPercentage,
        'originalPrice': originalPrice,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        medicineId: json['medicineId'],
        name: json['name'],
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 1,
        imageUrl: json['imageUrl'],
        variant: json['variant'],
        discountPercentage: json['discountPercentage']?.toDouble(),
        originalPrice: json['originalPrice']?.toDouble(),
      );
}

class CartService with ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal() {
    _loadFromPrefs();
  }

  final Map<String, CartItem> _items = {};
  bool _isLoading = false;

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }

  Future<void> fetchBackendCart() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('local_cart');
      if (cartString != null) {
        final List<dynamic> decoded = jsonDecode(cartString);
        _items.clear();
        for (var item in decoded) {
          final cItem = CartItem.fromJson(item as Map<String, dynamic>);
          _items[cItem.medicineId] = cItem;
        }
      }
    } catch (e) {
      debugPrint('Failed to load local cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> toSave = _items.values.map((e) => e.toJson()).toList();
      await prefs.setString('local_cart', jsonEncode(toSave));
    } catch (e) {
      debugPrint('Failed to save local cart: $e');
    }
  }

  Future<void> forceSync() async {
    await _saveToPrefs();
  }

  void addItem(String medicineId, String name, double price, String? imageUrl, {String? variant, double? originalPrice, double? discountPercentage}) {
    if (_items.containsKey(medicineId)) {
      _items.update(
        medicineId,
        (existing) => CartItem(
          medicineId: existing.medicineId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
          variant: existing.variant,
          originalPrice: existing.originalPrice,
          discountPercentage: existing.discountPercentage,
        ),
      );
    } else {
      _items.putIfAbsent(
        medicineId,
        () => CartItem(
          medicineId: medicineId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          variant: variant,
          originalPrice: originalPrice,
          discountPercentage: discountPercentage,
        ),
      );
    }
    notifyListeners();
    _saveToPrefs();
  }

  void removeItem(String medicineId) {
    _items.remove(medicineId);
    notifyListeners();
    _saveToPrefs();
  }

  void updateQuantity(String medicineId, int quantity) {
    if (_items.containsKey(medicineId)) {
      if (quantity <= 0) {
        _items.remove(medicineId);
      } else {
        _items.update(
          medicineId,
          (existing) => CartItem(
            medicineId: existing.medicineId,
            name: existing.name,
            price: existing.price,
            quantity: quantity,
            imageUrl: existing.imageUrl,
            variant: existing.variant,
            originalPrice: existing.originalPrice,
            discountPercentage: existing.discountPercentage,
          ),
        );
      }
      notifyListeners();
      _saveToPrefs();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveToPrefs();
  }

  List<Map<String, dynamic>> getOrderItems() {
    return _items.values
        .map((item) => {
              'medicineId': item.medicineId,
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
            })
        .toList();
  }
}
