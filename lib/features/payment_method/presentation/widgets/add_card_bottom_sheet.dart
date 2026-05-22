import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/payment_method_provider.dart';

class AddCardBottomSheet extends ConsumerStatefulWidget {
  const AddCardBottomSheet({super.key});

  @override
  ConsumerState<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends ConsumerState<AddCardBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final cardNumber = _numberController.text.replaceAll(' ', '');
    final last4 = cardNumber.substring(cardNumber.length - 4);
    
    String brand = 'OTHER';
    if (cardNumber.startsWith('4')) {
      brand = 'VISA';
    } else if (cardNumber.startsWith('5')) {
      brand = 'MASTERCARD';
    } else if (cardNumber.startsWith('3')) {
      brand = 'AMEX';
    }

    final expiryParts = _expiryController.text.split('/');
    final month = int.parse(expiryParts[0]);
    final year = int.parse('20${expiryParts[1]}');

    final paymentMethod = PaymentMethod(
      cardHolderName: _nameController.text.trim(),
      cardBrand: brand,
      cardLast4: last4,
      expiryMonth: month,
      expiryYear: year,
      isDefault: _isDefault,
    );

    try {
      await ref.read(paymentMethodsProvider.notifier).addPaymentMethod(paymentMethod);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add card: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Card',
                  style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (v) => v == null || v.length < 15 ? 'Invalid card number' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) {
                      if (value.length == 2 && !_expiryController.text.contains('/')) {
                        _expiryController.text = '$value/';
                        _expiryController.selection = TextSelection.fromPosition(
                          const TextPosition(offset: 3),
                        );
                      }
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v)) {
                        return 'Invalid format';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 3 ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Set as default payment method'),
                Switch(
                  value: _isDefault,
                  onChanged: (val) => setState(() => _isDefault = val),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
