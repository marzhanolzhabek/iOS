
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final added = cart.isInCart(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 100,
            decoration: BoxDecoration(
              color: product.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              product.icon,
              size: 42,
              color: product.color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 17,
                      color: Colors.amber,
                    ),
                    Text(' ${product.rating}'),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7555D9),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: added ? 'Remove from cart' : 'Add to cart',
            onPressed: () => cart.toggleCart(product),
            icon: Icon(
              added ? Icons.check_rounded : Icons.add_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
