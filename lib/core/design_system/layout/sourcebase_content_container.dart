import 'package:flutter/material.dart';

import '../../widgets/responsive_layout.dart';

class SourceBaseContentContainer extends StatelessWidget {
  const SourceBaseContentContainer({
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.getContentMaxWidth(context),
        ),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.getHorizontalPadding(context),
              ),
          child: child,
        ),
      ),
    );
  }
}
