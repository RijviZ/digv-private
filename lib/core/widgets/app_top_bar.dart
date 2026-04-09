import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:digv/core/theme/app_text_styles.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const AppTopBar({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
            child: SizedBox(
              height: 18,
              width: 18,
              child: SvgPicture.asset('assets/images/CaretLeft.svg'),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLight.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}
