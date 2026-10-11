
import 'package:flutter/material.dart';
import 'lab7/product.dart';
import 'lab7/detail_screen.dart';

void main() {
  runApp(const Lab7App());
}

class Lab7App extends StatelessWidget {
  const Lab7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

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
        builder: (context) => DetailScreen(product: product),
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

  Widget buildProductList(List<Product> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No favorite products yet'),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: Image.network(
              product.image,
              width: 70,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, size: 50);
              },
            ),
            title: Text(product.title),
            subtitle: Text(
              '\$${product.price.toStringAsFixed(2)}',
            ),
            trailing: IconButton(
              icon: Icon(
                favorites.contains(product)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () => toggleFavorite(product),
            ),
            onTap: () => openDetails(product),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    if (selectedIndex == 0) {
      currentPage = buildProductList(products);
    } else if (selectedIndex == 1) {
      currentPage = buildProductList(favorites);
    } else {
      currentPage = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80),
            SizedBox(height: 15),
            Text(
              'Student Profile',
              style: TextStyle(fontSize: 24),
            ),
            Text('Welcome to My Shop!'),
          ],
        ),
      );
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
