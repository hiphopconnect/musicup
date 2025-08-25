import 'package:flutter/material.dart';

class DS {
  // Spacing
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;

  // Radius
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(16));

  // Duration
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // ✅ Responsive Button Helper
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
