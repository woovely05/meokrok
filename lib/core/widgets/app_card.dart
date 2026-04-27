import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 12,
    this.color,
    this.borderColor,
    this.borderWidth = 0.5,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
            color: borderColor ?? colors.border, width: borderWidth),
      ),
      child: child,
    );
  }
}
