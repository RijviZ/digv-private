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
import 'package:flutter_svg/flutter_svg.dart';

class OrderTrackingScreen extends StatefulWidget {
  final PaymentType paymentType;

  const OrderTrackingScreen({super.key, required this.paymentType});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderStatus _status = OrderStatus.onTheWay;
  late PaymentType _paymentType;

  @override
  void initState() {
    super.initState();
    _paymentType = widget.paymentType;
  }

  bool get _isPrepaid => _paymentType == PaymentType.prepaid;
  bool get _isCompleted => _status == OrderStatus.completed;
  bool get _isOtpStage => _status == OrderStatus.workDoneOtp;

  // Only postpaid can cancel up to workStarted
  bool get _canCancel {
    if (_isPrepaid) return _status != OrderStatus.completed;
    return _status == OrderStatus.onTheWay || _status == OrderStatus.arrived;
  }

  List<TrackingStep> get _steps {
    final idx = OrderStatus.values.indexOf(_status);
    return [
      TrackingStep(
        title: 'Booking Confirmed',
        subtitle: 'Payment received',
        isCompleted: idx >= 0,
        isActive: idx == 0,
      ),
      TrackingStep(
        title: 'Technician Assigned',
        subtitle: 'Arjun Kumar is assigned',
        isCompleted: idx >= 1,
        isActive: idx == 1,
      ),
      TrackingStep(
        title: 'On the Way',
        subtitle: 'ETA 12 minutes',
        isCompleted: idx >= 2,
        isActive: idx == 2,
      ),
      TrackingStep(
        title: 'Arrived',
        isCompleted: idx >= 3,
        isActive: idx == 3,
      ),
      TrackingStep(
        title: 'Work Started',
        isCompleted: idx >= 4,
        isActive: idx == 4,
      ),
      TrackingStep(
        title: 'Work Done — OTP Needed',
        subtitle: 'Share OTP with technician',
        isCompleted: idx >= 5,
        isActive: idx == 5,
      ),
      TrackingStep(
        title: 'Completed',
        isCompleted: _isCompleted,
        isActive: _isCompleted,
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
      builder: (_) => const ChatSheet(),
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

  // Dev helper: cycle through statuses
  void _nextStatus() {
    const values = OrderStatus.values;
    final next = (values.indexOf(_status) + 1) % values.length;
    setState(() => _status = values[next]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          SafeArea(
              bottom: false,
              child: TrackingAppBar(
                statusLabel: _status.label,
                onNext: _nextStatus, // Remove in production
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
                  OrderDetailsCard(paymentType: _paymentType),
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
            onPressed: (){},
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
                const Text(
                  'Rate Service',
                  style: AppTextStyles.button,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // OTP stage (postpaid): View OTP Code + disabled Cancel
    if (_isOtpStage && !_isPrepaid) {
      return BottomBarDual(
        primary: 'View OTP Code',
        onPrimary: _showOtpSheet,
        secondary: 'Cancel Booking',
        onSecondary: null, // disabled
      );
    }

    // Can cancel
    if (_canCancel) {
      return BottomBarSingle(
        label: 'Cancel Booking',
        onTap: _showCancelDialog,
        dark: true,
      );
    }

    // Work started and beyond (postpaid) — cancel disabled
    return const BottomBarSingle(
      label: 'Cancel Booking',
      onTap: null,
      dark: false,
    );
  }
}
