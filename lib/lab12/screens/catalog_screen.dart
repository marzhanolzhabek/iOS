
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  final String username;

  const CatalogScreen({
    super.key,
    required this.username,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const background = Color(0xFFF8F5F0);
  static const dark = Color(0xFF28231F);
  static const gold = Color(0xFFB49363);

  String searchQuery = '';
  String selectedCategory = 'All';
  bool showFavoritesOnly = false;
  final Set<int> favorites = {};

  final categories = [
    'All',
    'Dresses',
    'Tops',
    'Bags',
    'Outerwear',
  ];

  String money(double value) {
    return '${value.toStringAsFixed(0)} ₸';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = lunaProducts.where((product) {
      final matchesSearch = product.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesCategory =
          selectedCategory == 'All' ||
              product.category == selectedCategory;

      final matchesFavorites =
          !showFavoritesOnly || favorites.contains(product.id);

      return matchesSearch &&
          matchesCategory &&
          matchesFavorites;
    }).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text(
          'LUNA MODE',
          style: TextStyle(
            fontFamily: 'serif',
            letterSpacing: 3,
            fontSize: 22,
            color: dark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () {
              setState(() {
                showFavoritesOnly = !showFavoritesOnly;
              });
            },
            icon: Icon(
              showFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: showFavoritesOnly ? Colors.red : dark,
            ),
          ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Shopping cart',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
                icon: Badge(
                  isLabelVisible: state.count > 0,
                  label: Text('${state.count}'),
                  backgroundColor: gold,
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: dark,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.username} ✨',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Find your\nsignature style.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 35,
                        height: 1.15,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(22),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: dark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXCLUSIVE COLLECTION',
                            style: TextStyle(
                              color: gold,
                              letterSpacing: 2,
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(height: 9),
                          Text(
                            'Elegance is a state of mind.',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'serif',
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 9),
                          Text(
                            'Discover timeless pieces curated for you.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search your perfect look...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: gold,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 43,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) =>
                        const SizedBox(width: 9),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected =
                              category == selectedCategory;

                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: dark,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : dark,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          showFavoritesOnly
                              ? 'My Favorites'
                              : 'Curated for You',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            color: dark,
                          ),
                        ),
                        Text(
                          '${filtered.length} items',
                          style: const TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No products found ♡',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16, 0, 16, 30,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                    constraints.crossAxisExtent >= 750 ? 3 : 2;

                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final product = filtered[index];
                          final isFavorite =
                          favorites.contains(product.id);

                          return Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(17),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, _, _) => Container(
                                          color: const Color(
                                            0xFFECE5DA,
                                          ),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            size: 45,
                                            color: gold,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: IconButton.filledTonal(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.red
                                                : dark,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (isFavorite) {
                                                favorites.remove(
                                                  product.id,
                                                );
                                              } else {
                                                favorites.add(
                                                  product.id,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.category.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: gold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: dark,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 13,
                                            color: gold,
                                          ),
                                          Text(
                                            ' ${product.rating}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        money(product.price),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: dark,
                                        ),
                                      ),
                                      const SizedBox(height: 9),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 35,
                                        child: ElevatedButton(
                                          style:
                                          ElevatedButton.styleFrom(
                                            backgroundColor: dark,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<CartBloc>()
                                                .add(
                                              AddProductEvent(
                                                product,
                                              ),
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).hideCurrentSnackBar();

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${product.name} added to bag',
                                                ),
                                                backgroundColor: dark,
                                                behavior:
                                                SnackBarBehavior.floating,
                                                duration: const Duration(
                                                  seconds: 1,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            '+ ADD TO BAG',
                                            style: TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 1,
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
                        },
                        childCount: filtered.length,
                      ),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 305,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
