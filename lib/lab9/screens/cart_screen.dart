
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final delivery = cart.totalPrice >= 200 ? 0.0 : 10.0;
    final total = cart.totalPrice + delivery;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Shopping Bag',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                cart.clearCart();
              },
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear All'),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 90,
              color: Colors.deepPurple.shade200,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your bag is empty',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Find something you love!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final product = cart.items[index];

                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      product.color.withValues(alpha: 0.15),
                      child: Icon(
                        product.icon,
                        color: product.color,
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove product',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        cart.removeProduct(product);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                if (delivery == 0)
                  const Text(
                    '🎉 You unlocked FREE delivery!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'Add \$${(200 - cart.totalPrice).toStringAsFixed(2)} '
                        'more for free delivery!',
                  ),
                const SizedBox(height: 18),
                _priceRow(
                  'Subtotal',
                  cart.totalPrice,
                ),
                const SizedBox(height: 8),
                _priceRow('Delivery', delivery),
                const Divider(height: 26),
                _priceRow('Total', total, bold: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7555D9),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Order Confirmed! 🎉'),
                          content: const Text(
                            'Thank you for shopping at LUMI STORE!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                cart.clearCart();
                                Navigator.pop(dialogContext);
                                Navigator.pop(context);
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
      String title,
      double price, {
        bool bold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: bold ? 20 : 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: bold ? 22 : 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: bold ? const Color(0xFF7555D9) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
