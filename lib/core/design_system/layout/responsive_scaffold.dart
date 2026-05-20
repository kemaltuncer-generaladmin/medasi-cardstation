import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/responsive_layout.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    required this.body,
    this.mobileNavigation,
    this.tabletNavigation,
    this.desktopNavigation,
    this.busy = false,
    super.key,
  });

  final Widget body;
  final Widget? mobileNavigation;
  final Widget? tabletNavigation;
  final Widget? desktopNavigation;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final breakpoint = ResponsiveLayout.breakpointOf(context);
    final progress = busy
        ? const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 3),
          )
        : null;

    if (breakpoint == SourceBaseBreakpoint.mobile) {
      return Scaffold(
        backgroundColor: AppColors.page,
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: body),
            ?mobileNavigation,
            ?progress,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.page,
      body: Row(
        children: [
          if (breakpoint == SourceBaseBreakpoint.desktop &&
              desktopNavigation != null)
            SafeArea(right: false, child: desktopNavigation!)
          else if (tabletNavigation != null)
            SafeArea(right: false, child: tabletNavigation!),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: body),
                ?progress,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
