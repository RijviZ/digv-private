import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/bank_account.dart';
import '../providers/bank_account_provider.dart';

class AddBankAccountBottomSheet extends ConsumerStatefulWidget {
  const AddBankAccountBottomSheet({super.key});

  @override
  ConsumerState<AddBankAccountBottomSheet> createState() => _AddBankAccountBottomSheetState();
}

class _AddBankAccountBottomSheetState extends ConsumerState<AddBankAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _holderNameCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _confirmAccountNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();

  String _accountType = 'SAVINGS';
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _holderNameCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _confirmAccountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _branchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final account = BankAccount(
      userBankAccountId: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      userId: '',
      accountHolderName: _holderNameCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim(),
      accountNumber: _accountNumberCtrl.text.trim(),
      ifscCode: _ifscCtrl.text.trim().toUpperCase(),
      branchName: _branchCtrl.text.trim().isEmpty ? 'Main Branch' : _branchCtrl.text.trim(),
      accountType: _accountType,
      isVerified: true,
      isDefault: _isDefault,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(bankAccountsProvider.notifier).addBankAccount(account);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add bank account: $e')),
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.add_bank_account,
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
              TextFormField(
                controller: _holderNameCtrl,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bankNameCtrl,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Bank Name (e.g. HDFC Bank, SBI, ICICI)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _accountNumberCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.colorScheme.onSurface),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 8) return 'Enter a valid account number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmAccountNumberCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.colorScheme.onSurface),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Confirm Account Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim() != _accountNumberCtrl.text.trim()) {
                    return 'Account numbers do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ifscCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                      ],
                      decoration: InputDecoration(
                        labelText: 'IFSC Code',
                        hintText: 'HDFC0001234',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (v.trim().length < 11) return '11 characters required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _accountType,
                      dropdownColor: theme.colorScheme.surface,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'SAVINGS', child: Text('Savings')),
                        DropdownMenuItem(value: 'CURRENT', child: Text('Current')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _accountType = val);
                      },
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
                    style: TextStyle(color: theme.colorScheme.onSurface),
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
                          l10n.add_bank_account,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
