import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:digv/features/booking_engine/domain/models/tracking_step.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/map_section.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/order_details_card.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/order_progress_card.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/postpaid_warning_banner.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/sheets/cancel_booking_sheet.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/sheets/chat_sheet.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/sheets/otp_sheet.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/technician_card.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/tracking_app_bar.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/tracking_bottom_bars.dart';
import 'package:flutter/material.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';
import 'package:digv/features/orders/domain/models/order_tracking_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final PaymentType paymentType;
  final OrderItem? order;

  const OrderTrackingScreen({super.key, required this.paymentType, this.order});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  OrderStatus _status = OrderStatus.onTheWay;
  late PaymentType _paymentType;

  @override
  void initState() {
    super.initState();
    _paymentType = widget.paymentType;
  }

  bool get _isPrepaid => _paymentType == PaymentType.prepaid;
  bool get _isCompleted => _status == OrderStatus.completed;

  // Only postpaid can cancel up to workStarted
  bool get _canCancel {
    if (_isPrepaid) return _status != OrderStatus.completed;
    return _status == OrderStatus.onTheWay || _status == OrderStatus.arrived;
  }

  void _resolveStatusFromLogs(List<OrderTrackingLog> logs) {
    if (widget.order == null) return;
    
    // Check if any log is COMPLETED or if the order badge status is completed
    if (widget.order!.status == OrderBadgeStatus.completed || 
        logs.any((l) => l.newStatus == 'COMPLETED')) {
      _status = OrderStatus.completed;
      return;
    }
    
    // Check for work done OTP
    if (logs.any((l) => l.newStatus == 'WORK_DONE' || l.newStatus == 'OTP_REQUIRED' || l.newStatus == 'WORK_DONE_OTP')) {
      _status = OrderStatus.workDoneOtp;
      return;
    }
    
    // Check for work started
    if (logs.any((l) => l.newStatus == 'WORK_STARTED')) {
      _status = OrderStatus.workStarted;
      return;
    }
    
    // Check for arrived
    if (logs.any((l) => l.newStatus == 'ARRIVED')) {
      _status = OrderStatus.arrived;
      return;
    }
    
    // Check for on the way
    if (logs.any((l) => l.newStatus == 'ON_THE_WAY')) {
      _status = OrderStatus.onTheWay;
      return;
    }
    
    // Default fallback to the order status
    switch (widget.order!.status) {
      case OrderBadgeStatus.completed:
        _status = OrderStatus.completed;
        break;
      case OrderBadgeStatus.inProgress:
        _status = OrderStatus.workStarted;
        break;
      default:
        _status = OrderStatus.onTheWay;
    }
  }

  List<TrackingStep> get _steps {
    final idx = OrderStatus.values.indexOf(_status);
    return [
      // These 2 steps are always completed before tracking screen opens
      const TrackingStep(
        title: 'Booking Confirmed',
        subtitle: 'Payment received',
        isCompleted: true,
        isActive: false,
      ),
      TrackingStep(
        title: 'Technician Assigned',
        subtitle: widget.order != null ? '${widget.order!.technicianName} is assigned' : 'Arjun Kumar is assigned',
        isCompleted: true,
        isActive: false,
      ),
      // These 5 steps map 1:1 to OrderStatus enum (indices 0–4)
      TrackingStep(
        title: 'On the Way',
        subtitle: 'ETA 12 minutes',
        isCompleted: idx >= 0,
        isActive: idx == 0,
      ),
      TrackingStep(
        title: 'Arrived',
        isCompleted: idx >= 1,
        isActive: idx == 1,
      ),
      TrackingStep(
        title: 'Work Started',
        isCompleted: idx >= 2,
        isActive: idx == 2,
      ),
      TrackingStep(
        title: 'Work Done — OTP Needed',
        subtitle: 'Share OTP with technician',
        subtitleColor: AppColors.alertText,
        isCompleted: idx >= 3,
        isActive: idx == 3,
        actionLabel: 'View OTP Code',
        actionLabelColor: AppColors.alertText,
        actionBackgroundColor: AppColors.alertBg,
        actionBorderColor: AppColors.alertBorder,
        onAction: idx == 3 ? _showOtpSheet : null,
      ),
      TrackingStep(
        title: 'Completed',
        isCompleted: idx >= 4,
        isActive: idx == 4,
      ),
    ];
  }

  void _showCancelDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CancelBookingSheet(
        onConfirm: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showChatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChatSheet(
        peerUserId: widget.order?.providerId ?? 'f9c4a8d7-9e33-4b99-84ab-111111111111',
        peerName: widget.order?.technicianName ?? 'Arjun Kumar',
        peerAvatarUrl: widget.order?.technicianImageUrl,
      ),
    );
  }

  void _showOtpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => OtpSheet(
        onDone: () {
          Navigator.pop(context);
          setState(() => _status = OrderStatus.completed);
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (widget.order != null) {
      final trackingAsync = ref.watch(orderTrackingProvider(widget.order!.id));
      return trackingAsync.when(
        data: (trackingData) {
          _resolveStatusFromLogs(trackingData.logs);
          return _buildContent(context);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load tracking data: $error', style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(orderTrackingProvider(widget.order!.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          SafeArea(
              bottom: false,
              child: TrackingAppBar(
                statusLabel: _status.label,
              ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const MapSection(),
                  const SizedBox(height: 20,),
                  TechnicianCard(
                    paymentType: _paymentType,
                    order: widget.order,
                    onChat: _showChatSheet,
                    onTogglePayment: () => setState(() {
                      _paymentType = _isPrepaid
                          ? PaymentType.postpaid
                          : PaymentType.prepaid;
                    }),
                  ),
                  const SizedBox(height: 20),
                  OrderProgressCard(steps: _steps),
                  const SizedBox(height: 10),
                  OrderDetailsCard(
                    paymentType: _paymentType,
                    order: widget.order,
                  ),
                  if (!_isPrepaid) ...[
                    const SizedBox(height: 10),
                    const PostpaidWarningBanner(),
                  ],
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomBar()),
    );
  }

  Widget _buildBottomBar() {
    // Completed — postpaid shows Pay & Rate, prepaid shows Rate Service
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .surface,
          border: const Border(top: BorderSide(color: AppColors.dropDownBorder)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (!_isPrepaid) {
                int dueAmount = 500;
                if (widget.order?.price != null) {
                  final rawPrice = widget.order!.price.replaceAll(RegExp(r'\D'), '');
                  dueAmount = int.tryParse(rawPrice) ?? 500;
                }
                context.push('/postpaid_payment', extra: {
                  'serviceRequestId': widget.order?.id ?? 'f9c4a8d7-9e33-4b99-84ab-111111111111',
                  'amount': dueAmount,
                  'isRemainingPayment': true,
                });
              } else {
                context.push('/postpaid_payment_success', extra: widget.order?.id ?? 'f9c4a8d7-9e33-4b99-84ab-111111111111');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                    'assets/images/star_edge.svg',
                    height: 24,
                    width: 24,
                ),  
                const SizedBox(width: 10),
                Text(
                  _isPrepaid ? 'Rate Service' : 'Pay & Rate Service',
                  style: AppTextStyles.button,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Can cancel (postpaid: only onTheWay/arrived; prepaid: up to before completed)
    if (_canCancel) {
      return BottomBarSingle(
        label: 'Cancel Booking',
        onTap: _showCancelDialog,
        dark: true,
      );
    }

    // Work started / OTP and beyond — cancel disabled
    return const BottomBarSingle(
      label: 'Cancel Booking',
      onTap: null,
      dark: false,
    );
  }
}
