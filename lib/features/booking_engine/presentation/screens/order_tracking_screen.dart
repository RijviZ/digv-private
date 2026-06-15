import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:digv/features/booking_engine/domain/models/tracking_step.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/map_section.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/order_details_card.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/order_progress_card.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/postpaid_warning_banner.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/sheets/chat_sheet.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/sheets/otp_sheet.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/technician_card.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/tracking_app_bar.dart';
import 'package:digv/features/booking_engine/presentation/widgets/order_tracking/tracking_bottom_bars.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/orders/domain/models/order_tracking_data.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';
import 'package:digv/features/orders/presentation/widgets/cancel_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final PaymentType paymentType;
  final OrderItem? order;

  const OrderTrackingScreen({super.key, required this.paymentType, this.order});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  OrderStatus _status = OrderStatus.created;
  late PaymentType _paymentType;
  List<OrderTrackingLog>? _logs;

  Future<void> _makeCall(String phoneNumber) async {
    // Using Uri.parse instead of Uri constructor prevents percent-encoding of the "+" symbol.
    // LaunchMode.externalApplication forces the OS to open the phone's native dialer directly.
    final Uri launchUri = Uri.parse('tel:${phoneNumber.replaceAll(' ', '')}');
    try {
      await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Could not launch phone call: $e');
    }
  }

  String? _findTechnicianPhoneNumber(List<OrderTrackingLog>? logs) {
    if (widget.order?.providerPhoneNumber != null && widget.order!.providerPhoneNumber!.isNotEmpty) {
      return widget.order!.providerPhoneNumber;
    }
    if (logs == null) return null;
    for (final log in logs) {
      if (log.actor != null && log.actor!.phoneNumber.isNotEmpty) {
        if (log.action.contains('PROVIDER') || 
            log.newStatus == 'ON_THE_WAY' || 
            log.newStatus == 'ARRIVED' || 
            log.newStatus == 'WORK_STARTED' || 
            log.newStatus == 'WORK_DONE') {
          return '${log.actor!.countryCode}${log.actor!.phoneNumber}';
        }
      }
    }
    for (final log in logs) {
      if (log.actor != null && 
          log.actor!.phoneNumber.isNotEmpty && 
          log.actor!.phoneNumber != '9876543211') {
        return '${log.actor!.countryCode}${log.actor!.phoneNumber}';
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _paymentType = widget.paymentType;
    if (widget.order != null) {
      final isPostpaid = widget.order!.paymentStatus == 'UNPAID' ||
          widget.order!.price.toLowerCase().contains('postpaid');
      _paymentType = isPostpaid ? PaymentType.postpaid : PaymentType.prepaid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(orderTrackingProvider(widget.order!.id));
      });
    }
  }

  bool get _isPrepaid => _paymentType == PaymentType.prepaid;
  bool get _isCompleted => _status == OrderStatus.completed;

  // Only postpaid can cancel up to workStarted
  bool get _canCancel {
    if (_isPrepaid) return _status != OrderStatus.completed;
    return _status == OrderStatus.onTheWay || _status == OrderStatus.arrived || _status == OrderStatus.assigned || _status == OrderStatus.created;
  }

  void _resolveStatusFromLogs(List<OrderTrackingLog> logs) {
    if (widget.order == null) return;
    
    // 1. Completed
    if (widget.order!.status == OrderBadgeStatus.completed || 
        logs.any((l) => l.newStatus == 'COMPLETED' || l.action == 'COMPLETED' ||
                        l.newStatus == 'OTP_VERIFIED' || l.action == 'OTP_VERIFIED')) {
      _status = OrderStatus.completed;
      return;
    }
    
    // 2. Work Done OTP Needed
    if (logs.any((l) => l.newStatus == 'OTP_REQUIRED' || l.action == 'OTP_REQUIRED' || 
                    l.newStatus == 'WORK_DONE' || l.newStatus == 'WORK_DONE_OTP')) {
      _status = OrderStatus.workDoneOtp;
      return;
    }
    
    // 3. Work Started
    if (logs.any((l) => l.newStatus == 'WORK_STARTED' || l.action == 'WORK_STARTED' ||
                    l.newStatus == 'WORK_PROGRESS_UPDATED' || l.action == 'WORK_PROGRESS_UPDATED')) {
      _status = OrderStatus.workStarted;
      return;
    }
    
    // 4. Arrived
    if (logs.any((l) => l.newStatus == 'ARRIVED' || l.action == 'ARRIVED')) {
      _status = OrderStatus.arrived;
      return;
    }
    
    // 5. On the Way
    if (logs.any((l) => l.newStatus == 'ON_THE_WAY' || l.action == 'ON_THE_WAY')) {
      _status = OrderStatus.onTheWay;
      return;
    }
 
    // 6. Assigned (Technician Assigned)
    if (logs.any((l) => l.newStatus == 'PROVIDER_ASSIGN' || l.action == 'PROVIDER_ASSIGN' ||
                    l.newStatus == 'PROVIDER_ASIGN' || l.action == 'PROVIDER_ASIGN' ||
                    l.newStatus == 'ACCEPTED' || l.action == 'ACCEPTED')) {
      _status = OrderStatus.assigned;
      return;
    }

    // 7. Created
    if (logs.any((l) => l.action == 'CREATED' || l.newStatus == 'PENDING')) {
      _status = OrderStatus.created;
      return;
    }
    
    // Default fallback to the order status
    switch (widget.order!.status) {
      case OrderBadgeStatus.completed:
        _status = OrderStatus.completed;
        break;
      case OrderBadgeStatus.active:
        _status = OrderStatus.assigned;
        break;
      case OrderBadgeStatus.upcoming:
        _status = OrderStatus.created;
        break;
      default:
        _status = OrderStatus.created;
    }
  }

  List<TrackingStep> get _steps {
    final idx = OrderStatus.values.indexOf(_status);
    return [
      TrackingStep(
        title: 'Created',
        subtitle: 'Booking request created',
        isCompleted: true,
        isActive: _status == OrderStatus.created,
      ),
      TrackingStep(
        title: 'Booking Confirmed',
        subtitle: 'Booking is confirmed',
        isCompleted: idx >= 1,
        isActive: false,
      ),
      TrackingStep(
        title: 'Technician Assigned',
        subtitle: widget.order != null ? '${widget.order!.technicianName} is assigned' : 'Arjun Kumar is assigned',
        isCompleted: idx >= 1,
        isActive: _status == OrderStatus.assigned,
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
        subtitleColor: AppColors.alertText,
        isCompleted: idx >= 5,
        isActive: idx == 5,
        actionLabel: 'View OTP Code',
        actionLabelColor: AppColors.alertText,
        actionBackgroundColor: AppColors.alertBg,
        actionBorderColor: AppColors.alertBorder,
        onAction: idx == 5 ? _showOtpSheet : null,
      ),
      TrackingStep(
        title: 'Completed',
        isCompleted: idx >= 6,
        isActive: idx == 6,
      ),
    ];
  }

  void _showCancelDialog() {
    if (widget.order == null) return;
    CancelBottomSheet.show(
      context,
      widget.order!,
      onCancelSuccess: () {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) {
              context.go('/orders');
            }
          });
        }
      },
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
          _logs = trackingData.logs;
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
                orderId: widget.order?.orderId ?? 'ORD-7845',
              ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (widget.order != null) {
                  ref.invalidate(orderTrackingProvider(widget.order!.id));
                  try {
                    await ref.read(orderTrackingProvider(widget.order!.id).future);
                  } catch (_) {}
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const MapSection(),
                    const SizedBox(height: 20,),
                    TechnicianCard(
                      paymentType: _paymentType,
                      order: widget.order,
                      onChat: _showChatSheet,
                      onCall: () {
                        final phone = _findTechnicianPhoneNumber(_logs) ?? '+919876543210';
                        _makeCall(phone);
                      },
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
                      PostpaidWarningBanner(price: widget.order?.price ?? '₹500'),
                    ],
                    const SizedBox(height: 96),
                  ],
                ),
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
                  'serviceName': widget.order?.serviceName ?? 'AC Regular Service',
                  'technicianName': widget.order?.technicianName ?? 'Arjun Kumar',
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
