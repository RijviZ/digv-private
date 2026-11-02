import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../I10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDob;
  File? _imageFile;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _initializeData() {
    final profileAsync = ref.read(profileProvider);
    profileAsync.whenData((user) {
      _nameCtrl.text = user.fullName ?? '';
      _emailCtrl.text = user.email ?? '';
      _phoneCtrl.text = user.phoneNumber;
      _selectedGender = user.gender;
      if (user.dateOfBirth != null) {
        _selectedDob = DateTime.tryParse(user.dateOfBirth!);
      }
      _isInitialized = true;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    final email = _emailCtrl.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      SnackBarUtils.showError(context, 'Please enter a valid email address');
      return;
    }

    final notifier = ref.read(authProvider.notifier);

    try {
      String? avatarUrl;
      if (_imageFile != null) {
        avatarUrl = await notifier.uploadAvatar(_imageFile!.path);
      } else {
        avatarUrl = ref.read(profileProvider).value?.avatarUrl;
      }

      final data = {
        "fullName": _nameCtrl.text.trim(),
        "gender": _selectedGender,
        "email": email,
        "dateOfBirth":
            _selectedDob != null ? DateFormat('yyyy-MM-dd').format(_selectedDob!) : null,
        "avatarUrl": avatarUrl,
      };

      await notifier.updateProfile(data);
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Profile updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '').trim();
        final lower = errorMsg.toLowerCase();
        if (errorMsg == 'E' ||
            errorMsg.length <= 1 ||
            lower.contains('duplicate') ||
            lower.contains('already exists') ||
            lower.contains('already in use') ||
            lower.contains('already registered') ||
            lower.contains('409')) {
          errorMsg = 'This email is already in use by another account. Please use a different email.';
        }
        SnackBarUtils.showError(context, errorMsg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_isInitialized) {
      _initializeData();
    }

    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final profileAsync = ref.watch(profileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/images/CaretLeft.svg',
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            l10n.edit_profile_title,
            style: AppTextStyles.titleLight.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: theme.dividerColor,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : ((profileAsync.value?.avatarUrl != null &&
                                          profileAsync.value!.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(profileAsync.value!.avatarUrl!)
                                      : const NetworkImage(
                                          'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg'))
                                      as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Text(
                              l10n.change_photo,
                              style: AppTextStyles.captionMedium.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _ProfileField(
                      controller: _nameCtrl,
                      hint: l10n.first_name,
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      controller: _emailCtrl,
                      hint: l10n.email_address,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _PhoneField(controller: _phoneCtrl),
                    const SizedBox(height: 12),

                    // Gender Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          dropdownColor: theme.colorScheme.surface,
                          hint: Text(
                            l10n.select_gender,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          isExpanded: true,
                          items: ['male', 'female', 'other'].map((String value) {
                            final label = value == 'male'
                                ? l10n.male
                                : (value == 'female' ? l10n.female : l10n.other);
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                label,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date of Birth
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedDob == null
                                  ? 'Date of Birth'
                                  : DateFormat('yyyy-MM-dd').format(_selectedDob!),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _selectedDob == null
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          l10n.save_changes,
                          style: AppTextStyles.button.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
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

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _ProfileField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.secondary,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disabledBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);
    final disabledTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Phone number is linked to your account and cannot be changed',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                backgroundColor: const Color(0xFF374151),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: disabledBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        '+91',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: disabledTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.dividerColor.withValues(alpha: 0.8),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: false,
                    readOnly: true,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: disabledTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.secondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successSecondaryBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Verified',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Phone number cannot be changed',
            style: TextStyle(
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              color: theme.colorScheme.secondary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
