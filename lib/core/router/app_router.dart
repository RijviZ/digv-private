import 'package:digv/features/auth/presentation/screens/login_screen.dart';
import 'package:digv/features/auth/presentation/screens/otp_screen.dart';
import 'package:digv/features/auth/presentation/screens/splash_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/payment_type_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/review_booking_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/select_date_and_time_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/select_technician_screen.dart';
import 'package:digv/features/booking_engine/presentation/screens/service_details_screen.dart';
import 'package:digv/features/home_discovery/presentation/screens/home_screen.dart';
import 'package:digv/features/notifications/presentation/screens/notification_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/enable_location_access_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_more_details_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_welcome_screen.dart';
import 'package:digv/features/profile_settings/presentation/screens/setup_personal_details_screen.dart';
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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
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
        return SetupMoreDetailsScreen();
      },
    ),
    GoRoute(
      path: '/enable_location_access',
      builder: (context, state) {
        return EnableLocationAccessScreen();
      },
    ),
  ],
);
