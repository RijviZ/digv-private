import 'package:digv/features/auth/presentation/screens/login_screen.dart';
import 'package:digv/features/auth/presentation/screens/otp_screen.dart';
import 'package:digv/features/auth/presentation/screens/splash_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/booking_confirmed_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/booking_requested_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/order_tracking_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/payment_gateway_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/payment_type_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/review_booking_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/select_date_and_time_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/select_technician_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/service_details_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/postpaid_payment_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/postpaid_payment_success_screen.dart';
import 'package:digv/features/shell/presentation/main_shell.dart';
import 'package:digv/features/more/presentation/screens/edit_profile_screen.dart';
import 'package:digv/features/more/presentation/screens/manage_addresses_screen.dart';
import 'package:digv/features/more/presentation/screens/payment_methods_screen.dart';
import 'package:digv/features/more/presentation/screens/notification_settings_screen.dart';
import 'package:digv/features/more/presentation/screens/app_settings_screen.dart';
import 'package:digv/features/more/presentation/screens/help_center_screen.dart';
import 'package:digv/features/more/presentation/screens/contact_support_screen.dart';
import 'package:digv/features/more/presentation/screens/faqs_screen.dart';
import 'package:digv/features/notifications/presentation/screens/notification_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/enable_location_access_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_more_details_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_welcome_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_personal_details_screen.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
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
      builder: (context, state) => const ServiceDetailsScreen(),
    ),
    GoRoute(
      path: '/select_technician',
      builder: (context, state) => const SelectTechnicianScreen(),
    ),
    GoRoute(
      path: '/select_date_and_time',
      builder: (context, state) => const SelectDateTimeScreen(),
    ),
    GoRoute(
      path: '/review_booking',
      builder: (context, state) => const ReviewBookingScreen(),
    ),
    GoRoute(
      path: '/review_and_pay',
      builder: (context, state) => const ReviewPayScreen(),
    ),
    GoRoute(
      path: '/payment_type',
      builder: (context, state) => const PaymentTypeScreen(),
    ),
    GoRoute(
      path: '/payment_gateway',
      builder: (context, state) => const PaymentGatewayScreen(),
    ),
    GoRoute(
      path: '/booking_requested',
      builder: (context, state) => const BookingRequestedScreen(),
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
        final paymentType = state.extra as PaymentType? ?? PaymentType.prepaid;
        return OrderTrackingScreen(paymentType: paymentType);
      },
    ),
    GoRoute(
      path: '/postpaid_payment',
      builder: (context, state) => const PostpaidPaymentScreen(),
    ),
    GoRoute(
      path: '/postpaid_payment_success',
      builder: (context, state) => const PostpaidPaymentSuccessScreen(),
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
        return const SetupMoreDetailsScreen();
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
