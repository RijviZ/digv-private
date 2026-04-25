import 'package:flutter/material.dart';

class TrackingStep {
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final bool isCompleted;
  final bool isActive;
  final String? actionLabel;
  final Color? actionLabelColor;
  final Color? actionBorderColor;
  final Color? actionBackgroundColor;
  final void Function()? onAction;

  const TrackingStep({
    required this.title,
    this.subtitle,
    this.subtitleColor,
    required this.isCompleted,
    required this.isActive,
    this.actionLabel,
    this.actionLabelColor,
    this.actionBorderColor,
    this.actionBackgroundColor,
    this.onAction,
  });
}
