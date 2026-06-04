import '../../domain/entities/faq.dart';

class FaqItemModel extends FaqItem {
  const FaqItemModel({
    required super.faqId,
    required super.type,
    required super.question,
    required super.answer,
    required super.sortOrder,
    required super.isActive,
    required super.helpfulCount,
    required super.notHelpfulCount,
  });

  factory FaqItemModel.fromJson(Map<String, dynamic> json) {
    return FaqItemModel(
      faqId: json['faqId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      notHelpfulCount: (json['notHelpfulCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faqId': faqId,
      'type': type,
      'question': question,
      'answer': answer,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'helpfulCount': helpfulCount,
      'notHelpfulCount': notHelpfulCount,
    };
  }
}

class FaqDataModel extends FaqData {
  const FaqDataModel({
    required super.items,
    required super.tabs,
  });

  factory FaqDataModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    final items = itemsList.map((e) => FaqItemModel.fromJson(e as Map<String, dynamic>)).toList();
    
    final tabsMap = json['tabs'] as Map<String, dynamic>? ?? {};
    final tabs = tabsMap.map((key, value) => MapEntry(key, (value as num).toInt()));

    return FaqDataModel(
      items: items,
      tabs: tabs,
    );
  }
}
