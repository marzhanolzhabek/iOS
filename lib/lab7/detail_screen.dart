import 'package:flutter/material.dart';
import 'product.dart';

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              product.image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 220,
                  child: Center(
                    child: Icon(Icons.image, size: 80),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Text(
              product.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 10),

            Chip(
              label: Text(product.category),
            ),

            const SizedBox(height: 20),

            Text(
              product.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Feed'),
            ),
          ],
        ),
      ),
    );
  }
}