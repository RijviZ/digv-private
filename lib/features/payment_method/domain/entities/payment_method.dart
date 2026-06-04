class PaymentMethod {
  final String? userPaymentMethodId;
  final String cardHolderName;
  final String cardBrand;
  final String cardLast4;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  const PaymentMethod({
    this.userPaymentMethodId,
    required this.cardHolderName,
    required this.cardBrand,
    required this.cardLast4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });
}
