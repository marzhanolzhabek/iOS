abstract class MediaItem{
  String id;
  String title;
  double price;

  MediaItem(this.id,this.title,this.price);

  String getDetails();
}

mixin Downloadable{
  void download(String title){
    print("Downloading $title");
  }
}

class Audiobook extends MediaItem with Downloadable{
  double durationHours;
  String narrator;

  Audiobook(String id,String title,double price,this.durationHours,this.narrator)
      :super(id,title,price);

  @override
  String getDetails(){
    return "$title $price $durationHours $narrator";
  }
}

class EBook extends MediaItem with Downloadable{
  double fileSizeMB;
  String author;

  EBook(String id,String title,double price,this.fileSizeMB,this.author)
      :super(id,title,price);

  @override
  String getDetails(){
    return "$title $price $fileSizeMB $author";
  }
}

class ShoppingCart{
  List<MediaItem> _items = [];

  void addItem(MediaItem item){
    _items.add(item);
  }

  double calculateTotalWithTax({double taxRate=0.12}){
    double total = _items.fold(0.0,(sum,item)=>sum+item.price);
    return total+(total*taxRate);
  }

  List<MediaItem> filterByMaxPrice(double maxPrice){
    return _items.where((item)=>item.price<=maxPrice).toList();
  }

  void printReceipt(){
    for(MediaItem item in _items){
      print(item.getDetails());

      if(item is Audiobook){
        item.download(item.title);
      }
      else if(item is EBook){
        item.download(item.title);
      }
    }
    print("Total: ${calculateTotalWithTax()}");
  }
}

void main(){
  ShoppingCart cart = ShoppingCart();

  Audiobook a1 = Audiobook("1","Harry Potter",5000,10.5,"Stephen Fry");
  EBook e1 = EBook("2","The Hobbit",3500,5.2,"Tolkien");
  EBook e2 = EBook("3","1984",2500,3.5,"George Orwell");

  cart.addItem(a1);
  cart.addItem(e1);
  cart.addItem(e2);

  cart.printReceipt();

  print("Books under 4000");

  List<MediaItem> books = cart.filterByMaxPrice(4000);

  for(MediaItem item in books){
    print(item.getDetails());
  }
}