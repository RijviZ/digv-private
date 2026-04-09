enum PaymentMode { prepaid, postpaid }

enum PrepaidMethod { upi, card, netBanking }

enum PostpaidMethod { card, netBanking, cash }

extension PrepaidLabel on PrepaidMethod {
  String get label {
    switch (this) {
      case PrepaidMethod.upi:
        return 'UPI';
      case PrepaidMethod.card:
        return 'Card';
      case PrepaidMethod.netBanking:
        return 'Net Banking';
    }
  }
}

extension PostpaidLabel on PostpaidMethod {
  String get label {
    switch (this) {
      case PostpaidMethod.card:
        return 'Card';
      case PostpaidMethod.netBanking:
        return 'Net Banking';
      case PostpaidMethod.cash:
        return 'Cash';
    }
  }
}
