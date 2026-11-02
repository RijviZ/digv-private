import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    super.userPaymentMethodId,
    required super.cardHolderName,
    required super.cardBrand,
    required super.cardLast4,
    required super.expiryMonth,
    required super.expiryYear,
    required super.isDefault,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['userPaymentMethodId'] ?? json['id'] ?? json['_id'];

    int month = 1;
    final rawMonth = json['expiryMonth'] ?? json['exp_month'] ?? json['expiry_month'] ?? json['month'];
    if (rawMonth is int) {
      month = rawMonth;
    } else if (rawMonth != null) {
      month = int.tryParse(rawMonth.toString()) ?? 1;
    }

    int year = DateTime.now().year;
    final rawYear = json['expiryYear'] ?? json['exp_year'] ?? json['expiry_year'] ?? json['year'];
    if (rawYear is int) {
      year = rawYear < 100 ? 2000 + rawYear : rawYear;
    } else if (rawYear != null) {
      final parsed = int.tryParse(rawYear.toString()) ?? year;
      year = parsed < 100 ? 2000 + parsed : parsed;
    }

    String last4 = (json['cardLast4'] ?? json['last4'] ?? json['card_last4'] ?? json['cardNumber'] ?? '').toString();
    if (last4.length > 4) {
      last4 = last4.substring(last4.length - 4);
    }

    return PaymentMethodModel(
      userPaymentMethodId: rawId?.toString(),
      cardHolderName: (json['cardHolderName'] ?? json['cardholderName'] ?? json['holderName'] ?? json['name'] ?? '').toString(),
      cardBrand: (json['cardBrand'] ?? json['brand'] ?? json['card_brand'] ?? 'OTHER').toString(),
      cardLast4: last4,
      expiryMonth: month,
      expiryYear: year,
      isDefault: json['isDefault'] == true || json['is_default'] == true,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool?,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userPaymentMethodId != null) 'userPaymentMethodId': userPaymentMethodId,
      'cardHolderName': cardHolderName,
      'cardBrand': cardBrand,
      'cardLast4': cardLast4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
