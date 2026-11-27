
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.rating,
  });

  @override
  List<Object?> get props => [
    id, name, category, price,
    imageUrl, description, rating,
  ];
}

const List<Product> lunaProducts = [
  Product(
    id: 1,
    name: 'Midnight Elegance Dress',
    category: 'Dresses',
    price: 28990,
    imageUrl:
    'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=600',
    description: 'A beautiful dress for special occasions.',
    rating: 4.9,
  ),
  Product(
    id: 2,
    name: 'Classic Beige Blazer',
    category: 'Outerwear',
    price: 34990,
    imageUrl:
    'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600',
    description: 'A timeless addition to your wardrobe.',
    rating: 4.8,
  ),
  Product(
    id: 3,
    name: 'Soft Knit Sweater',
    category: 'Tops',
    price: 18990,
    imageUrl:
    'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600',
    description: 'Soft and comfortable everyday fashion.',
    rating: 4.7,
  ),
  Product(
    id: 4,
    name: 'Urban Chic Handbag',
    category: 'Bags',
    price: 24990,
    imageUrl:
    'https://images.unsplash.com/photo-1547949003-9792a18a2601?w=600',
    description: 'Elegant accessories for every look.',
    rating: 4.9,
  ),
  Product(
    id: 5,
    name: 'Minimalist White Shirt',
    category: 'Tops',
    price: 15990,
    imageUrl:
    'https://images.unsplash.com/photo-1598554747436-c9293d6a588f?w=600',
    description: 'A classic minimalist fashion essential.',
    rating: 4.6,
  ),
  Product(
    id: 6,
    name: 'Elegant Leather Bag',
    category: 'Bags',
    price: 39990,
    imageUrl:
    'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600',
    description: 'A premium-inspired statement accessory.',
    rating: 4.9,
  ),
];
