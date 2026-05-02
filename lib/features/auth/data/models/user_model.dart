import '../../domain/entities/user.dart';

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
    required super.role,
    required super.isPhoneVerified,
    required super.isEmailVerified,
    required super.isProfileSetupCompleted,
    required super.isLocationAccessSkipped,
    required super.isOnboardingCompleted,
    super.latestLocation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      countryCode: json['countryCode'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isProfileSetupCompleted: json['isProfileSetupCompleted'] as bool? ?? false,
      isLocationAccessSkipped: json['isLocationAccessSkipped'] as bool? ?? false,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
      latestLocation: json['latestLocation'] as Map<String, dynamic>?,
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
      'role': role,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'isProfileSetupCompleted': isProfileSetupCompleted,
      'isLocationAccessSkipped': isLocationAccessSkipped,
      'isOnboardingCompleted': isOnboardingCompleted,
      'latestLocation': latestLocation,
    };
  }
}
