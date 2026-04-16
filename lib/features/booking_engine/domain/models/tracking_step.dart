class TrackingStep {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final bool isActive;

  const TrackingStep({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });
}
