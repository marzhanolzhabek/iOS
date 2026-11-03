
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String search = '';
  String category = 'All';

  final List<String> categories = [
    'All',
    'Electronics',
    'Fashion',
    'Accessories',
  ];

  static const List<Product> products = [
    Product(
      id: 1,
      name: 'Wireless Headphones',
      category: 'Electronics',
      price: 99.99,
      rating: 4.8,
      icon: Icons.headphones,
      color: Color(0xFF9370DB),
    ),
    Product(
      id: 2,
      name: 'Smart Watch',
      category: 'Electronics',
      price: 149.99,
      rating: 4.7,
      icon: Icons.watch,
      color: Color(0xFF56A6A0),
    ),
    Product(
      id: 3,
      name: 'Laptop Pro',
      category: 'Electronics',
      price: 799.99,
      rating: 4.9,
      icon: Icons.laptop_mac,
      color: Color(0xFF6085D6),
    ),
    Product(
      id: 4,
      name: 'Digital Camera',
      category: 'Electronics',
      price: 299.99,
      rating: 4.6,
      icon: Icons.camera_alt,
      color: Color(0xFFE8A15A),
    ),
    Product(
      id: 5,
      name: 'Urban Sneakers',
      category: 'Fashion',
      price: 89.99,
      rating: 4.8,
      icon: Icons.directions_run,
      color: Color(0xFFE47F9A),
    ),
    Product(
      id: 6,
      name: 'Travel Backpack',
      category: 'Accessories',
      price: 59.99,
      rating: 4.5,
      icon: Icons.backpack,
      color: Color(0xFF6E9C78),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    final filtered = products.where((product) {
      final matchesSearch =
      product.name.toLowerCase().contains(search.toLowerCase());

      final matchesCategory =
          category == 'All' || product.category == category;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LUMI.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Color(0xFF7555D9),
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Discover your favorites ✨',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Everything you love, in one place.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Promotional banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7956D8),
                  Color(0xFFB19AF0),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPECIAL OFFER',
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your next favorite\nis waiting!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Free delivery on orders over \$200',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            onChanged: (value) {
              setState(() => search = value);
            },
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(item),
                    selected: category == item,
                    onSelected: (_) {
                      setState(() => category = item);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),

          Text(
            'Our Products (${filtered.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text('No products found 🔎'),
              ),
            ),

          ...filtered.map(
                (product) => ProductCard(product: product),
          ),
        ],
      ),
    );
  }
}
