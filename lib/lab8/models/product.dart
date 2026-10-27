
import 'package:flutter/material.dart';

class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final IconData icon;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.icon,
  });
}
