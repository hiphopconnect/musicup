// lib/widgets/responsive_widgets.dart

import 'package:flutter/material.dart';

/// Breakpoints für responsive Design
class BreakPoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

/// Responsive Helper für Bildschirmgrößen
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < BreakPoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= BreakPoints.mobile && width < BreakPoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= BreakPoints.tablet;
  }

  static int getCrossAxisCount(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    if (isMobile(context)) return mobileColumns;
    if (isTablet(context)) return tabletColumns;
    return desktopColumns;
  }

  static double getContentMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800;
    return 1200;
  }
}

/// Responsive Grid für bessere Tablet/Desktop Unterstützung
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getCrossAxisCount(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
    );

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 4.5 : 3.5,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Adaptive Padding basierend auf Bildschirmgröße
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(8.0),
    this.tabletPadding = const EdgeInsets.all(16.0),
    this.desktopPadding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    
    if (ResponsiveHelper.isMobile(context)) {
      padding = mobilePadding!;
    } else if (ResponsiveHelper.isTablet(context)) {
      padding = tabletPadding!;
    } else {
      padding = desktopPadding!;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive Container mit maximaler Breite
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.getContentMaxWidth(context);
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: centerContent 
          ? Center(child: child)
          : child,
    );
  }
}

/// Adaptive Layout Builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (ResponsiveHelper.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Responsive Text Größe
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double mobileScale;
  final double tabletScale;
  final double desktopScale;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileScale = 1.0,
    this.tabletScale = 1.1,
    this.desktopScale = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    double scale;
    
    if (ResponsiveHelper.isMobile(context)) {
      scale = mobileScale;
    } else if (ResponsiveHelper.isTablet(context)) {
      scale = tabletScale;
    } else {
      scale = desktopScale;
    }

    return Text(
      text,
      style: style?.copyWith(
        fontSize: (style?.fontSize ?? 14.0) * scale,
      ) ?? TextStyle(fontSize: 14.0 * scale),
    );
  }
}