import 'dart:async';

import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/utils/snackbar_utils.dart';
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
import 'package:digv/features/disputes/presentation/providers/disputes_provider.dart';
import 'package:digv/features/disputes/presentation/widgets/dispute_status_card.dart';
import 'package:digv/features/disputes/presentation/widgets/raise_dispute_bottom_sheet.dart';
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
  final String? serviceRequestId;

  const OrderTrackingScreen({
    super.key,
    required this.paymentType,
    this.order,
    this.serviceRequestId,
  });

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  OrderStatus _status = OrderStatus.created;
  late PaymentType _paymentType;
  List<OrderTrackingLog>? _logs;
  OrderItem? _resolvedOrder;
  bool _initializedWithResolvedOrder = false;
  bool _userConfirmedOtp = false;
  Timer? _refreshTimer;
  String? _serverOtp;

  String get _resolvedOtp {
    if (_serverOtp != null && _serverOtp!.isNotEmpty) return _serverOtp!;
    if (_order?.otp != null && _order!.otp!.isNotEmpty) return _order!.otp!;
    if (_logs != null) {
      for (final log in _logs!) {
        if (log.action.contains('OTP') || log.note.contains('OTP')) {
          final match = RegExp(r'\b\d{6}\b').firstMatch(log.note);
          if (match != null) return match.group(0)!;
        }
      }
    }
    return '123456';
  }

  OrderItem? get _order => widget.order ?? _resolvedOrder;

  Future<void> _makeCall(String phoneNumber) async {
    // Using Uri.parse instead of Uri constructor prevents percent-encoding of the "+" symbol.
    // LaunchMode.externalApplication forces the OS to open the phone's native dialer directly.
    final Uri launchUri = Uri.parse('tel:${phoneNumber.replaceAll(' ', '')}');
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch phone call: $e');
    }
  }

  String? _findTechnicianPhoneNumber(List<OrderTrackingLog>? logs) {
    if (_order?.providerPhoneNumber != null &&
        _order!.providerPhoneNumber!.isNotEmpty) {
      return _order!.providerPhoneNumber;
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
    if (_order != null) {
      final isPostpaid =
          _order!.paymentStatus == 'UNPAID' ||
          _order!.price.toLowerCase().contains('postpaid');
      _paymentType = isPostpaid ? PaymentType.postpaid : PaymentType.prepaid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(orderTrackingProvider(_order!.id));
      });
      _startPolling();
    }
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final currentOrder = _order;
      if (currentOrder != null && mounted) {
        ref.invalidate(orderTrackingProvider(currentOrder.id));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  bool get _isPrepaid => _paymentType == PaymentType.prepaid;
  bool get _isCompleted => _status == OrderStatus.completed;

  // Only postpaid can cancel up to workStarted
  bool get _canCancel {
    if (_isPrepaid) return _status != OrderStatus.completed;
    return _status == OrderStatus.onTheWay ||
        _status == OrderStatus.arrived ||
        _status == OrderStatus.assigned ||
        _status == OrderStatus.created;
  }

  void _resolveStatusFromLogs(List<OrderTrackingLog> logs) {
    if (_order == null) return;

    if (_userConfirmedOtp) {
      _status = OrderStatus.completed;
      return;
    }

    // 1. Completed
    if (_order!.status == OrderBadgeStatus.completed ||
        logs.any(
          (l) =>
              l.newStatus == 'COMPLETED' ||
              l.action == 'COMPLETED' ||
              l.newStatus == 'OTP_VERIFIED' ||
              l.action == 'OTP_VERIFIED',
        )) {
      _status = OrderStatus.completed;
      return;
    }

    // 2. Work Done OTP Needed
    if (logs.any(
      (l) =>
          l.newStatus == 'OTP_REQUIRED' ||
          l.action == 'OTP_REQUIRED' ||
          l.newStatus == 'WORK_DONE' ||
          l.newStatus == 'WORK_DONE_OTP',
    )) {
      _status = OrderStatus.workDoneOtp;
      return;
    }

    // 3. Work Started
    if (logs.any(
      (l) =>
          l.newStatus == 'WORK_STARTED' ||
          l.action == 'WORK_STARTED' ||
          l.newStatus == 'WORK_PROGRESS_UPDATED' ||
          l.action == 'WORK_PROGRESS_UPDATED',
    )) {
      _status = OrderStatus.workStarted;
      return;
    }

    // 4. Arrived
    if (logs.any((l) => l.newStatus == 'ARRIVED' || l.action == 'ARRIVED')) {
      _status = OrderStatus.arrived;
      return;
    }

    // 5. On the Way
    if (logs.any(
      (l) => l.newStatus == 'ON_THE_WAY' || l.action == 'ON_THE_WAY',
    )) {
      _status = OrderStatus.onTheWay;
      return;
    }

    // 6. Assigned (Technician Assigned)
    if (logs.any(
      (l) =>
          l.newStatus == 'PROVIDER_ASSIGN' ||
          l.action == 'PROVIDER_ASSIGN' ||
          l.newStatus == 'PROVIDER_ASIGN' ||
          l.action == 'PROVIDER_ASIGN' ||
          l.newStatus == 'ACCEPTED' ||
          l.action == 'ACCEPTED',
    )) {
      _status = OrderStatus.assigned;
      return;
    }

    // 7. Created
    if (logs.any((l) => l.action == 'CREATED' || l.newStatus == 'PENDING')) {
      _status = OrderStatus.created;
      return;
    }

    // Default fallback to the order status
    switch (_order!.status) {
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
    final l10n = AppLocalizations.of(context)!;

    return [
      TrackingStep(
        title: l10n.step_created,
        subtitle: l10n.step_created_sub,
        isCompleted: true,
        isActive: _status == OrderStatus.created,
      ),
      TrackingStep(
        title: l10n.step_booking_confirmed,
        subtitle: l10n.step_booking_confirmed_sub,
        isCompleted: idx >= 1,
        isActive: false,
      ),
      TrackingStep(
        title: l10n.step_tech_assigned,
        subtitle: _order != null
            ? '${_order!.technicianName} is assigned'
            : 'Arjun Kumar is assigned',
        isCompleted: idx >= 1,
        isActive: _status == OrderStatus.assigned,
      ),
      TrackingStep(
        title: l10n.step_on_the_way,
        subtitle: 'ETA 12 minutes',
        isCompleted: idx >= 2,
        isActive: idx == 2,
      ),
      TrackingStep(title: l10n.step_arrived, isCompleted: idx >= 3, isActive: idx == 3),
      TrackingStep(
        title: l10n.step_work_started,
        isCompleted: idx >= 4,
        isActive: idx == 4,
      ),
      TrackingStep(
        title: l10n.step_work_done_otp,
        subtitle: l10n.share_otp_technician,
        subtitleColor: AppColors.alertText,
        isCompleted: idx >= 5,
        isActive: idx == 5,
        actionLabel: l10n.view_otp_code,
        actionLabelColor: AppColors.alertText,
        actionBackgroundColor: AppColors.alertBg,
        actionBorderColor: AppColors.alertBorder,
        onAction: idx == 5 ? _showOtpSheet : null,
      ),
      TrackingStep(
        title: l10n.step_completed,
        isCompleted: idx >= 6,
        isActive: idx == 6,
      ),
    ];
  }

  void _showCancelDialog() {
    if (_order == null) return;
    CancelBottomSheet.show(
      context,
      _order!,
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

  void _showDisputeDialog() {
    final currentOrder = _order;
    if (currentOrder == null) return;

    final existingDisputes =
        ref.read(disputesForOrderProvider(currentOrder.id)).value ?? [];
    if (existingDisputes.isNotEmpty) {
      SnackBarUtils.showSuccess(
        context,
        'A dispute is already active for this order (#${existingDisputes.first.displayDisputeNo}).',
      );
      return;
    }

    RaiseDisputeBottomSheet.show(
      context,
      order: currentOrder,
      onDisputeSubmitted: () {
        ref.invalidate(disputesForOrderProvider(currentOrder.id));
        ref.invalidate(myDisputesProvider);
      },
    );
  }

  void _contactSupport() {
    context.push(
      '/contact_support',
      extra: {
        'orderId': _order?.orderId,
        'subject': 'Service Issue',
      },
    );
  }

  void _showChatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChatSheet(
        peerUserId:
            _order?.providerId ?? 'f9c4a8d7-9e33-4b99-84ab-111111111111',
        peerName: _order?.technicianName ?? 'Arjun Kumar',
        peerAvatarUrl: _order?.technicianImageUrl,
      ),
    );
  }

  void _showOtpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => OtpSheet(
        serviceName: _order?.serviceName,
        technicianName: _order?.technicianName,
        otp: _resolvedOtp,
        onDone: () {
          Navigator.pop(context);
          setState(() {
            _userConfirmedOtp = true;
            _status = OrderStatus.completed;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentOrder = widget.order ?? _resolvedOrder;

    if (currentOrder == null && widget.serviceRequestId != null) {
      final orderAsync = ref.watch(orderItemProvider(widget.serviceRequestId!));
      return orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Scaffold(body: Center(child: Text('Order not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_initializedWithResolvedOrder) {
              setState(() {
                _resolvedOrder = order;
                final isPostpaid =
                    order.paymentStatus == 'UNPAID' ||
                    order.price.toLowerCase().contains('postpaid');
                _paymentType = isPostpaid
                    ? PaymentType.postpaid
                    : PaymentType.prepaid;
                ref.invalidate(orderTrackingProvider(order.id));
                _initializedWithResolvedOrder = true;
                _startPolling();
              });
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, st) =>
            Scaffold(body: Center(child: Text('Error loading order: $err'))),
      );
    }

    if (currentOrder != null) {
      final trackingAsync = ref.watch(orderTrackingProvider(currentOrder.id));
      return trackingAsync.when(
        data: (trackingData) {
          _logs = trackingData.logs;
          _serverOtp = trackingData.otp;
          _resolveStatusFromLogs(trackingData.logs);
          return _buildContent(context);
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load tracking data: $error',
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(orderTrackingProvider(currentOrder.id)),
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
              orderId: _order?.orderId ?? 'ORD-7845',
              onDispute: _order != null ? _showDisputeDialog : null,
              onSupport: _contactSupport,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_order != null) {
                  ref.invalidate(orderTrackingProvider(_order!.id));
                  ref.invalidate(disputesForOrderProvider(_order!.id));
                  try {
                    await ref.read(orderTrackingProvider(_order!.id).future);
                  } catch (_) {}
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const MapSection(),
                    const SizedBox(height: 20),
                    TechnicianCard(
                      paymentType: _paymentType,
                      order: _order,
                      onChat: _showChatSheet,
                      onCall: () {
                        final phone =
                            _findTechnicianPhoneNumber(_logs) ??
                            '+919876543210';
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
                    OrderDetailsCard(paymentType: _paymentType, order: _order),
                    if (_order != null) ...[
                      Consumer(
                        builder: (context, ref, child) {
                          final disputesAsync =
                              ref.watch(disputesForOrderProvider(_order!.id));
                          return disputesAsync.when(
                            data: (disputes) {
                              if (disputes.isNotEmpty) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    DisputeStatusCard(
                                      dispute: disputes.first,
                                      orderId: _order?.orderId,
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  const SizedBox(height: 12),
                                  _buildDisputeHelpCard(),
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (error, _) => Column(
                              children: [
                                const SizedBox(height: 12),
                                _buildDisputeHelpCard(),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    if (!_isPrepaid) ...[
                      const SizedBox(height: 10),
                      PostpaidWarningBanner(price: _order?.price ?? '₹500'),
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
          color: Theme.of(context).colorScheme.surface,
          border: const Border(
            top: BorderSide(color: AppColors.dropDownBorder),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (!_isPrepaid) {
                int dueAmount = 500;
                if (_order?.price != null) {
                  final rawPrice = _order!.price.replaceAll(RegExp(r'\D'), '');
                  dueAmount = int.tryParse(rawPrice) ?? 500;
                }
                context.push(
                  '/postpaid_payment',
                  extra: {
                    'serviceRequestId':
                        _order?.id ?? 'f9c4a8d7-9e33-4b99-84ab-111111111111',
                    'amount': dueAmount,
                    'isRemainingPayment': true,
                    'serviceName': _order?.serviceName ?? 'AC Regular Service',
                    'technicianName': _order?.technicianName ?? 'Arjun Kumar',
                  },
                );
              } else {
                context.push(
                  '/postpaid_payment_success',
                  extra: _order?.id ?? 'f9c4a8d7-9e33-4b99-84ab-111111111111',
                );
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
      return BottomBarDual(
        primary: 'Cancel Booking',
        onPrimary: _showCancelDialog,
        secondary: 'Raise Dispute',
        onSecondary: _showDisputeDialog,
      );
    }

    // Work started / OTP and beyond — cancel restricted, offer Dispute
    return BottomBarDual(
      primary: 'Raise Dispute',
      onPrimary: _showDisputeDialog,
      secondary: 'Cancel Booking',
      onSecondary: _showCancelDialog,
    );
  }

  Widget _buildDisputeHelpCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.alertBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.alertBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.gavel_outlined,
            size: 20,
            color: AppColors.alertText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issue with your service?',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.alertText,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'If the service is unsatisfactory or cannot be cancelled, you can open a dispute.',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.alertText.withAlpha(200),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showDisputeDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Dispute',
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.alertText,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
