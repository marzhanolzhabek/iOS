double processOrder({
  required String orderId,
  required double itemPrice,
  String? promoCode,
  double ?deliveryFee,
}) {
  double delivery = deliveryFee ?? 500.0;
  double discountAmount = 0;

  if (itemPrice > 4000) {
    delivery *= 1.1;
  }

  if (promoCode == 'SAVE10') {
    discountAmount = itemPrice * 0.10;
  }
  double total = itemPrice - discountAmount + delivery;

  print('orderId : $orderId');
  print('ur itemPrice : $itemPrice');
  return total;
}

void main() {
  double result = processOrder(
      orderId: 'ORD-1',
      itemPrice: 3000.0,
      promoCode: 'SAVE20',
      deliveryFee: 400.0

  );
  print('$result');
  print(processOrder(
      orderId: 'Ord2',
      itemPrice: 5000.0,
      promoCode: ''));

}
