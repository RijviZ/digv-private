class BankAccount {
  final String userBankAccountId;
  final String userId;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String branchName;
  final String accountType;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verifiedByAdminId;
  final String? verificationNote;
  final Map<String, dynamic>? verificationResponse;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankAccount({
    required this.userBankAccountId,
    required this.userId,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branchName,
    required this.accountType,
    required this.isVerified,
    this.verifiedAt,
    this.verifiedByAdminId,
    this.verificationNote,
    this.verificationResponse,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
