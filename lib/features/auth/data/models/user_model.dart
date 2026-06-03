import 'package:digv/features/address/data/models/address_model.dart';

import '../../domain/entities/user.dart';
import 'user_profile_model.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.phoneNumber,
    required super.countryCode,
    super.email,
    super.fullName,
    super.gender,
    super.dateOfBirth,
    super.avatarUrl,
    super.referredByCode,
    super.userOwnReferralCode,
    required super.role,
    required super.isPhoneVerified,
    required super.isEmailVerified,
    required super.isProfileSetupCompleted,
    required super.isLocationAccessSkipped,
    required super.isOnboardingCompleted,
    super.latestLocation,
    super.addresses,
    super.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? latestLocationJson = json['latestLocation'] as Map<String, dynamic>?;
    
    // If latestLocation is null, try to find it in the locations list (legacy support)
    if (latestLocationJson == null && json['locations'] is List) {
      final locations = json['locations'] as List;
      if (locations.isNotEmpty) {
        final latest = locations.firstWhere(
          (loc) => loc['isLatest'] == true,
          orElse: () => locations.first,
        );
        latestLocationJson = latest as Map<String, dynamic>;
      }
    }

    return UserModel(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      countryCode: json['countryCode'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      referredByCode: json['referredByCode'] as String?,
      userOwnReferralCode: json['userOwnReferralCode'] as String?,
      role: json['role'] as String,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isProfileSetupCompleted: json['isProfileSetupCompleted'] as bool? ?? false,
      isLocationAccessSkipped: json['isLocationAccessSkipped'] as bool? ?? false,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
      latestLocation: latestLocationJson != null ? AddressModel.fromJson(latestLocationJson) : null,
      addresses: json['addresses'] != null
          ? (json['addresses'] as List)
              .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      profile: json['profile'] != null
          ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'email': email,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'avatarUrl': avatarUrl,
      'referredByCode': referredByCode,
      'userOwnReferralCode': userOwnReferralCode,
      'role': role,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'isProfileSetupCompleted': isProfileSetupCompleted,
      'isLocationAccessSkipped': isLocationAccessSkipped,
      'isOnboardingCompleted': isOnboardingCompleted,
      'latestLocation': (latestLocation as AddressModel?)?.toJson(),
      'addresses': addresses?.map((e) => (e as AddressModel).toJson()).toList(),
      'profile': (profile as UserProfileModel?)?.toJson(),
    };
  }
}

