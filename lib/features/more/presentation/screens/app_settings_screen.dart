import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/more/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  final _languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'code': 'hi'},
    {'name': 'Bengali', 'native': 'বাংলা', 'code': 'bn'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsProvider);

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
              height: 18,
              width: 18,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'App Settings',
            style: AppTextStyles.titleLight.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: settingsAsync.when(
          data: (settings) {
            final isDarkMode = settings.themeMode == 'DARK';
            final isLightSelected = settings.themeMode == 'LIGHT';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: AppTextStyles.titleLight.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/sun.svg',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: AppTextStyles.h6.copyWith(
                                      color: AppColors.textDark,
                                      fontFamily: AppTextStyles.fontFamilyPoppins,
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                  ),
                                  Text(
                                    isDarkMode ? 'Currently On' : 'Currently Off',
                                    style: AppTextStyles.caption.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontFamily: AppTextStyles.fontFamilyPoppins,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppToggle(
                              value: isDarkMode,
                              onChanged: (v) {
                                ref.read(settingsProvider.notifier).updateTheme(v ? 'DARK' : 'LIGHT');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => ref.read(settingsProvider.notifier).updateTheme('LIGHT'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isLightSelected
                                          ? AppColors.textDark
                                          : theme.dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black.withOpacity(0.08),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 34,
                                        decoration: const BoxDecoration(
                                          color: AppColors.textLight,
                                          borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(4),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Light',
                                              style: AppTextStyles.labelMedium.copyWith(
                                                color: AppColors.textDark,
                                                fontFamily: AppTextStyles.fontFamilyPoppins,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (isLightSelected)
                                              SvgPicture.asset(
                                                'assets/images/check.svg',
                                                width: 14,
                                                height: 14,
                                                colorFilter: const ColorFilter.mode(
                                                  AppColors.textDark,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => ref.read(settingsProvider.notifier).updateTheme('DARK'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? AppColors.textDark
                                          : theme.dividerColor,
                                      width: 1.08,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.bgDark,
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black.withOpacity(0.08),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 34,
                                        decoration: const BoxDecoration(
                                          color: AppColors.textLight,
                                          borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(4),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Dark',
                                              style: AppTextStyles.labelMedium.copyWith(
                                                color: AppColors.textDark,
                                                fontFamily: AppTextStyles.fontFamilyPoppins,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (isDarkMode)
                                              SvgPicture.asset(
                                                'assets/images/check.svg',
                                                width: 14,
                                                height: 14,
                                                colorFilter: const ColorFilter.mode(
                                                  AppColors.textDark,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Language',
                    style: AppTextStyles.titleLight.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: _languages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final lang = entry.value;
                        final isSelected = settings.appLanguage == lang['code'];
                        final isFirst = idx == 0;

                        return Column(
                          children: [
                            if (!isFirst)
                              Divider(height: 1, color: theme.dividerColor),
                            GestureDetector(
                              onTap: () => ref.read(settingsProvider.notifier).updateLanguage(lang['code']!),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/language.svg',
                                      width: 18,
                                      height: 18,
                                      colorFilter: ColorFilter.mode(
                                        isSelected ? AppColors.blueDeep : theme.colorScheme.secondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lang['name']!,
                                            style: AppTextStyles.h6.copyWith(
                                              color: AppColors.textDark,
                                              fontFamily: AppTextStyles.fontFamilyPoppins,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              height: 1.5,
                                            ),
                                          ),
                                          Text(
                                            lang['native']!,
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: theme.colorScheme.secondary,
                                              fontFamily: AppTextStyles.fontFamilyPoppins,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      SvgPicture.asset(
                                        'assets/images/check.svg',
                                        width: 18,
                                        height: 18,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.blueDeep,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      'Language change takes effect immediately. All app content will be displayed in the selected language.',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFC2410C),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(settingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 20,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: value ? AppColors.blueDeep : const Color(0xFFE2E8F0),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
