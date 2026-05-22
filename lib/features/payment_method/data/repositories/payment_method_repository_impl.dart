import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../models/payment_method_model.dart';
import '../sources/payment_method_remote_data_source.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodRemoteDataSource remoteDataSource;

  PaymentMethodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaymentMethod> addPaymentMethod(PaymentMethod paymentMethod) async {
    final model = PaymentMethodModel(
      cardHolderName: paymentMethod.cardHolderName,
      cardBrand: paymentMethod.cardBrand,
      cardLast4: paymentMethod.cardLast4,
      expiryMonth: paymentMethod.expiryMonth,
      expiryYear: paymentMethod.expiryYear,
      isDefault: paymentMethod.isDefault,
    );
    return await remoteDataSource.addPaymentMethod(model);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    return await remoteDataSource.getPaymentMethods();
  }

  @override
  Future<PaymentMethod> updatePaymentMethod(String id, PaymentMethod paymentMethod) async {
    final model = PaymentMethodModel(
      userPaymentMethodId: paymentMethod.userPaymentMethodId,
      cardHolderName: paymentMethod.cardHolderName,
      cardBrand: paymentMethod.cardBrand,
      cardLast4: paymentMethod.cardLast4,
      expiryMonth: paymentMethod.expiryMonth,
      expiryYear: paymentMethod.expiryYear,
      isDefault: paymentMethod.isDefault,
      isActive: paymentMethod.isActive,
      createdAt: paymentMethod.createdAt,
      updatedAt: paymentMethod.updatedAt,
    );
    return await remoteDataSource.updatePaymentMethod(id, model);
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    return await remoteDataSource.deletePaymentMethod(id);
  }

  @override
  Future<PaymentMethod> setDefaultPaymentMethod(String id) async {
    return await remoteDataSource.setDefaultPaymentMethod(id);
  }
}
