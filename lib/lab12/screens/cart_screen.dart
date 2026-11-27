
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const background = Color(0xFFF8F5F0);
  static const dark = Color(0xFF28231F);
  static const gold = Color(0xFFB49363);

  final promoController = TextEditingController();
  bool promoApplied = false;

  @override
  void dispose() {
    promoController.dispose();
    super.dispose();
  }

  String money(double value) {
    return '${value.toStringAsFixed(0)} ₸';
  }

  void applyPromo() {
    final code = promoController.text.trim().toUpperCase();

    if (code == 'LUNA10') {
      setState(() {
        promoApplied = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('LUNA10 applied! You saved 10%.'),
          backgroundColor: Color(0xFF42634B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        promoApplied = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code. Try LUNA10.'),
          backgroundColor: Color(0xFFB83B45),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> confirmOrder(double total) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm your order'),
          content: Text(
            'Your total is ${money(total)}.\n'
                'Would you like to place this demo order?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    context.read<CartBloc>().add(const ClearCartEvent());

    setState(() {
      promoApplied = false;
      promoController.clear();
    });

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF42634B),
              ),
              SizedBox(width: 10),
              Text('Order placed!'),
            ],
          ),
          content: const Text(
            'Thank you for choosing LUNA MODE!\n'
                'Your demo order has been confirmed.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('CONTINUE SHOPPING'),
            ),
          ],
        );
      },
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget cartItem(BuildContext context, Product product) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 85,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 85,
                  height: 100,
                  color: const Color(0xFFECE5DA),
                  child: const Icon(
                    Icons.image_outlined,
                    color: gold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      color: gold,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    money(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove one item',
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              onPressed: () {
                context.read<CartBloc>().add(
                  RemoveProductEvent(product.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text(
          'MY SHOPPING BAG',
          style: TextStyle(
            fontFamily: 'serif',
            letterSpacing: 2,
            color: dark,
            fontSize: 20,
          ),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Clear all',
                onPressed: state.items.isEmpty
                    ? null
                    : () {
                  context
                      .read<CartBloc>()
                      .add(const ClearCartEvent());

                  setState(() {
                    promoApplied = false;
                    promoController.clear();
                  });
                },
                icon: const Icon(Icons.delete_sweep_outlined),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 85,
                    color: gold,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your bag is empty.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 27,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your next favorite piece is waiting.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('EXPLORE COLLECTION'),
                  ),
                ],
              ),
            );
          }

          final subtotal = state.totalPrice;
          final discount = promoApplied ? subtotal * 0.10 : 0.0;
          final finalTotal = subtotal - discount;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      '${state.count} items in your bag',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.items.map(
                          (product) => cartItem(context, product),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'HAVE A PROMO CODE?',
                      style: TextStyle(
                        color: dark,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promoController,
                            decoration: InputDecoration(
                              hintText: 'Enter code: LUNA10',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: applyPromo,
                          child: const Text('APPLY'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(23, 20, 23, 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text(money(subtotal)),
                        ],
                      ),
                      if (promoApplied) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'LUNA10 Discount (10%)',
                              style: TextStyle(
                                color: Color(0xFF42634B),
                              ),
                            ),
                            Text(
                              '- ${money(discount)}',
                              style: const TextStyle(
                                color: Color(0xFF42634B),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: dark,
                            ),
                          ),
                          Text(
                            money(finalTotal),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              confirmOrder(finalTotal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'CONFIRM ORDER',
                            style: TextStyle(letterSpacing: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Demo checkout • No real payment',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
