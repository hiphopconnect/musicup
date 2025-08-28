import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Platform type enumeration for specific optimizations
enum PlatformType {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
}

/// Responsive layout builder that adapts UI based on screen size and platform
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(screenWidth);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  static DeviceType getDeviceType(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  static PlatformType getCurrentPlatform() {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isIOS) return PlatformType.ios;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isMacOS) return PlatformType.macos;
    if (Platform.isLinux) return PlatformType.linux;
    return PlatformType.linux; // fallback
  }

  static bool get isMobile => getCurrentPlatform() == PlatformType.android || 
                             getCurrentPlatform() == PlatformType.ios;
  
  static bool get isDesktop => getCurrentPlatform() == PlatformType.windows || 
                              getCurrentPlatform() == PlatformType.macos || 
                              getCurrentPlatform() == PlatformType.linux;
}

/// Platform-specific UI adaptations
class PlatformAdaptive {
  /// Get platform-appropriate app bar height
  static double getAppBarHeight(BuildContext context) {
    final platform = ResponsiveLayout.getCurrentPlatform();
    switch (platform) {
      case PlatformType.ios:
        return 44.0; // iOS navigation bar height
      case PlatformType.macos:
        return 52.0; // macOS title bar height
      case PlatformType.windows:
        return 48.0; // Windows title bar height
      case PlatformType.linux:
        return 56.0; // Standard Material app bar height
      case PlatformType.android:
        return 56.0; // Material app bar height
      case PlatformType.web:
        return 64.0; // Larger for web
    }
  }

  /// Get platform-appropriate padding
  static EdgeInsets getPlatformPadding(BuildContext context) {
    final platform = ResponsiveLayout.getCurrentPlatform();
    final deviceType = ResponsiveLayout.getDeviceType(
      MediaQuery.of(context).size.width
    );

    if (ResponsiveLayout.isDesktop && deviceType != DeviceType.mobile) {
      return const EdgeInsets.all(24.0); // More padding on desktop
    }

    switch (platform) {
      case PlatformType.ios:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
      case PlatformType.android:
        return const EdgeInsets.all(16.0);
      default:
        return const EdgeInsets.all(16.0);
    }
  }

  /// Get platform-appropriate border radius
  static BorderRadius getPlatformBorderRadius() {
    final platform = ResponsiveLayout.getCurrentPlatform();
    switch (platform) {
      case PlatformType.ios:
        return BorderRadius.circular(12.0);
      case PlatformType.macos:
        return BorderRadius.circular(8.0);
      case PlatformType.windows:
        return BorderRadius.circular(4.0);
      case PlatformType.linux:
        return BorderRadius.circular(8.0);
      case PlatformType.android:
        return BorderRadius.circular(12.0);
      case PlatformType.web:
        return BorderRadius.circular(8.0);
    }
  }

  /// Get platform-appropriate elevation
  static double getPlatformElevation() {
    final platform = ResponsiveLayout.getCurrentPlatform();
    switch (platform) {
      case PlatformType.ios:
        return 0.0; // iOS uses subtle shadows
      case PlatformType.macos:
        return 2.0;
      case PlatformType.windows:
        return 4.0;
      case PlatformType.linux:
        return 2.0;
      case PlatformType.android:
        return 4.0; // Material elevation
      case PlatformType.web:
        return 2.0;
    }
  }

  /// Check if platform supports system tray
  static bool get supportsSystemTray {
    final platform = ResponsiveLayout.getCurrentPlatform();
    return platform == PlatformType.windows ||
           platform == PlatformType.macos ||
           platform == PlatformType.linux;
  }

  /// Check if platform supports window management
  static bool get supportsWindowManagement {
    return ResponsiveLayout.isDesktop;
  }

  /// Get appropriate navigation type for platform/screen size
  static NavigationType getNavigationType(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(
      MediaQuery.of(context).size.width
    );
    final platform = ResponsiveLayout.getCurrentPlatform();

    if (ResponsiveLayout.isDesktop && deviceType != DeviceType.mobile) {
      return NavigationType.sidebar;
    }

    if (platform == PlatformType.ios) {
      return NavigationType.tabBar; // iOS style tab bar
    }

    return NavigationType.bottomNavigation; // Android style bottom navigation
  }
}

enum NavigationType {
  bottomNavigation,
  tabBar,
  sidebar,
  rail,
}

/// Responsive value helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  T getValue(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(
      MediaQuery.of(context).size.width
    );

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}