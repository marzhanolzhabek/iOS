void checkBalance({required String name, required double balance})=>
    print('$name, your available balance is: $balance tenge');

double deposite({required double currentBalance, double? amount}){
  double amt = amount ?? 0.0;
  double total = currentBalance + amt;

  print('U deposited $amt tenge');
  print('Ur new balance is $total tenge');

  return total;
}

double withdraw({
  required String name,
  required double currentBalance,
  double? amount,
  int? pinCode,
}){
  int realPin = 1234;
  int userPin = pinCode ?? 0000;

  if (userPin != realPin){
    print('Wrong PIN! Transaction failed.');
    return currentBalance;
  }
  double amt = amount ?? 0.0;

  if(amt > currentBalance){
    print('Not enough money!');
    return currentBalance;
  }
  double total = currentBalance - amt;

  print('$name withdrew $amt tenge');
  print('Ur new balance id $total tenge');

  return total;
}

void main(){
  double myBalance = 10000.0;

  checkBalance(name: 'Marzhan', balance: myBalance);

  myBalance = deposite(currentBalance: myBalance, amount : 2500.0);

  myBalance = withdraw(
    name: 'Marzhan',
    currentBalance: myBalance,
    amount : 5000.0,
    pinCode : 1234,
  );

  myBalance = withdraw(
      name: 'Marzhan',
      currentBalance: myBalance,
      amount:1000.0,
      pinCode:9999,
  );
  checkBalance(name: 'Marzhan', balance: myBalance);
}