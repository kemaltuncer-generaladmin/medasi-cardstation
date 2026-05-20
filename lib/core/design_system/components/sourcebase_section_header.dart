import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../constants/sb_spacing.dart';
import '../typography/sb_text_styles.dart';
import 'sourcebase_button.dart';

class SourceBaseSectionHeader extends StatelessWidget {
  const SourceBaseSectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      header: true,
      label: title,
      child: Padding(
        padding: const EdgeInsets.only(bottom: SBSpacing.sm),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SBTextStyles.heading3.copyWith(color: AppColors.navy),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: SBSpacing.xs),
                  Text(
                    subtitle!,
                    style: SBTextStyles.bodySmall.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            );

            if (compact || actionLabel == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: SBSpacing.sm),
                    SourceBaseButton(
                      label: actionLabel!,
                      onPressed: onAction,
                      variant: SourceBaseButtonVariant.text,
                      fullWidth: false,
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: SBSpacing.md),
                SourceBaseButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: SourceBaseButtonVariant.text,
                  fullWidth: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
