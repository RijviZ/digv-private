import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStyle;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.width = double.infinity,
    this.height = 56,
    this.margin,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isEnabled ? Theme.of(context).colorScheme.primary: Theme.of(context).colorScheme.primary.withAlpha(128),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(36),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: textStyle ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: button);
    }
    return button;
  }
}
