import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/tracking_step.dart';
import 'package:digv/features/booking_engine/presentation/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderProgressCard extends StatelessWidget {
  final List<TrackingStep> steps;

  const OrderProgressCard({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      label: 'ORDER PROGRESS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...steps.asMap().entries.map((e) {
            return StepTile(step: e.value, isLast: e.key == steps.length - 1);
          }),
        ],
      ),
    );
  }
}

class StepTile extends StatelessWidget {
  final TrackingStep step;
  final bool isLast;

  const StepTile({super.key, required this.step, required this.isLast});

  Color get _dotColor {
    if (step.isActive) return AppColors.blue;
    if (step.isCompleted) return AppColors.textDark;
    return AppColors.onLight;
  }

  Color get _textColor {
    if (step.isCompleted || step.isActive) return AppColors.textDark;
    return AppColors.textGray;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: step.isActive
                        ? AppColors.blue
                        : step.isCompleted
                        ? AppColors.textDark
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _dotColor, width: 1),
                  ),
                  child: step.isCompleted && !step.isActive
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child: SvgPicture.asset(
                            'assets/images/check_circle_white.svg',
                            height: 11,
                            width: 11,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        )
                      : step.isActive
                      ? const Center(child: CircleAvatar(radius: 4, backgroundColor: Colors.white))
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.onLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTextStyles.captionMedium.copyWith(
                      fontWeight: (step.isCompleted || step.isActive) ? FontWeight.w700 : FontWeight.w400,
                      color: _textColor,
                    ),
                  ),
                  if (step.subtitle != null && (step.isCompleted || step.isActive)) ...[
                    const SizedBox(height: 1),
                    Text(step.subtitle!, style: AppTextStyles.caption.copyWith(color: step.isCompleted? step.subtitleColor??Theme.of(context).colorScheme.secondary:AppColors.textGray)),
                  ],
                  if (step.actionLabel != null && step.isActive) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: step.onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: step.actionBackgroundColor ?? const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: step.actionBorderColor ?? AppColors.blueLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/lock.svg',
                              height: 12,
                              width: 12,
                              colorFilter: ColorFilter.mode(step.actionLabelColor ?? AppColors.blueLight, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              step.actionLabel!,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: step.actionLabelColor ?? AppColors.blueLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
