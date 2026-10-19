class UpdatePriceRequest {
  const UpdatePriceRequest(this.price);

  final double price;

  Map<String, dynamic> toJson() => {'price': price};
}
