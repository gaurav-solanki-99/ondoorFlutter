class DummyModelClass {
  String itemName;
  String offerText;
  String itemimagePath;
  List<String> itemQuantity;
  String itemPrice;
  int itemCount;
  String selectedQuantity; // Add this property

  DummyModelClass(this.itemName, this.itemimagePath, this.offerText,
      this.selectedQuantity, this.itemQuantity, this.itemPrice, this.itemCount);
}
