
import 'package:flutter/material.dart';
import 'product.dart';

class FeedScreen extends StatelessWidget {
  final List<Product> products;
  final List<Product> favorites;
  final Function(Product) onProductTap;
  final Function(Product) onFavoriteTap;

  const FeedScreen({
    super.key,
    required this.products,
    required this.favorites,
    required this.onProductTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product.image,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 55,
                    height: 55,
                    child: Icon(Icons.image, size: 40),
                  );
                },
              ),
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
              onPressed: () => onFavoriteTap(product),
            ),

            onTap: () => onProductTap(product),
          ),
        );
      },
    );
  }
}
