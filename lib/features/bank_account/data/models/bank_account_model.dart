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
      userBankAccountId: json['userBankAccountId'] as String,
      userId: json['userId'] as String,
      accountHolderName: json['accountHolderName'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      ifscCode: json['ifscCode'] as String,
      branchName: json['branchName'] as String,
      accountType: json['accountType'] as String,
      isVerified: json['isVerified'] as bool,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt'] as String) 
          : null,
      verifiedByAdminId: json['verifiedByAdminId'] as String?,
      verificationNote: json['verificationNote'] as String?,
      verificationResponse: json['verificationResponse'] as Map<String, dynamic>?,
      isDefault: json['isDefault'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userBankAccountId': userBankAccountId,
      'userId': userId,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
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
