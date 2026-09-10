double processOrder({
  required String orderId,
  required double itemPrice,
  String? promoCode,
  double? deliveryFee,
}) {
  double delivery = deliveryFee ?? 500.0;
  double discountAmount = 0;

  if (promoCode == 'SAVE10') {
    discountAmount = itemPrice * 0.10;
  }

  double total = itemPrice - discountAmount + delivery;

  print('--- Order Summary ---');
  print('Order ID: $orderId');
  print('Item Price: $itemPrice');
  print('Promo Code: ${promoCode ?? "Not applied"}');
  print('Discount: $discountAmount');
  print('Delivery Fee: $delivery');
  print('Total to Pay: $total');

  return total;
}

void main() {
  double result = processOrder(
    orderId: 'ORD2026-01',
    itemPrice: 8500.0,
    promoCode: 'SAVE10',
  );

  print('Returned value: $result');

  processOrder(
    orderId: 'ORD2026-02',
    itemPrice: 3200.0,
    deliveryFee: 800.0,
  );
}