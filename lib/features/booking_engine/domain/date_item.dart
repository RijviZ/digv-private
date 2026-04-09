
class DateItem {
  final String day;
  final int date;
  final String month;

  const DateItem({required this.day, required this.date, required this.month});

  DateItem copyWith({String? day, int? date, String? month}) {
    return DateItem(day: day ?? this.day, date: date ?? this.date, month: month ?? this.month);
  }

  Map<String, dynamic> toMap() {
    return {'day': day, 'date': date, 'month': month};
  }

  factory DateItem.fromMap(Map<String, dynamic> map) {
    return DateItem(day: map['day'] as String, date: map['date'] as int, month: map['month'] as String);
  }

  @override
  String toString() => 'DateItem(day: $day, date: $date, month: $month)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateItem && other.day == day && other.date == date && other.month == month;
  }

  @override
  int get hashCode => day.hashCode ^ date.hashCode ^ month.hashCode;
}
