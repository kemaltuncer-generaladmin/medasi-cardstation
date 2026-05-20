import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../constants/sb_dimensions.dart';
import '../constants/sb_shadows.dart';
import '../constants/sb_spacing.dart';

class SourceBaseCard extends StatelessWidget {
  const SourceBaseCard({
    required this.child,
    this.padding = SBSpacing.cardPadding,
    this.margin,
    this.radius = SBDimensions.cardRadius,
    this.borderColor,
    this.backgroundColor = AppColors.white,
    this.elevated = true,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? borderColor;
  final Color backgroundColor;
  final bool elevated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final content = Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? AppColors.line),
        boxShadow: elevated ? SBShadows.card : null,
      ),
      child: child,
    );

    if (onTap == null) {
      return Semantics(
        container: true,
        explicitChildNodes: true,
        child: content,
      );
    }

    return Semantics(
      button: true,
      container: true,
      explicitChildNodes: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      ),
    );
  }
}
