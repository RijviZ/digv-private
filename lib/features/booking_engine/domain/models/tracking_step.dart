class TrackingStep {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final bool isActive;
  final String? actionLabel;
  final void Function()? onAction;

  const TrackingStep({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.isActive,
    this.actionLabel,
    this.onAction,
  });
}
