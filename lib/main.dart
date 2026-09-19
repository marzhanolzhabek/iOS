import 'package:flutter/material.dart';
void main(){
   //task1
  for(int i=1;i<=10;i++){
    for(int j=1;j<=10;j++){
      print("$i*$j=${i*j}");
    }
  }
  //task2

  int day =28;
  int month=2;
  int year=2026;

  int daysInMonth;

  if(month == 2){
    if(year % 400 == 0 || (year%4 == 0 && year % 100 !=0)){
      daysInMonth= 29;
    }
    else{
      daysInMonth= 28;
    }
  }else if (month == 4 || month == 6 || month ==9 || month == 11){
    daysInMonth = 30;
  }else{
    daysInMonth = 31;
  }
  if(month < 1 || month > 12 || day<1 || day> daysInMonth){
    print("Invalid date");
  }else{
    if( day <daysInMonth){
      day++;
    }else{
      day=1;

      if(month < 12){
        month++;
      }else{
        month=1;
        year++;
      }
    }
    print("$day.$month.$year");
  }
  //task3

  String text = "flutter mobile development";
  int count=0;

  for (int i =0; i<text.length; i++){
    var c=text[i];

    if(c == 'a'||c=='e'||c=='i'||c=='o'||c=='u'){
      count++;
    }
  }
  print(count);

  //task4

  List<int> numbers=[14,88,3,42,99,12,67];
  int a=numbers[0];
  int b=numbers[0];

  for(int i=0;i<numbers.length;i++){
    if(numbers[i]<a){
      a=numbers[i];
    }
    if(numbers[i]>b){
      b=numbers[i];
    }
  }
  print("min=$a  max=$b");
  print(numbers);

  //task5

  int number=3;
  bool isPrime=true;

  if (number<2){
    isPrime=false;
  }else{
    for(int i=2; i<number;i++){
      if(number%i==0){
        isPrime = false;
        break;
      }
    }
  }
  if(isPrime){
    print("Prime number");
  }else{
    print("Not prime number");
  }










}
