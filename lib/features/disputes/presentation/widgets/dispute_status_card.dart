import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/dispute_entity.dart';

class DisputeStatusCard extends StatelessWidget {
  final DisputeEntity dispute;
  final String? orderId;

  const DisputeStatusCard({
    super.key,
    required this.dispute,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = dispute.status;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, size: 20, color: status.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dispute Filed',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: status.color),
                ),
                child: Text(
                  status.label.toUpperCase(),
                  style: AppTextStyles.captionMedium.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disputed Amount:',
                style: AppTextStyles.captionMedium.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              Text(
                '₹${dispute.amountInDispute.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dispute.reason,
            style: AppTextStyles.captionMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (dispute.resolution != null && dispute.resolution!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(180),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dispute.resolution!,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                context.push(
                  '/contact_support',
                  extra: {
                    'orderId': orderId ?? dispute.serviceRequestId,
                    'subject': 'Dispute Status Query',
                  },
                );
              },
              child: Text(
                'Questions? Contact Support →',
                style: AppTextStyles.captionMedium.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
