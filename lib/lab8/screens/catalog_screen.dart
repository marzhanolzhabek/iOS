
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_grid_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool isGridView = false;
  int nextId = 7;

  List<Product> products = [];

  List<Product> getInitialProducts() {
    return const [
      Product(
        id: 1,
        title: 'Wireless Headphones',
        category: 'Electronics',
        price: 99.99,
        rating: 4.8,
        icon: Icons.headphones,
      ),
      Product(
        id: 2,
        title: 'Smart Watch',
        category: 'Accessories',
        price: 149.99,
        rating: 4.6,
        icon: Icons.watch,
      ),
      Product(
        id: 3,
        title: 'Digital Camera',
        category: 'Electronics',
        price: 299.99,
        rating: 4.9,
        icon: Icons.camera_alt,
      ),
      Product(
        id: 4,
        title: 'Laptop',
        category: 'Computers',
        price: 799.99,
        rating: 4.7,
        icon: Icons.laptop_mac,
      ),
      Product(
        id: 5,
        title: 'Sneakers',
        category: 'Fashion',
        price: 89.99,
        rating: 4.5,
        icon: Icons.directions_run,
      ),
      Product(
        id: 6,
        title: 'Backpack',
        category: 'Accessories',
        price: 59.99,
        rating: 4.4,
        icon: Icons.backpack,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    products = getInitialProducts();
  }

  void toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  Future<void> refreshCatalog() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    );

    if (!mounted) return;

    final newProduct = Product(
      id: nextId,
      title: 'New Product $nextId',
      category: 'New Arrival',
      price: 49.99 + nextId,
      rating: 4.5,
      icon: Icons.shopping_bag,
    );

    setState(() {
      products.insert(0, newProduct);
      nextId++;
    });
  }

  void deleteProduct(Product product) {
    final originalIndex = products.indexWhere(
          (item) => item.id == product.id,
    );

    if (originalIndex == -1) return;

    setState(() {
      products.removeAt(originalIndex);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: Text('${product.title} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (!mounted) return;

            setState(() {
              final restoreIndex = originalIndex.clamp(
                0,
                products.length,
              );

              products.insert(restoreIndex, product);
            });
          },
        ),
      ),
    );
  }

  void resetCatalog() {
    setState(() {
      products = getInitialProducts();
      nextId = 7;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 85,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Catalog is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text('All products have been removed.'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: resetCatalog,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Catalog'),
          ),
        ],
      ),
    );
  }

  Widget buildListView() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 0.5,
        );
      },
      itemBuilder: (context, index) {
        final product = products[index];

        return Dismissible(
          key: ValueKey(product.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
          ),
          onDismissed: (direction) {
            deleteProduct(product);
          },
          child: ProductListItem(product: product),
        );
      },
    );
  }

  Widget buildGridView() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductGridCard(product: product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Catalog'),
        actions: [
          IconButton(
            tooltip: isGridView
                ? 'Switch to List'
                : 'Switch to Grid',
            onPressed: toggleView,
            icon: Icon(
              isGridView
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
          ),
        ],
      ),
      body: products.isEmpty
          ? buildEmptyState()
          : RefreshIndicator(
        onRefresh: refreshCatalog,
        child: isGridView
            ? buildGridView()
            : buildListView(),
      ),
    );
  }
}
