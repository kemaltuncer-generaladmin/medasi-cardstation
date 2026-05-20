import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../buttons/sb_primary_button.dart';
import '../constants/sb_dimensions.dart';
import '../constants/sb_spacing.dart';
import '../typography/sb_text_styles.dart';
import 'sourcebase_card.dart';

class SourceBaseEmptyState extends StatelessWidget {
  const SourceBaseEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateContent(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class SourceBaseLoadingState extends StatelessWidget {
  const SourceBaseLoadingState({
    required this.title,
    required this.message,
    this.icon = Icons.hourglass_top_rounded,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _StateContent(
      icon: icon,
      title: title,
      message: message,
      loading: true,
    );
  }
}

class SourceBaseErrorState extends StatelessWidget {
  const SourceBaseErrorState({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateContent(
      icon: icon,
      iconColor: AppColors.red,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _StateContent extends StatelessWidget {
  const _StateContent({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.blue,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SourceBaseCard(
      padding: const EdgeInsets.all(SBDimensions.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          loading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
          const SizedBox(height: SBSpacing.md),
          Text(
            title,
            style: SBTextStyles.heading3.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: SBSpacing.xs),
          Text(
            message,
            style: SBTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: SBSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 148),
              child: SBPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                icon: Icons.refresh_rounded,
                size: SBButtonSize.small,
                fullWidth: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
