
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(items: [])) {
    on<AddProductEvent>((event, emit) {
      final updatedItems = [
        ...state.items,
        event.product,
      ];

      emit(CartState(items: updatedItems));
    });

    on<RemoveProductEvent>((event, emit) {
      final updatedItems = [...state.items];

      final index = updatedItems.indexWhere(
            (product) => product.id == event.productId,
      );

      if (index != -1) {
        updatedItems.removeAt(index);
        emit(CartState(items: updatedItems));
      }
    });

    on<ClearCartEvent>((event, emit) {
      emit(CartState(items: []));
    });
  }
}
