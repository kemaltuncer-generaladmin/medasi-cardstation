import 'package:flutter/material.dart';

import '../design_system/constants/sb_dimensions.dart';
import '../design_system/constants/sb_spacing.dart';

enum SourceBaseBreakpoint { mobile, tablet, desktop }

/// SourceBase Responsive Layout System
///
/// Provides consistent layout behavior across mobile, tablet, and desktop.
/// Breakpoints:
/// - Mobile: 0 - 599px
/// - Tablet: 600px - 1023px
/// - Desktop: 1024px and wider
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  static const double mobileMax = 599;
  static const double tabletMin = 600;
  static const double desktopMin = 1024;

  static SourceBaseBreakpoint breakpointOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopMin) return SourceBaseBreakpoint.desktop;
    if (width >= tabletMin) return SourceBaseBreakpoint.tablet;
    return SourceBaseBreakpoint.mobile;
  }

  static bool isMobile(BuildContext context) =>
      breakpointOf(context) == SourceBaseBreakpoint.mobile;

  static bool isTablet(BuildContext context) {
    return breakpointOf(context) == SourceBaseBreakpoint.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      breakpointOf(context) == SourceBaseBreakpoint.desktop;

  static double getContentMaxWidth(BuildContext context) {
    return switch (breakpointOf(context)) {
      SourceBaseBreakpoint.desktop => SBDimensions.desktopMaxContentWidth,
      SourceBaseBreakpoint.tablet => SBDimensions.tabletMaxContentWidth,
      SourceBaseBreakpoint.mobile => double.infinity,
    };
  }

  static double getHorizontalPadding(BuildContext context) {
    return switch (breakpointOf(context)) {
      SourceBaseBreakpoint.desktop => SBSpacing.desktopPagePadding,
      SourceBaseBreakpoint.tablet => SBSpacing.tabletPagePadding,
      SourceBaseBreakpoint.mobile => SBSpacing.mobilePagePadding,
    };
  }

  static EdgeInsets safePagePadding(
    BuildContext context, {
    bool includeTop = true,
    bool includeBottom = true,
    double topExtra = 0,
    double bottomExtra = 0,
  }) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final horizontal = getHorizontalPadding(context);
    return EdgeInsets.fromLTRB(
      horizontal,
      (includeTop ? viewPadding.top : 0) + topExtra,
      horizontal,
      (includeBottom ? viewPadding.bottom : 0) + bottomExtra,
    );
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return switch (breakpointOf(context)) {
      SourceBaseBreakpoint.desktop => desktop ?? tablet ?? mobile,
      SourceBaseBreakpoint.tablet => tablet ?? mobile,
      SourceBaseBreakpoint.mobile => mobile,
    };
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= desktopMin && desktop != null) {
      return desktop!(context);
    } else if (width >= tabletMin && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

class ResponsiveValue<T> {
  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  final T mobile;
  final T? tablet;
  final T? desktop;

  T resolve(BuildContext context) {
    return ResponsiveLayout.value(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Adaptive content container that respects platform-specific max widths
class AdaptiveContent extends StatelessWidget {
  const AdaptiveContent({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveLayout.getContentMaxWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
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

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    super.key,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.isDesktop(context)
        ? desktopColumns
        : ResponsiveLayout.isTablet(context)
        ? tabletColumns
        : mobileColumns;

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: columns == 1 ? 3.4 : 1.2,
      children: children,
    );
  }
}

/// Responsive spacing that adapts to screen size
class ResponsiveSpacing extends StatelessWidget {
  const ResponsiveSpacing({
    this.mobile = 16,
    this.tablet = 24,
    this.desktop = 32,
    super.key,
  });

  final double mobile;
  final double tablet;
  final double desktop;

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveLayout.isDesktop(context)
        ? desktop
        : ResponsiveLayout.isTablet(context)
        ? tablet
        : mobile;

    return SizedBox(height: height);
  }
}
