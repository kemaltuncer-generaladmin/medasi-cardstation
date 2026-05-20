import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/responsive_layout.dart';
import '../constants/sb_spacing.dart';
import 'sourcebase_content_container.dart';

class AdaptivePageShell extends StatelessWidget {
  const AdaptivePageShell({
    required this.children,
    this.onRefresh,
    this.bottomInset = 0,
    this.includeTopSafeArea = true,
    this.includeBottomSafeArea = true,
    super.key,
  });

  final List<Widget> children;
  final RefreshCallback? onRefresh;
  final double bottomInset;
  final bool includeTopSafeArea;
  final bool includeBottomSafeArea;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveLayout.safePagePadding(
      context,
      includeTop: includeTopSafeArea,
      includeBottom: includeBottomSafeArea,
      topExtra: ResponsiveLayout.isMobile(context) ? SBSpacing.sm : 18,
      bottomExtra: bottomInset,
    );
    final scroll = ListView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      children: children,
    );

    return SourceBaseContentContainer(
      padding: EdgeInsets.zero,
      child: onRefresh == null
          ? scroll
          : RefreshIndicator(
              onRefresh: onRefresh!,
              displacement: 20,
              color: AppColors.blue,
              child: scroll,
            ),
    );
  }
}
