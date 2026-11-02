class FaqItem {
  final String faqId;
  final String type;
  final String question;
  final String answer;
  final int sortOrder;
  final bool isActive;
  final int helpfulCount;
  final int notHelpfulCount;

  const FaqItem({
    required this.faqId,
    required this.type,
    required this.question,
    required this.answer,
    required this.sortOrder,
    required this.isActive,
    required this.helpfulCount,
    required this.notHelpfulCount,
  });

  FaqItem copyWith({
    String? faqId,
    String? type,
    String? question,
    String? answer,
    int? sortOrder,
    bool? isActive,
    int? helpfulCount,
    int? notHelpfulCount,
  }) {
    return FaqItem(
      faqId: faqId ?? this.faqId,
      type: type ?? this.type,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
    );
  }
}

class FaqData {
  final List<FaqItem> items;
  final Map<String, int> tabs;

  const FaqData({
    required this.items,
    required this.tabs,
  });
}
