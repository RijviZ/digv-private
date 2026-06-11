import 'package:digv/features/address/domain/entities/address.dart';
import 'package:digv/features/address/presentation/screens/add_address_screen.dart';
import 'package:digv/features/auth/presentation/screens/login_screen.dart';
import 'package:digv/features/auth/presentation/screens/otp_screen.dart';
import 'package:digv/features/auth/presentation/screens/splash_screen.dart';
import 'package:digv/features/booking_engine/domain/date_item.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:digv/features/booking_engine/domain/technician.dart';
import 'package:digv/features/booking_engine/presentation/screens/booking_confirmed_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/booking_requested_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/order_tracking_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/payment_gateway_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/payment_type_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/postpaid_payment_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/postpaid_payment_success_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/review_booking_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/select_date_and_time_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/select_technician_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/service_details_screen.dart';
import 'package:digv/features/more/presentation/screens/app_settings_screen.dart';
import 'package:digv/features/more/presentation/screens/contact_support_screen.dart';
import 'package:digv/features/more/presentation/screens/edit_profile_screen.dart';
import 'package:digv/features/more/presentation/screens/faqs_screen.dart';
import 'package:digv/features/more/presentation/screens/help_center_screen.dart';
import 'package:digv/features/more/presentation/screens/manage_addresses_screen.dart';
import 'package:digv/features/more/presentation/screens/notification_settings_screen.dart';
import 'package:digv/features/more/presentation/screens/payment_methods_screen.dart';
import 'package:digv/features/notifications/presentation/screens/notification_screen.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/profile_settings/presentation/screens/enable_location_access_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_more_details_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_personal_details_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_welcome_screen.dart';
import 'package:digv/features/shell/presentation/main_shell.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking_engine/presentation/screens/review_and_pay_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // ── Shell routes — all three tabs live inside MainShell ──────────────
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShell(initialTab: kHomeTab),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const MainShell(initialTab: kOrdersTab),
    ),
    // Legacy alias so any existing context.push('/my_orders') still works
    GoRoute(
      path: '/my_orders',
      builder: (context, state) => const MainShell(initialTab: kOrdersTab),
    ),
    GoRoute(
      path: '/more',
      builder: (context, state) => const MainShell(initialTab: kMoreTab),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/edit_profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/manage_addresses',
      builder: (context, state) => const ManageAddressesScreen(),
    ),
    GoRoute(
      path: '/payment_methods',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/notification_settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/app_settings',
      builder: (context, state) => const AppSettingsScreen(),
    ),
    GoRoute(
      path: '/help_center',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/faqs',
      builder: (context, state) => const FaqsScreen(),
    ),
    GoRoute(
      path: '/contact_support',
      builder: (context, state) => const ContactSupportScreen(),
    ),
    GoRoute(
      path: '/service_details',
      builder: (context, state) {
        final serviceItemId = state.extra as String;
        return ServiceDetailsScreen(serviceItemId: serviceItemId);
      },
    ),
    GoRoute(
      path: '/select_technician',
      builder: (context, state) {
        final (serviceItemId, quantity) = state.extra as (String, int);
        return SelectTechnicianScreen(serviceItemId: serviceItemId, quantity: quantity);
      },
    ),
    GoRoute(
      path: '/select_date_and_time',
      builder: (context, state) {
        if (state.extra is (SearchServiceEntity, Technician, int)) {
          final (service, technician, quantity) = state.extra as (SearchServiceEntity, Technician, int);
          return SelectDateTimeScreen(service: service, technician: technician, quantity: quantity);
        }
        final (service, technician) = state.extra as (SearchServiceEntity, Technician);
        return SelectDateTimeScreen(service: service, technician: technician, quantity: 1);
      },
    ),
    GoRoute(
      path: '/review_booking',
      builder: (context, state) {
        if (state.extra is (SearchServiceEntity, Technician, DateItem, String, int)) {
          final (service, technician, date, time, quantity) = state.extra as (SearchServiceEntity, Technician, DateItem, String, int);
          return ReviewBookingScreen(
            service: service,
            technician: technician,
            selectedDate: date,
            selectedTime: time,
            quantity: quantity,
          );
        }
        final (service, technician, date, time) = state.extra as (SearchServiceEntity, Technician, DateItem, String);
        return ReviewBookingScreen(
          service: service,
          technician: technician,
          selectedDate: date,
          selectedTime: time,
          quantity: 1,
        );
      },
    ),
    GoRoute(
      path: '/review_and_pay',
      builder: (context, state) {
        final (service, technician, date, time, quantity, address) = state.extra as (SearchServiceEntity, Technician, DateItem, String, int, Address);
        return ReviewPayScreen(
          service: service,
          technician: technician,
          date: date,
          time: time,
          quantity: quantity,
          address: address,
        );
      },
    ),
    GoRoute(
      path: '/payment_type',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentTypeScreen(
          amount: extra['amount'] as int? ?? 0,
          quantity: extra['quantity'] as int? ?? 1,
          serviceCharge: extra['serviceCharge'] as int? ?? 0,
          fee: extra['fee'] as int? ?? 0,
          bookingDetails: extra,
        );
      },
    ),
    GoRoute(
      path: '/payment_gateway',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentGatewayScreen(bookingDetails: extra);
      },
    ),
    GoRoute(
      path: '/booking_requested',
      builder: (context, state) {
        final order = state.extra as OrderItem?;
        return BookingRequestedScreen(order: order);
      },
    ),
    GoRoute(
      path: '/booking_confirmed',
      builder: (context, state) {
        final paymentType = state.extra as PaymentType? ?? PaymentType.prepaid;
        return BookingConfirmedScreen(paymentType: paymentType);
      },
    ),
    GoRoute(
      path: '/order_tracking',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is PaymentType) {
          return OrderTrackingScreen(paymentType: extra);
        } else if (extra is OrderItem) {
          final order = extra;
          final isPostpaid = order.price.toLowerCase().contains('postpaid') || order.status == OrderBadgeStatus.completed;
          return OrderTrackingScreen(
            paymentType: isPostpaid ? PaymentType.postpaid : PaymentType.prepaid,
            order: order,
          );
        }
        return const OrderTrackingScreen(paymentType: PaymentType.prepaid);
      },
    ),
    GoRoute(
      path: '/postpaid_payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PostpaidPaymentScreen(bookingDetails: extra);
      },
    ),
    GoRoute(
      path: '/postpaid_payment_success',
      builder: (context, state) {
        final serviceRequestId = state.extra as String? ?? 'f9c4a8d7-9e33-4b99-84ab-111111111111';
        return PostpaidPaymentSuccessScreen(serviceRequestId: serviceRequestId);
      },
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/setup_welcome',
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return SetupWelcomeScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/setup_personal_details',
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return SetupPersonalDetailsScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/setup_more_details',
      builder: (context, state) {
        final profileData = state.extra as Map<String, dynamic>? ?? {};
        return SetupMoreDetailsScreen(profileData: profileData);
      },
    ),
    GoRoute(
      path: '/add_address',
      builder: (context, state) {
        final address = state.extra as Address?;
        return AddEditAddressScreen(initialAddress: address);
      },
    ),
    GoRoute(
      path: '/enable_location_access',
      builder: (context, state) {
        return const EnableLocationAccessScreen();
      },
    ),
  ],
);
