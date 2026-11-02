import 'package:flutter/material.dart';

enum DisputeStatus {
  opened,
  underReview,
  resolved,
  rejected;

  String get label {
    switch (this) {
      case DisputeStatus.opened:
        return 'Opened';
      case DisputeStatus.underReview:
        return 'Under Review';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case DisputeStatus.opened:
        return const Color(0xFFD97706);
      case DisputeStatus.underReview:
        return const Color(0xFF2563EB);
      case DisputeStatus.resolved:
        return const Color(0xFF059669);
      case DisputeStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case DisputeStatus.opened:
        return const Color(0xFFFEF3C7);
      case DisputeStatus.underReview:
        return const Color(0xFFDBEAFE);
      case DisputeStatus.resolved:
        return const Color(0xFFD1FAE5);
      case DisputeStatus.rejected:
        return const Color(0xFFFEE2E2);
    }
  }
}

class DisputeEntity {
  final String id;
  final String? disputeNo;
  final String serviceRequestId;
  final String? serviceRequestNumber;
  final double amountInDispute;
  final double? serviceRequestTotalAmount;
  final String currency;
  final String reason;
  final String? adminNote;
  final DisputeStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? customerAvatarUrl;
  final String? providerId;
  final String? providerName;
  final String? providerEmail;
  final String? providerPhone;
  final String? providerAvatarUrl;
  final String? createdByUserId;
  final String? createdByName;
  final String? createdByUserType;
  final String? resolution;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DisputeEntity({
    required this.id,
    this.disputeNo,
    required this.serviceRequestId,
    this.serviceRequestNumber,
    required this.amountInDispute,
    this.serviceRequestTotalAmount,
    this.currency = 'INR',
    required this.reason,
    this.adminNote,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerAvatarUrl,
    this.providerId,
    this.providerName,
    this.providerEmail,
    this.providerPhone,
    this.providerAvatarUrl,
    this.createdByUserId,
    this.createdByName,
    this.createdByUserType,
    this.resolution,
    this.createdAt,
    this.updatedAt,
  });

  String get displayDisputeNo {
    if (disputeNo != null && disputeNo!.isNotEmpty) {
      return disputeNo!;
    }
    if (id.isNotEmpty) {
      final short = id.length > 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();
      return 'DSP-$short';
    }
    return 'DSP-UNKNOWN';
  }

  String get displayOrderNo {
    if (serviceRequestNumber != null && serviceRequestNumber!.isNotEmpty) {
      return 'Order #$serviceRequestNumber';
    }
    if (serviceRequestId.isNotEmpty) {
      final short = serviceRequestId.length > 6
          ? serviceRequestId.substring(0, 6).toUpperCase()
          : serviceRequestId.toUpperCase();
      return 'Order #$short';
    }
    return 'Order';
  }

  String get displayServiceRequestNumber {
    if (serviceRequestNumber != null && serviceRequestNumber!.isNotEmpty) {
      return serviceRequestNumber!;
    }
    if (serviceRequestId.isNotEmpty) {
      return serviceRequestId.length > 6
          ? serviceRequestId.substring(0, 6).toUpperCase()
          : serviceRequestId.toUpperCase();
    }
    return '';
  }

  String get formattedDateTime {
    if (createdAt == null) return '';
    final dt = createdAt!.toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month/$year $hour:$minute $ampm';
  }

  factory DisputeEntity.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? json['disputeStatus'] ?? 'OPENED')
        .toString()
        .toUpperCase();
    DisputeStatus status = DisputeStatus.opened;
    if (statusStr.contains('UNDER_REVIEW') || statusStr.contains('REVIEW')) {
      status = DisputeStatus.underReview;
    } else if (statusStr.contains('RESOLV')) {
      status = DisputeStatus.resolved;
    } else if (statusStr.contains('REJECT')) {
      status = DisputeStatus.rejected;
    }

    final rawAmount = json['amountInDispute'] ?? json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : (double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0);

    final rawTotalAmount =
        json['serviceRequestTotalAmount'] ?? json['totalAmount'];
    final totalAmount = rawTotalAmount is num
        ? rawTotalAmount.toDouble()
        : double.tryParse(rawTotalAmount?.toString() ?? '');

    return DisputeEntity(
      id: json['disputeId']?.toString() ??
          json['id']?.toString() ??
          json['_id']?.toString() ??
          '',
      disputeNo: json['disputeNo']?.toString(),
      serviceRequestId: json['serviceRequestId']?.toString() ??
          (json['serviceRequest'] is Map
              ? (json['serviceRequest']['id']?.toString() ??
                  json['serviceRequest']['serviceRequestId']?.toString())
              : null) ??
          '',
      serviceRequestNumber: json['serviceRequestNumber']?.toString() ??
          (json['serviceRequest'] is Map
              ? (json['serviceRequest']['serviceRequestNumber']?.toString() ??
                  json['serviceRequest']['orderId']?.toString())
              : null),
      amountInDispute: amount,
      serviceRequestTotalAmount: totalAmount,
      currency: json['currency']?.toString() ?? 'INR',
      reason: json['reason']?.toString() ?? '',
      adminNote: json['adminNote']?.toString(),
      status: status,
      customerId: json['customerId']?.toString(),
      customerName: json['customerName']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      customerAvatarUrl: json['customerAvatarUrl']?.toString(),
      providerId: json['providerId']?.toString(),
      providerName: json['providerName']?.toString(),
      providerEmail: json['providerEmail']?.toString(),
      providerPhone: json['providerPhone']?.toString(),
      providerAvatarUrl: json['providerAvatarUrl']?.toString(),
      createdByUserId: json['createdByUserId']?.toString(),
      createdByName: json['createdByName']?.toString(),
      createdByUserType: json['createdByUserType']?.toString(),
      resolution: json['resolution']?.toString() ??
          json['resolutionNote']?.toString() ??
          json['adminNote']?.toString() ??
          json['notes']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disputeNo': disputeNo,
      'serviceRequestId': serviceRequestId,
      'serviceRequestNumber': serviceRequestNumber,
      'amountInDispute': amountInDispute,
      'serviceRequestTotalAmount': serviceRequestTotalAmount,
      'currency': currency,
      'reason': reason,
      'adminNote': adminNote,
      'status': status.name.toUpperCase(),
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAvatarUrl': customerAvatarUrl,
      'providerId': providerId,
      'providerName': providerName,
      'providerEmail': providerEmail,
      'providerPhone': providerPhone,
      'providerAvatarUrl': providerAvatarUrl,
      'createdByUserId': createdByUserId,
      'createdByName': createdByName,
      'createdByUserType': createdByUserType,
      'resolution': resolution,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
