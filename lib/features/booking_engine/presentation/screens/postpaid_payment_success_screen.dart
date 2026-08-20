import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';
import 'package:digv/core/network/file_upload_service.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';

class PostpaidPaymentSuccessScreen extends ConsumerStatefulWidget {
  final String serviceRequestId;
  final OrderItem? initialOrder;

  const PostpaidPaymentSuccessScreen({
    super.key,
    required this.serviceRequestId,
    this.initialOrder,
  });

  @override
  ConsumerState<PostpaidPaymentSuccessScreen> createState() =>
      _PostpaidPaymentSuccessScreenState();
}

class _PostpaidPaymentSuccessScreenState
    extends ConsumerState<PostpaidPaymentSuccessScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _photos = [];
  bool _isUploadingPhoto = false;
  bool _isSubmitting = false;
  bool _isLoadingReview = true;
  String? _existingReviewId;
  OrderItem? _resolvedOrder;

  @override
  void initState() {
    super.initState();
    _resolvedOrder = widget.initialOrder;
    _fetchExistingReview();
  }

  Future<void> _fetchExistingReview() async {
    try {
      final repository = ref.read(ordersRepositoryProvider);

      if (_resolvedOrder == null) {
        try {
          final orders = await repository.getServiceRequests();
          for (final order in orders) {
            if (order.id == widget.serviceRequestId ||
                order.orderId == widget.serviceRequestId ||
                order.orderId.replaceAll(' ', '') ==
                    widget.serviceRequestId.replaceAll(' ', '')) {
              if (mounted) {
                setState(() {
                  _resolvedOrder = order;
                });
              }
              break;
            }
          }
        } catch (_) {}
      }

      final effectiveId = _resolvedOrder?.id ?? widget.serviceRequestId;

      final review = await repository.getGivenReviewByServiceRequestId(
        serviceRequestId: effectiveId,
      );
      if (review != null && mounted) {
        setState(() {
          _existingReviewId = review['id'] as String?;
          _rating = review['rating'] as int? ?? 0;
          _reviewController.text = review['comment'] as String? ?? '';
          _photos.clear();
          if (review['photos'] != null) {
            _photos.addAll(List<String>.from(review['photos'] as List));
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReview = false;
        });
      }
    }
  }

  OrderItem? _findOrder() {
    if (_resolvedOrder != null) return _resolvedOrder;
    for (final status in [null, 'ACTIVE', 'PAST', 'UPCOMING', 'CANCELLED']) {
      try {
        final ordersAsync = ref.read(ordersProvider(status));
        if (ordersAsync is AsyncData<List<OrderItem>>) {
          for (final order in ordersAsync.value) {
            if (order.id == widget.serviceRequestId ||
                order.orderId == widget.serviceRequestId ||
                order.orderId.replaceAll(' ', '') ==
                    widget.serviceRequestId.replaceAll(' ', '')) {
              return order;
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  void _onRatingChanged(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_photos.length >= 4) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        final url = await ref
            .read(fileUploadServiceProvider)
            .uploadFile(pickedFile.path, category: 'reviews');
        setState(() {
          _photos.add(url);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
        }
      } finally {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _onSubmitReview() async {
    if (_rating == 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final repository = ref.read(ordersRepositoryProvider);

      final tags = <String>[];
      if (_rating >= 4) {
        tags.addAll(['Friendly', 'Cooperative', 'Good Behaviour']);
      } else if (_rating >= 3) {
        tags.addAll(['Punctual', 'Average Experience']);
      } else {
        tags.addAll(['Late', 'Poor Communication']);
      }

      final effectiveId = _resolvedOrder?.id ?? widget.serviceRequestId;

      if (_existingReviewId != null) {
        await repository.updateReview(
          id: _existingReviewId!,
          rating: _rating,
          comment: _reviewController.text.trim(),
          tags: tags,
          photos: _photos,
        );
      } else {
        await repository.submitReview(
          serviceRequestId: effectiveId,
          targetType: 'PROVIDER',
          rating: _rating,
          comment: _reviewController.text.trim(),
          tags: tags,
          photos: _photos,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingReviewId != null
                  ? 'Review updated successfully!'
                  : 'Review submitted successfully!',
            ),
            backgroundColor: AppColors.successText,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        } else if (responseData != null) {
          errorMessage = responseData.toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save review: $errorMessage'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch all statuses unconditionally so the screen rebuilds when the data finishes loading from server
    ref.watch(ordersProvider(null));
    ref.watch(ordersProvider('ACTIVE'));
    ref.watch(ordersProvider('PAST'));
    ref.watch(ordersProvider('UPCOMING'));
    ref.watch(ordersProvider('CANCELLED'));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),

            Expanded(
              child: _isLoadingReview
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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

                          const SizedBox(
                            height: 44,
                          ), // Buffer for bottom buttons
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/images/CaretLeft.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Rate Your Experience',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLight.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianInfo() {
    final order = _findOrder();
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.inputBgSecondaryDark
                : AppColors.inputBgSecondary,
            border: Border.all(color: Theme.of(context).dividerColor, width: 2.16),
            image: order?.technicianImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(order!.technicianImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: order?.technicianImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 36,
                  color: Theme.of(context).colorScheme.secondary,
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          order?.technicianName ?? 'Arjun Kumar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontFamily: AppTextStyles.fontFamily,
            fontWeight: FontWeight.w500,
            height: 1.75,
          ),
        ),
        const SizedBox(height: 4),
        Builder(
          builder: (context) {
            final rating = order?.rating ?? 0.0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final isFilled = index < rating.floor();
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SvgPicture.asset(
                        isFilled
                            ? 'assets/images/star.svg'
                            : 'assets/images/star_edge.svg',
                        width: 13,
                        height: 13,
                        colorFilter: const ColorFilter.mode(
                          AppColors.star,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 6),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${order?.reviews ?? 0} reviews)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            );
          },
        ),
        Text(
          order?.serviceName ?? 'AC Regular Service',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
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
          side: const BorderSide(
            width: 1,
            color: AppColors.inputBorderSecondary,
          ),
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
              isFilled
                  ? 'assets/images/star.svg'
                  : 'assets/images/star_edge.svg',
              width: 40,
              height: 40,
              colorFilter: isFilled
                  ? const ColorFilter.mode(AppColors.star, BlendMode.srcIn)
                  : ColorFilter.mode(
                      Theme.of(context).dividerColor,
                      BlendMode.srcIn,
                    ),
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
        Text(
          'Write a review (optional)',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.inputBgSecondaryDark
                : AppColors.inputBgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 3,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              height: 1.50,
            ),
            decoration: InputDecoration(
              hintText: 'Share your experience to help others...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 14,
                fontFamily: AppTextStyles.fontFamilyPoppins,
              ),
              contentPadding: const EdgeInsets.all(14),
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
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(optional · up to 4)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 11,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            ..._photos.map(
              (url) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.remove(url)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_photos.length < 4)
              GestureDetector(
                onTap: _pickAndUploadPhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1.08,
                    ),
                  ),
                  child: _isUploadingPhoto
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/photo.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 10,
                                fontFamily: AppTextStyles.fontFamilyPoppins,
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add photos of the completed work to help future customers',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Submit / Rate Button
          InkWell(
            onTap: _rating > 0 && !_isSubmitting ? _onSubmitReview : null,
            child: Opacity(
              opacity: _rating > 0 && !_isSubmitting ? 1.0 : 0.5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: _isSubmitting
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _rating > 0
                            ? (_existingReviewId != null
                                  ? 'Update Review'
                                  : 'Submit Review')
                            : 'Tap a star to rate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
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
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'Remind me later',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
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
