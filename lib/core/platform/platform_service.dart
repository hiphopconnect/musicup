import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:music_up/core/responsive/responsive_layout.dart';
import 'package:music_up/core/error/error_handler.dart';

/// Platform-specific service that provides platform-optimized functionality
class PlatformService {
  static PlatformService? _instance;
  static PlatformService get instance => _instance ??= PlatformService._();
  
  PlatformService._();

  /// Initialize platform-specific features
  Future<void> initialize() async {
    try {
      final platform = ResponsiveLayout.getCurrentPlatform();
      
      switch (platform) {
        case PlatformType.android:
          await _initializeAndroid();
          break;
        case PlatformType.ios:
          await _initializeIOS();
          break;
        case PlatformType.windows:
          await _initializeWindows();
          break;
        case PlatformType.macos:
          await _initializeMacOS();
          break;
        case PlatformType.linux:
          await _initializeLinux();
          break;
        case PlatformType.web:
          await _initializeWeb();
          break;
      }
    } catch (error, stackTrace) {
      AppErrorHandler.handle(
        error,
        stackTrace,
        context: 'PlatformService.initialize',
        level: ErrorLevel.warning,
      );
    }
  }

  /// Android-specific initialization
  Future<void> _initializeAndroid() async {
    // Set edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Set supported orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// iOS-specific initialization
  Future<void> _initializeIOS() async {
    // Set supported orientations (iOS defaults are usually fine)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // iOS-specific system UI configuration
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Windows-specific initialization
  Future<void> _initializeWindows() async {
    if (!PlatformAdaptive.supportsWindowManagement) return;

    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      maximumSize: Size(1920, 1080),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Set up window event listeners
    windowManager.addListener(_WindowListener());

    // Initialize system tray
    if (PlatformAdaptive.supportsSystemTray) {
      await _initializeSystemTray('assets/icons/app_icon.ico');
    }
  }

  /// macOS-specific initialization
  Future<void> _initializeMacOS() async {
    if (!PlatformAdaptive.supportsWindowManagement) return;

    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // macOS-specific window configuration
    await windowManager.setTitle('MusicUp');
    
    // Initialize system tray/menu bar
    if (PlatformAdaptive.supportsSystemTray) {
      await _initializeSystemTray('assets/icons/app_icon.png');
    }
  }

  /// Linux-specific initialization
  Future<void> _initializeLinux() async {
    if (!PlatformAdaptive.supportsWindowManagement) return;

    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Linux-specific configuration
    await windowManager.setTitle('MusicUp');

    // System tray support varies on Linux
    if (PlatformAdaptive.supportsSystemTray) {
      try {
        await _initializeSystemTray('assets/icons/app_icon.png');
      } catch (error) {
        // System tray might not be available on all Linux distributions
        AppErrorHandler.handle(
          error,
          StackTrace.current,
          context: 'Linux System Tray',
          level: ErrorLevel.warning,
        );
      }
    }
  }

  /// Web-specific initialization
  Future<void> _initializeWeb() async {
    // Web-specific optimizations
    // Note: Some features are not available on web
  }

  /// Initialize system tray with platform-specific icons
  Future<void> _initializeSystemTray(String iconPath) async {
    try {
      final SystemTray systemTray = SystemTray();

      await systemTray.initSystemTray(
        title: "MusicUp",
        iconPath: iconPath,
        toolTip: "MusicUp - Music Collection Manager",
      );

      // Create context menu
      final Menu menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Show MusicUp',
          onClicked: (menuItem) async {
            if (PlatformAdaptive.supportsWindowManagement) {
              await windowManager.show();
              await windowManager.focus();
            }
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Add Album',
          onClicked: (menuItem) async {
            // Quick add functionality
            if (PlatformAdaptive.supportsWindowManagement) {
              await windowManager.show();
              await windowManager.focus();
            }
            // TODO: Navigate to add album screen
          },
        ),
        MenuItemLabel(
          label: 'Search Discogs',
          onClicked: (menuItem) async {
            if (PlatformAdaptive.supportsWindowManagement) {
              await windowManager.show();
              await windowManager.focus();
            }
            // TODO: Navigate to Discogs search
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Settings',
          onClicked: (menuItem) async {
            if (PlatformAdaptive.supportsWindowManagement) {
              await windowManager.show();
              await windowManager.focus();
            }
            // TODO: Navigate to settings
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Exit MusicUp',
          onClicked: (menuItem) async {
            await _exitApp();
          },
        ),
      ]);

      await systemTray.setContextMenu(menu);

      // Handle tray icon clicks
      systemTray.registerSystemTrayEventHandler((eventName) async {
        if (eventName == kSystemTrayEventClick || eventName == kSystemTrayEventRightClick) {
          if (PlatformAdaptive.supportsWindowManagement) {
            final isVisible = await windowManager.isVisible();
            if (isVisible) {
              await windowManager.hide();
            } else {
              await windowManager.show();
              await windowManager.focus();
            }
          }
        }
      });
    } catch (error, stackTrace) {
      AppErrorHandler.handle(
        error,
        stackTrace,
        context: 'System Tray Initialization',
        level: ErrorLevel.warning,
      );
    }
  }

  /// Get platform-specific app information
  Future<PlatformAppInfo> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final platform = ResponsiveLayout.getCurrentPlatform();
    
    return PlatformAppInfo(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      platform: platform,
      buildSignature: packageInfo.buildSignature,
    );
  }

  /// Open URL in platform-appropriate way
  Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } catch (error, stackTrace) {
      AppErrorHandler.handle(
        error,
        stackTrace,
        context: 'PlatformService.openUrl',
      );
      return false;
    }
  }

  /// Share content using platform sharing
  Future<bool> shareText(String text, {String? subject}) async {
    try {
      // This would use share_plus package
      // await Share.share(text, subject: subject);
      return true;
    } catch (error, stackTrace) {
      AppErrorHandler.handle(
        error,
        stackTrace,
        context: 'PlatformService.shareText',
      );
      return false;
    }
  }

  /// Exit the application gracefully
  Future<void> _exitApp() async {
    if (PlatformAdaptive.supportsWindowManagement) {
      await windowManager.destroy();
    }
    SystemNavigator.pop();
  }

  /// Show platform-appropriate notifications
  Future<bool> showNotification({
    required String title,
    required String body,
    String? iconPath,
  }) async {
    try {
      // This would integrate with flutter_local_notifications
      // For now, just log the notification
      print('Notification: $title - $body');
      return true;
    } catch (error, stackTrace) {
      AppErrorHandler.handle(
        error,
        stackTrace,
        context: 'PlatformService.showNotification',
      );
      return false;
    }
  }

  /// Check for app updates (desktop only)
  Future<bool> checkForUpdates() async {
    if (!ResponsiveLayout.isDesktop) return false;

    try {
      // This would integrate with auto_updater package
      // For now, just return false (no updates)
      return false;
    } catch (error, stackTrace) {
      AppErrorHandler.handle(
        error,
        stackTrace,
        context: 'PlatformService.checkForUpdates',
      );
      return false;
    }
  }
}

/// Window event listener for desktop platforms
class _WindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    final platform = ResponsiveLayout.getCurrentPlatform();
    
    // On macOS, hide to system tray instead of closing
    if (platform == PlatformType.macos && PlatformAdaptive.supportsSystemTray) {
      await windowManager.hide();
    } else {
      // On other platforms, exit the app
      SystemNavigator.pop();
    }
  }

  @override
  void onWindowMinimize() async {
    // Optionally hide to system tray when minimized
    final platform = ResponsiveLayout.getCurrentPlatform();
    
    if (PlatformAdaptive.supportsSystemTray && platform == PlatformType.windows) {
      await windowManager.hide();
    }
  }
}

/// Platform-specific app information
class PlatformAppInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final PlatformType platform;
  final String buildSignature;

  const PlatformAppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.buildSignature,
  });

  @override
  String toString() {
    return '$appName v$version ($buildNumber) on ${platform.name}';
  }
}