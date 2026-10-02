void checkBalance({
  required String name,
  required double balance
})=>print('$name cvbn $ balance');

double deposit({
  required double currentBalance,
  double ? amount
}){
  double amt = amount ?? 0.0;
  double total = currentBalance + amt;

  return total;
}
double withdraw({
  required String name,
  required double currentBalance,
  double ? amount,
  int ? pinCode
}) {
  int realPin =1234;
  int UserPin = pinCode  ?? 0000;

  if (UserPin != realPin){
    print('WRONG PIN');
    return currentBalance;
  }double amt = amount ?? 0.0;
  if(amt > currentBalance){
    print('Not enouth money')
  }



}