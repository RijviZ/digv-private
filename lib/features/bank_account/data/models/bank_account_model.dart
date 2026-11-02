import '../../domain/entities/bank_account.dart';

class BankAccountModel extends BankAccount {
  const BankAccountModel({
    required super.userBankAccountId,
    required super.userId,
    required super.accountHolderName,
    required super.bankName,
    required super.accountNumber,
    required super.ifscCode,
    required super.branchName,
    required super.accountType,
    required super.isVerified,
    super.verifiedAt,
    super.verifiedByAdminId,
    super.verificationNote,
    super.verificationResponse,
    required super.isDefault,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      userBankAccountId: (json['userBankInfoId'] as String?) ??
          (json['userBankAccountId'] as String?) ??
          (json['id'] as String?) ??
          '',
      userId: (json['userId'] as String?) ?? '',
      accountHolderName: (json['accountHolderName'] as String?) ?? '',
      bankName: (json['bankName'] as String?) ?? '',
      accountNumber: (json['accountNo'] as String?) ??
          (json['accountNumber'] as String?) ??
          '',
      ifscCode: (json['ifscCode'] as String?) ?? '',
      branchName: (json['branchName'] as String?) ?? '',
      accountType: (json['accountType'] as String?) ?? '',
      isVerified: (json['isVerified'] as bool?) ?? false,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'] as String)
          : null,
      verifiedByAdminId: json['verifiedByAdminId'] as String?,
      verificationNote: json['verificationNote'] as String?,
      verificationResponse: json['verificationResponse'] as Map<String, dynamic>?,
      isDefault: (json['isDefault'] as bool?) ?? false,
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Whitelisted payload for POST /users/bank-accounts as per Swagger DTO
  Map<String, dynamic> toCreateJson() {
    return {
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNo': accountNumber,
      'ifscCode': ifscCode,
      'branchName': branchName.isNotEmpty ? branchName : 'Main Branch',
      'accountType': accountType.isNotEmpty ? accountType : 'SAVINGS',
      'isDefault': isDefault,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'userBankAccountId': userBankAccountId,
      'userBankInfoId': userBankAccountId,
      'userId': userId,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNo': accountNumber,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'accountType': accountType,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedByAdminId': verifiedByAdminId,
      'verificationNote': verificationNote,
      'verificationResponse': verificationResponse,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
