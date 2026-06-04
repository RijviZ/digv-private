class UserStats {
  final int totalBookings;
  final int completedBookings;
  final double totalSpent;
  final double avgRating;
  final int totalReviews;

  const UserStats({
    required this.totalBookings,
    required this.completedBookings,
    required this.totalSpent,
    required this.avgRating,
    required this.totalReviews,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalBookings: json['totalBookings'] as int? ?? 0,
      completedBookings: json['completedBookings'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }

  factory UserStats.empty() {
    return const UserStats(
      totalBookings: 0,
      completedBookings: 0,
      totalSpent: 0.0,
      avgRating: 0.0,
      totalReviews: 0,
    );
  }
}
