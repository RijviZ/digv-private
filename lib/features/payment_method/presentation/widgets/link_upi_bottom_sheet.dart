import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../I10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/upi_provider.dart';

class LinkUpiBottomSheet extends ConsumerStatefulWidget {
  const LinkUpiBottomSheet({super.key});

  @override
  ConsumerState<LinkUpiBottomSheet> createState() => _LinkUpiBottomSheetState();
}

class _LinkUpiBottomSheetState extends ConsumerState<LinkUpiBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _upiIdController = TextEditingController();
  String _selectedApp = 'Google Pay';
  bool _isDefault = false;
  bool _isLoading = false;

  final List<String> _upiApps = const [
    'Google Pay',
    'PhonePe',
    'Paytm',
    'BHIM UPI',
    'Other UPI',
  ];

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      ref.read(upiListProvider.notifier).addUpi(
            name: _selectedApp,
            upiId: _upiIdController.text.trim(),
            isDefault: _isDefault,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('UPI ID linked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to link UPI ID: $e')),
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
                        l10n.link_upi_id,
                        style: AppTextStyles.h6.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedApp,
                    dropdownColor: theme.colorScheme.surface,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                    decoration: InputDecoration(
                      labelText: 'UPI App / Provider',
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    ),
                    items: _upiApps.map((app) {
                      return DropdownMenuItem<String>(
                        value: app,
                        child: Text(app),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedApp = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _upiIdController,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'UPI ID',
                      hintText: 'e.g. yourname@okaxis or mobile@upi',
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter UPI ID';
                      if (!v.contains('@')) return 'Please enter a valid UPI ID (must contain @)';
                      return null;
                    },
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
                              l10n.link_upi_id,
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
