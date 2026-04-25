import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class PostpaidPaymentSuccessScreen extends StatefulWidget {
  const PostpaidPaymentSuccessScreen({super.key});

  @override
  State<PostpaidPaymentSuccessScreen> createState() => _PostpaidPaymentSuccessScreenState();
}

class _PostpaidPaymentSuccessScreenState extends State<PostpaidPaymentSuccessScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _photos = [];

  void _onRatingChanged(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Technician Info
                    _buildTechnicianInfo(),
                    
                    const SizedBox(height: 16),
                    // Rating Info Box
                    _buildRatingInfoBox(),
                    
                    const SizedBox(height: 24),
                    // Star Rating
                    _buildStarRating(),
                    
                    const SizedBox(height: 28),
                    // Review Section
                    _buildReviewSection(),
                    
                    const SizedBox(height: 24),
                    // Photo Section
                    _buildPhotoSection(),
                    
                    const SizedBox(height: 44), // Buffer for bottom buttons
                  ],
                ),
              ),
            ),
            
            // Bottom Action Buttons
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/images/CaretLeft.svg',
                  colorFilter: const ColorFilter.mode(AppColors.onLight, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const Text(
            'Rate Your Experience',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLight,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianInfo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.inputBorder, width: 2.16),
            image: const DecorationImage(
              image: NetworkImage("https://placehold.co/72x72"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Arjun Kumar',
          style: TextStyle(
            color: AppColors.onLight,
            fontSize: 18,
            fontFamily: AppTextStyles.fontFamily,
            fontWeight: FontWeight.w500,
            height: 1.75,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SvgPicture.asset(
                    'assets/images/star.svg',
                    width: 13,
                    height: 13,
                    colorFilter: const ColorFilter.mode(AppColors.star, BlendMode.srcIn),
                  ),
                );
              }),
            ),
            const SizedBox(width: 6),
            const Text(
              '4.9',
              style: TextStyle(
                color: AppColors.onLight,
                fontSize: 12,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '(312 reviews)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
        const Text(
          'AC Regular Service',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.unread,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.inputBorderSecondary),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/CheckCircleG.svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            'Select rating to proceed',
            style: TextStyle(
              color: AppColors.blue,
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final currentRating = index + 1;
        final isFilled = _rating >= currentRating;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => _onRatingChanged(currentRating),
            child: SvgPicture.asset(
              isFilled ? 'assets/images/star.svg' : 'assets/images/star_edge.svg',
              width: 40,
              height: 40,
              colorFilter: isFilled 
                ? const ColorFilter.mode(AppColors.star, BlendMode.srcIn)
                : const ColorFilter.mode(AppColors.dropDownBorder, BlendMode.srcIn),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write a review (optional)',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 3,
            style: const TextStyle(
              color: AppColors.onLight,
              fontSize: 14,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              height: 1.50,
            ),
            decoration: const InputDecoration(
              hintText: 'Share your experience to help others...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: AppTextStyles.fontFamilyPoppins,
              ),
              contentPadding: EdgeInsets.all(14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/camera.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(AppColors.textDark, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Add Photos',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(optional · up to 4)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
            Text(
              '${_photos.length}/4',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        // Add Photo Card
        if (_photos.length < 4)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder, width: 1.08),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/photo.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Add photos of the completed work to help future customers',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.dropDownBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Submit / Rate Button
          InkWell(
            onTap: _rating > 0 ? () => context.go('/home') : null,
            child: Opacity(
              opacity: _rating > 0 ? 1.0 : 0.5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.onLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _rating > 0 ? 'Submit Review' : 'Tap a star to rate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.onDark,
                    fontSize: 16,
                    fontFamily: AppTextStyles.fontFamily,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Remind Later Button
          InkWell(
            onTap: () => context.go('/home'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.dropDownBorder),
              ),
              child: const Text(
                'Remind me later',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onLight,
                  fontSize: 16,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
