import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../features/booking_engine/domain/technician.dart';
import '../theme/app_colors.dart';

class TechnicianCard extends StatelessWidget {
  final Technician technician;
 
  const TechnicianCard({super.key, required this.technician});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.dropDownBorder, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildFooterRow(),
        ],
      ),
    );
  }
 
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technician.name,
                          style: AppTextStyles.bodyMediumBold.copyWith(color: Theme.of(context).colorScheme.primary)
                        ),
                        const SizedBox(height: 2),
                        Text(
                          technician.specialty,
                          style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary, height: 1.75),
                        ),
                        const SizedBox(height: 6),

                      ],
                    ),
                  ),
                  if (technician.isTopRated) ...[
                    const SizedBox(width: 8),
                    _buildTopRatedBadge(),
                  ],
                ],
              ),
              _buildStatsRow(context),
            ],
          ),
        ),
        
      ],
    );
  }
 
  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFC8CDD4),
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _AvatarPainter(),
        ),
      ),
    );
  }
 
  Widget _buildTopRatedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Top Rated',
        style: AppTextStyles.captionSmall.copyWith(color: AppColors.warningText)
      ),
    );
  }
 
  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
         SizedBox(
           height: 11,
             width: 11,
             child: SvgPicture.asset('assets/images/star.svg')),
        const SizedBox(width: 3),
        Text(
          technician.rating.toStringAsFixed(1),
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary
          ),),
        const SizedBox(width: 2),
        Text(
          '(${technician.reviews})',
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.secondary
          ),
        ),
        const SizedBox(width: 10),
        // Jobs
        SizedBox(
            height: 11,
            width: 11,
            child: SvgPicture.asset('assets/images/briefcase.svg')),
        const SizedBox(width: 3),
        Text(
          '${technician.jobs} jobs',
          style: AppTextStyles.caption.copyWith(
    color: Theme.of(context).colorScheme.secondary
    ),
        ),
        const SizedBox(width: 10),
        // Experience
        const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          '${technician.experience} yrs',
            style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.secondary
            ),
        ),
      ],
    );
  }
 
  Widget _buildFooterRow() {
    return Row(
      children: [
        _buildPriceTag(),
        const SizedBox(width: 10),
        _buildDistanceTag(),
      ],
    );
  }
 
  Widget _buildPriceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.inputBorderSecondary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SvgPicture.asset('assets/images/rupee.svg'),
          const SizedBox(width: 1),
          Text(
            '${technician.pricePerVisit}',
            style: AppTextStyles.captionLarge.copyWith(
              color: AppColors.blue,
              fontWeight: FontWeight.w800
            ),),
           Text(
            '/visit',
            style: AppTextStyles.captionSmall.copyWith(color: AppColors.dropDownBorder)
          ),
        ],
      ),
    );
  }
 
  Widget _buildDistanceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.successBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/pin_g.svg'),
          const SizedBox(width: 4),
          Text(
            '${technician.distanceKm} km · ${technician.distanceLabel}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.successText,
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildReviewsRow() {
    final fullStars = technician.rating.floor();
    return Row(
      children: [
        ...List.generate(5, (i) => Icon(
          i < fullStars ? Icons.star_rounded : Icons.star_rounded,
          size: 14,
          color: i < fullStars ? const Color(0xFFF59E0B) : const Color(0xFFDDDDDD),
        )),
        const SizedBox(width: 6),
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 11, color: Color(0xFF555555)),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 14, color: Color(0xFFAAAAAA)),
      ],
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFF8A9099);
    final bgPaint = Paint()..color = const Color(0xFFC8CDD4);

    // Background
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Head
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.38),
      size.width * 0.17,
      bodyPaint,
    );

    // Body / shoulders
    final bodyRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.87),
      width: size.width * 0.6,
      height: size.height * 0.4,
    );
    canvas.drawOval(bodyRect, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
