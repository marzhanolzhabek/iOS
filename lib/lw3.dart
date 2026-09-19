import 'dart:collection';

class Book{
  String title;
  String Author;
  double price;
  bool isBorrowed;

  Book(this.title, this.Author, this.price, {this.isBorrowed=false});
}
class Library{
  List<Book> _books  =[];

  void addBook(Book book){
    _books.add(book);
  }
  List<Book> getAvailableBooks(){
    return _books.where((b) => b.isBorrowed == false).toList();
  }

  double getTotalValue(){
    return _books.fold(0.0,(sum,b) => sum + b.price);
  }
}
void main(){
  Library lib = Library();

  lib.addBook(Book('Abai Zholy',"Mukhtar",5400.0));

  for(Book b in lib.getAvailableBooks()){
    print('${b.title}by ${b.Author}-${b.price} tenge');
  }
  print ('Total value :${lib.getTotalValue()} tenge');
}

