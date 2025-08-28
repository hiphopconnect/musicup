import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/core/responsive/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('should display mobile layout for small screens', (tester) async {
      const mobileWidget = Text('Mobile');
      const tabletWidget = Text('Tablet');
      const desktopWidget = Text('Desktop');

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveLayout(
              mobile: mobileWidget,
              tablet: tabletWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should display tablet layout for medium screens', (tester) async {
      const mobileWidget = Text('Mobile');
      const tabletWidget = Text('Tablet');
      const desktopWidget = Text('Desktop');

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: ResponsiveLayout(
              mobile: mobileWidget,
              tablet: tabletWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should display desktop layout for large screens', (tester) async {
      const mobileWidget = Text('Mobile');
      const tabletWidget = Text('Tablet');
      const desktopWidget = Text('Desktop');

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: ResponsiveLayout(
              mobile: mobileWidget,
              tablet: tabletWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when tablet is not provided', (tester) async {
      const mobileWidget = Text('Mobile');
      const desktopWidget = Text('Desktop');

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)), // Tablet size
            child: ResponsiveLayout(
              mobile: mobileWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should fallback correctly for large desktop screens', (tester) async {
      const mobileWidget = Text('Mobile');
      const desktopWidget = Text('Desktop');

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1500, 1000)), // Large desktop
            child: ResponsiveLayout(
              mobile: mobileWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });
  });

  group('ResponsiveBreakpoints', () {
    test('should have correct breakpoint values', () {
      expect(ResponsiveBreakpoints.mobile, equals(480));
      expect(ResponsiveBreakpoints.tablet, equals(768));
      expect(ResponsiveBreakpoints.desktop, equals(1024));
      expect(ResponsiveBreakpoints.largeDesktop, equals(1440));
    });
  });

  group('ResponsiveLayout.getDeviceType', () {
    test('should return mobile for small screens', () {
      expect(ResponsiveLayout.getDeviceType(400), DeviceType.mobile);
      expect(ResponsiveLayout.getDeviceType(479), DeviceType.mobile);
    });

    test('should return tablet for medium screens', () {
      expect(ResponsiveLayout.getDeviceType(480), DeviceType.tablet);
      expect(ResponsiveLayout.getDeviceType(767), DeviceType.tablet);
    });

    test('should return desktop for large screens', () {
      expect(ResponsiveLayout.getDeviceType(768), DeviceType.desktop);
      expect(ResponsiveLayout.getDeviceType(1023), DeviceType.desktop);
    });

    test('should return largeDesktop for extra large screens', () {
      expect(ResponsiveLayout.getDeviceType(1440), DeviceType.largeDesktop);
      expect(ResponsiveLayout.getDeviceType(1920), DeviceType.largeDesktop);
    });
  });

  group('PlatformAdaptive', () {
    testWidgets('should return appropriate padding for different platforms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = PlatformAdaptive.getPlatformPadding(context);
              return Container(
                padding: padding,
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      // Test passes if no exception is thrown
      expect(find.text('Test'), findsOneWidget);
    });

    test('should return appropriate border radius', () {
      final borderRadius = PlatformAdaptive.getPlatformBorderRadius();
      expect(borderRadius, isA<BorderRadius>());
    });

    test('should return appropriate elevation', () {
      final elevation = PlatformAdaptive.getPlatformElevation();
      expect(elevation, isA<double>());
      expect(elevation, greaterThanOrEqualTo(0));
    });

    testWidgets('should return appropriate app bar height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final height = PlatformAdaptive.getAppBarHeight(context);
              return SizedBox(
                height: height,
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('ResponsiveValue', () {
    testWidgets('should return mobile value for mobile screens', (tester) async {
      final responsiveValue = ResponsiveValue<String>(
        mobile: 'Mobile Value',
        tablet: 'Tablet Value',
        desktop: 'Desktop Value',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final value = responsiveValue.getValue(context);
                return Text(value);
              },
            ),
          ),
        ),
      );

      expect(find.text('Mobile Value'), findsOneWidget);
    });

    testWidgets('should return tablet value for tablet screens', (tester) async {
      final responsiveValue = ResponsiveValue<String>(
        mobile: 'Mobile Value',
        tablet: 'Tablet Value',
        desktop: 'Desktop Value',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                final value = responsiveValue.getValue(context);
                return Text(value);
              },
            ),
          ),
        ),
      );

      expect(find.text('Tablet Value'), findsOneWidget);
    });

    testWidgets('should return desktop value for desktop screens', (tester) async {
      final responsiveValue = ResponsiveValue<String>(
        mobile: 'Mobile Value',
        tablet: 'Tablet Value',
        desktop: 'Desktop Value',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final value = responsiveValue.getValue(context);
                return Text(value);
              },
            ),
          ),
        ),
      );

      expect(find.text('Desktop Value'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when tablet is not provided', (tester) async {
      final responsiveValue = ResponsiveValue<String>(
        mobile: 'Mobile Value',
        desktop: 'Desktop Value',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)), // Tablet size
            child: Builder(
              builder: (context) {
                final value = responsiveValue.getValue(context);
                return Text(value);
              },
            ),
          ),
        ),
      );

      expect(find.text('Mobile Value'), findsOneWidget);
    });
  });
}