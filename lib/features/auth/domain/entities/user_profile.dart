class UserProfile {
  final String userProfileId;
  final String userId;
  final String profileType;
  final String? bio;
  final bool isAvailableNow;
  final String profileVerificationStatus;
  final String? verificationNote;
  final String basePrice;
  final String currency;
  final bool isWeeklyPayoutEnabled;
  final String? payoutDisabledAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.userProfileId,
    required this.userId,
    required this.profileType,
    this.bio,
    required this.isAvailableNow,
    required this.profileVerificationStatus,
    this.verificationNote,
    required this.basePrice,
    required this.currency,
    required this.isWeeklyPayoutEnabled,
    this.payoutDisabledAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
