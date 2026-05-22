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
    return PaymentMethodModel(
      userPaymentMethodId: json['userPaymentMethodId'] as String?,
      cardHolderName: json['cardHolderName'] as String,
      cardBrand: json['cardBrand'] as String,
      cardLast4: json['cardLast4'] as String,
      expiryMonth: json['expiryMonth'] as int,
      expiryYear: json['expiryYear'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
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
