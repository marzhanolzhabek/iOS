
import 'package:flutter/material.dart';
import 'product.dart';
import 'detail_screen.dart';
import 'feed_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Product> products = const [
    Product(
      title: 'Wireless Headphones',
      description: 'Comfortable wireless headphones with clear sound.',
      image: 'https://placehold.co/400x300/png?text=Headphones',
      price: 99.99,
      category: 'Electronics',
    ),
    Product(
      title: 'Smart Watch',
      description: 'A smart watch for daily activities and notifications.',
      image: 'https://placehold.co/400x300/png?text=Smart+Watch',
      price: 149.99,
      category: 'Accessories',
    ),
    Product(
      title: 'Digital Camera',
      description: 'A compact camera for taking beautiful photos.',
      image: 'https://placehold.co/400x300/png?text=Camera',
      price: 299.99,
      category: 'Electronics',
    ),
    Product(
      title: 'Laptop',
      description: 'A lightweight laptop for study and work.',
      image: 'https://placehold.co/400x300/png?text=Laptop',
      price: 799.99,
      category: 'Computers',
    ),
  ];

  final List<Product> favorites = [];

  void openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          product: product,
        ),
      ),
    );
  }

  void toggleFavorite(Product product) {
    setState(() {
      if (favorites.contains(product)) {
        favorites.remove(product);
      } else {
        favorites.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    if (selectedIndex == 0) {
      currentPage = FeedScreen(
        products: products,
        favorites: favorites,
        onProductTap: openDetails,
        onFavoriteTap: toggleFavorite,
      );
    } else if (selectedIndex == 1) {
      currentPage = FavoritesScreen(
        favorites: favorites,
        onProductTap: openDetails,
        onFavoriteTap: toggleFavorite,
      );
    } else {
      currentPage = const ProfileScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
