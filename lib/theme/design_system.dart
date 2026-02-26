import 'package:flutter/material.dart';

class DS {
  // Spacing
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  // Icon Sizes
  static const double iconXs = 14;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 30;
  static const double iconXl = 48;
  static const double iconXxl = 64;
  static const double iconHero = 80;

  // Font Sizes
  static const double fontXs = 12;
  static const double fontSm = 14;
  static const double fontMd = 16;
  static const double fontLg = 18;
  static const double fontXl = 24;

  // Radius
  static const BorderRadius rXs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(16));

  // Duration
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // Responsive Button Helper
  static Widget responsiveButtonRow({
    required List<Widget> buttons,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Wenn zu wenig Platz, verwende Column
        if (constraints.maxWidth < 400) {
          return Column(
            children: buttons
                .map(
                  (button) => Padding(
                    padding: const EdgeInsets.only(bottom: DS.xs),
                    child: SizedBox(
                      width: double.infinity,
                      child: button,
                    ),
                  ),
                )
                .toList(),
          );
        }
        // Sonst normale Row
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          children: buttons.map((button) => Flexible(child: button)).toList(),
        );
      },
    );
  }
}
