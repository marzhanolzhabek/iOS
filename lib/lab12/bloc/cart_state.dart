
import 'package:equatable/equatable.dart';
import '../models/product.dart';

class CartState extends Equatable {
  final List<Product> items;
  final double totalPrice;
  final int count;

  CartState({
    required List<Product> items,
  })  : items = List.unmodifiable(items),
        totalPrice = items.fold<double>(
          0,
              (sum, product) => sum + product.price,
        ),
        count = items.length;

  @override
  List<Object?> get props => [items, totalPrice, count];
}
