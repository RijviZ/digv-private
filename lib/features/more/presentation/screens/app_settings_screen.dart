import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/more/presentation/providers/settings_provider.dart';
import 'package:digv/features/profile_settings/presentation/providers/locale_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            l10n.darkMode,
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
                    l10n.appearance,
                    style: AppTextStyles.titleLight.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
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
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.darkMode,
                                    style: AppTextStyles.h6.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontFamily: AppTextStyles.fontFamilyPoppins,
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                  ),
                                  Text(
                                    isDarkMode ? l10n.currently_on : l10n.currently_off,
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
                                          ? theme.colorScheme.primary
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
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(4),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              l10n.light,
                                              style: AppTextStyles.labelMedium.copyWith(
                                                color: theme.colorScheme.onSurface,
                                                fontFamily: AppTextStyles.fontFamilyPoppins,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (isLightSelected)
                                              SvgPicture.asset(
                                                'assets/images/check.svg',
                                                width: 14,
                                                height: 14,
                                                colorFilter: ColorFilter.mode(
                                                  theme.colorScheme.primary,
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
                                          ? theme.colorScheme.primary
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
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(4),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              l10n.dark,
                                              style: AppTextStyles.labelMedium.copyWith(
                                                color: theme.colorScheme.onSurface,
                                                fontFamily: AppTextStyles.fontFamilyPoppins,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (isDarkMode)
                                              SvgPicture.asset(
                                                'assets/images/check.svg',
                                                width: 14,
                                                height: 14,
                                                colorFilter: ColorFilter.mode(
                                                  theme.colorScheme.primary,
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
                    l10n.language,
                    style: AppTextStyles.titleLight.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: _languages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final lang = entry.value;
                        final currentLocaleCode = ref.watch(localeProvider).languageCode.toLowerCase();
                        final isSelected = currentLocaleCode == (lang['code'] as String).toLowerCase() ||
                            settings.appLanguage.toLowerCase() == (lang['code'] as String).toLowerCase();
                        final isFirst = idx == 0;

                        return Column(
                          children: [
                            if (!isFirst)
                              Divider(height: 1, color: theme.dividerColor),
                            GestureDetector(
                              onTap: () {
                                final code = lang['code']!;
                                ref.read(localeProvider.notifier).setLocale(Locale(code.toLowerCase()));
                                ref.read(settingsProvider.notifier).updateLanguage(code.toUpperCase());
                              },
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
                                        isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
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
                                              color: theme.colorScheme.onSurface,
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
                                        colorFilter: ColorFilter.mode(
                                          theme.colorScheme.primary,
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
                      l10n.lang_notice,
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
