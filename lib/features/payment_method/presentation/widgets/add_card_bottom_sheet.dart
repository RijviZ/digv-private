import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../I10n/app_localizations.dart';
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
    final last4 = cardNumber.length >= 4
        ? cardNumber.substring(cardNumber.length - 4)
        : cardNumber;

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

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String labelText,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
        fontSize: 14,
        fontFamily: AppTextStyles.fontFamilyPoppins,
      ),
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
        fontSize: 14,
        fontFamily: AppTextStyles.fontFamilyPoppins,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.add_new_card,
                        style: AppTextStyles.h6.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.colorScheme.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      context: context,
                      labelText: l10n.cardholder_name,
                      hintText: 'e.g. John Doe',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: _inputDecoration(
                      context: context,
                      labelText: l10n.card_number,
                      hintText: '•••• •••• •••• ••••',
                    ),
                    validator: (v) => v == null || v.length < 15 ? 'Invalid card number' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.datetime,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                            LengthLimitingTextInputFormatter(5),
                          ],
                          decoration: _inputDecoration(
                            context: context,
                            labelText: l10n.expiry_date,
                            hintText: 'MM/YY',
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
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: _inputDecoration(
                            context: context,
                            labelText: l10n.cvv,
                            hintText: '123',
                          ),
                          obscureText: true,
                          validator: (v) => v == null || v.length < 3 ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.set_default_payment_method,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontFamily: AppTextStyles.fontFamilyPoppins,
                          fontSize: 14,
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        onChanged: (val) => setState(() => _isDefault = val),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.add_new_card,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimary,
                                fontFamily: AppTextStyles.fontFamilyPoppins,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
