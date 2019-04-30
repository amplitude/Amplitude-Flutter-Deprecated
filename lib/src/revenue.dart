class Revenue {
  Revenue() {
    payload = <String, dynamic>{};
  }

  Map<String, dynamic> payload;

  static const EVENT = 'revenue_amount';
  static const PRODUCT_ID = r'$productId';
  static const PRICE = r'$price';
  static const QUANTITY = r'$quantity';
  static const REVENUE_TYPE = r'$revenueType';
  static const RECEIPT = r'$receipt';

  bool isValid() => payload[PRICE] != null;

  void setProductId(String productId) {
    payload[PRODUCT_ID] = productId;
  }

  void setPrice(double price) {
    payload[PRICE] = price;
  }

  void setQuantity(int quantity) {
    payload[QUANTITY] = quantity;
  }

  void setRevenueType(String revenueType) {
    payload[REVENUE_TYPE] = revenueType;
  }

  void setProperties(Map<String, dynamic> properties) {
    payload.addAll(properties);
  }

  void setReceipt(String data) {
    payload[RECEIPT] = data;
  }
}
