import 'package:flutter/material.dart';

enum PayTab { upi, credit, debit, bank }

extension PayTabInfo on PayTab {
  String get label {
    switch (this) {
      case PayTab.upi:    return 'UPI';
      case PayTab.credit: return 'Credit';
      case PayTab.debit:  return 'Debit';
      case PayTab.bank:   return 'Bank';
    }
  }

  String get svgPath {
    switch (this) {
      case PayTab.upi:    return 'assets/images/smart-phone-01.svg';
      case PayTab.credit: return 'assets/images/credit-card.svg';
      case PayTab.debit:  return 'assets/images/credit-card.svg';
      case PayTab.bank:   return 'assets/images/bank.svg';
    }
  }
}

class UpiApp {
  final String name;
  final Color bgColor;
  final Color iconBg;
  final String imagePath;

  const UpiApp({
    required this.name,
    required this.bgColor,
    required this.iconBg,
    required this.imagePath,
  });
}
