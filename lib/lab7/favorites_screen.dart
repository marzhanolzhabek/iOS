
import 'package:flutter/material.dart';
import 'product.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Product> favorites;
  final Function(Product) onProductTap;
  final Function(Product) onFavoriteTap;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onProductTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Text('No favorite products yet'),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];

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
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onPressed: () => onFavoriteTap(product),
            ),
            onTap: () => onProductTap(product),
          ),
        );
      },
    );
  }
}
