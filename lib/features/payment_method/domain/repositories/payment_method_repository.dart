import '../entities/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<PaymentMethod> addPaymentMethod(PaymentMethod paymentMethod);
  Future<List<PaymentMethod>> getPaymentMethods();
  Future<PaymentMethod> updatePaymentMethod(String id, PaymentMethod paymentMethod);
  Future<void> deletePaymentMethod(String id);
  Future<PaymentMethod> setDefaultPaymentMethod(String id);
}
