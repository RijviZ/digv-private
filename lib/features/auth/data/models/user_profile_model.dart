import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.userProfileId,
    required super.userId,
    required super.profileType,
    super.bio,
    required super.isAvailableNow,
    required super.profileVerificationStatus,
    super.verificationNote,
    required super.basePrice,
    required super.currency,
    required super.isWeeklyPayoutEnabled,
    super.payoutDisabledAt,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userProfileId: json['userProfileId'] as String,
      userId: json['userId'] as String,
      profileType: json['profileType'] as String,
      bio: json['bio'] as String?,
      isAvailableNow: json['isAvailableNow'] as bool? ?? false,
      profileVerificationStatus: json['profileVerificationStatus'] as String,
      verificationNote: json['verificationNote'] as String?,
      basePrice: json['basePrice'] as String? ?? "0.00",
      currency: json['currency'] as String? ?? "INR",
      isWeeklyPayoutEnabled: json['isWeeklyPayoutEnabled'] as bool? ?? false,
      payoutDisabledAt: json['payoutDisabledAt'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userProfileId': userProfileId,
      'userId': userId,
      'profileType': profileType,
      'bio': bio,
      'isAvailableNow': isAvailableNow,
      'profileVerificationStatus': profileVerificationStatus,
      'verificationNote': verificationNote,
      'basePrice': basePrice,
      'currency': currency,
      'isWeeklyPayoutEnabled': isWeeklyPayoutEnabled,
      'payoutDisabledAt': payoutDisabledAt,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
