import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../buttons/sb_primary_button.dart';
import '../buttons/sb_secondary_button.dart';
import '../buttons/sb_text_button.dart';

enum SourceBaseButtonVariant { primary, secondary, text }

class SourceBaseButton extends StatelessWidget {
  const SourceBaseButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = SourceBaseButtonVariant.primary,
    this.size = SBButtonSize.medium,
    this.loading = false,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SourceBaseButtonVariant variant;
  final SBButtonSize size;
  final bool loading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      SourceBaseButtonVariant.primary => SBPrimaryButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        size: size,
        loading: loading,
        fullWidth: fullWidth,
      ),
      SourceBaseButtonVariant.secondary => SBSecondaryButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        size: size,
        loading: loading,
        fullWidth: fullWidth,
      ),
      SourceBaseButtonVariant.text => Align(
        alignment: fullWidth ? Alignment.centerLeft : Alignment.center,
        child: SBTextButton(
          label: label,
          onPressed: loading ? null : onPressed,
          icon: icon,
          color: AppColors.blue,
        ),
      ),
    };
  }
}
