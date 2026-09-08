void processOrder({
  required String orderId,
  required double itemPrice,
  String? promoCode,
  double? deliveryFee,
}) {
  double finalDeliveryFee = deliveryFee ?? 500.0;
  double discount = 0;

  if (promoCode == 'SAVE10'){
    discount = itemPrice * 0.10;
  }
  double finalTotal = itemPrice - discount + finalDeliveryFee;
  print('Order ID: $orderId');
  print('Item price: $itemPrice');
  print('Promo code: ${promoCode ?? "None"}');
  print('Discount: $discount');
  print('Delivery fee: $finalDeliveryFee');
  print('Final total: $finalTotal');
}
void main(){
  processOrder(
    orderId: 'ORD001',
    itemPrice: 5000,
    promoCode: 'SAVE10',
  );
}