abstract class MediaItem {
  String id;
  String title;
  double price;

  MediaItem(this.id, this.title, this.price);

  String getDetails();
}

mixin Downloadable {
  void download(String title) {
    print("Downloading: $title");
  }
}

class Audiobook extends MediaItem with Downloadable {
  double durationHours;
  String narrator;

  Audiobook(
      String id,
      String title,
      double price,
      this.durationHours,
      this.narrator,
      ) : super(id, title, price);

  @override
  String getDetails() {
    return "Audiobook: $title | okushy: $narrator | "
        "Duration: $durationHours hours | Price: \$${price}";
  }
}

class EBook extends MediaItem with Downloadable {
  double fileSizeMB;
  String author;

  EBook(
      String id,
      String title,
      double price,
      this.fileSizeMB,
      this.author,
      ) : super(id, title, price);

  @override
  String getDetails() {
    return "EBook: $title | Author: $author | "
        "Size: $fileSizeMB MB | Price: \$${price}";
  }
}

class ShoppingCart {
  List<MediaItem> _items = [];

  void addItem(MediaItem item) {
    _items.add(item);
  }

  double calculateTotalWithTax({double taxRate = 0.12}) {
    double total = _items.fold(
      0,
          (sum, item) => sum + item.price,
    );

    return total + (total * taxRate);
  }

  List<MediaItem> filterByMaxPrice(double maxPrice) {
    return _items.where((item) => item.price <= maxPrice).toList();
  }

  void printReceipt() {

    for (MediaItem item in _items) {
      print(item.getDetails());

      if (item is Downloadable) {
        (item as Downloadable).download(item.title);
      }
    }

    print(
      "Total with tax: \$${calculateTotalWithTax().toStringAsFixed(2)}",
    );
  }
}

void main() {
  Audiobook audiobook1 = Audiobook(
    "A01",
    "Abai ",
    15.0,
    5.5,
    "Abai",
  );

  Audiobook audiobook2 = Audiobook(
    "A02",
    "Mukhtar",
    12.0,
    10.0,
    "Mukhtar",
  );

  EBook ebook1 = EBook(
    "E01",
    "Marzhan",
    20.0,
    5.2,
    "Robert ",
  );

  EBook ebook2 = EBook(
    "E02",
    "Bekzat",
    8.0,
    3.5,
    "Bekzat",
  );

  ShoppingCart cart = ShoppingCart();

  cart.addItem(audiobook1);
  cart.addItem(audiobook2);
  cart.addItem(ebook1);
  cart.addItem(ebook2);

  print("Items under \$15:");

  List<MediaItem> cheapItems = cart.filterByMaxPrice(15);

  for (MediaItem item in cheapItems) {
    print(item.getDetails());
  }

  print("");

  cart.printReceipt();
}