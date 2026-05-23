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
}

class FaqData {
  final List<FaqItem> items;
  final Map<String, int> tabs;

  const FaqData({
    required this.items,
    required this.tabs,
  });
}
