import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ========================= CLEANER MODEL =========================

class Cleaner {
  final String name;
  final String image;
  final double rating;
  final int reviews;
  final int yearsExp;
  final int pricePerHr;

  const Cleaner({
    required this.name,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.yearsExp,
    required this.pricePerHr,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'rating': rating,
        'reviews': reviews,
        'yearsExp': yearsExp,
        'pricePerHr': pricePerHr,
      };

  factory Cleaner.fromJson(Map<String, dynamic> json) => Cleaner(
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        rating: (json['rating'] ?? 0).toDouble(),
        reviews: json['reviews'] ?? 0,
        yearsExp: json['yearsExp'] ?? 0,
        pricePerHr: json['pricePerHr'] ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cleaner &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

// ========================= NOTIFIER =========================

class FavouritesNotifier extends Notifier<List<Cleaner>> {
  static const _storageKey = 'favourite_cleaners';

  @override
  List<Cleaner> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      state = decoded.map((e) => Cleaner.fromJson(e)).toList();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void toggleFavourite(Cleaner cleaner) {
    if (state.contains(cleaner)) {
      state = state.where((c) => c != cleaner).toList();
    } else {
      state = [...state, cleaner];
    }
    _saveToPrefs();
  }

  bool isFavourite(String cleanerName) {
    return state.any((c) => c.name == cleanerName);
  }
}

// ========================= PROVIDER =========================

final favouritesProvider =
    NotifierProvider<FavouritesNotifier, List<Cleaner>>(
  FavouritesNotifier.new,
);
