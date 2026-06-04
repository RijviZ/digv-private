import 'package:digv/features/address/domain/entities/address.dart';
import 'user_profile.dart';

class User {
  final String userId;
  final String phoneNumber;
  final String countryCode;
  final String? email;
  final String? fullName;
  final String? gender;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String? referredByCode;
  final String? userOwnReferralCode;
  final String role;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isProfileSetupCompleted;
  final bool isLocationAccessSkipped;
  final bool isOnboardingCompleted;
  final Address? latestLocation;
  final List<Address>? addresses;
  final UserProfile? profile;

  const User({
    required this.userId,
    required this.phoneNumber,
    required this.countryCode,
    this.email,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
    this.referredByCode,
    this.userOwnReferralCode,
    required this.role,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.isProfileSetupCompleted,
    required this.isLocationAccessSkipped,
    required this.isOnboardingCompleted,
    this.latestLocation,
    this.addresses,
    this.profile,
  });
}

