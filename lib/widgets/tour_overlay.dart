// lib/widgets/tour_overlay.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/services/tour_service.dart';
import 'package:music_up/theme/design_system.dart';

class TourOverlay extends StatelessWidget {
  final TourService tourService;

  const TourOverlay({super.key, required this.tourService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: tourService,
      builder: (context, _) {
        if (!tourService.isActive) return const SizedBox.shrink();

        final step = tourService.currentTourStep;
        if (step == null) return const SizedBox.shrink();

        final targetContext = step.targetKey.currentContext;
        if (targetContext == null) return const SizedBox.shrink();

        final renderBox = targetContext.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.hasSize) return const SizedBox.shrink();

        final targetPosition = renderBox.localToGlobal(Offset.zero);
        final targetSize = renderBox.size;
        final targetRect = targetPosition & targetSize;

        return _buildOverlay(context, targetRect, step);
      },
    );
  }

  Widget _buildOverlay(BuildContext context, Rect targetRect, TourStep step) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    const spotlightPadding = 8.0;
    final spotlightRect = Rect.fromLTRB(
      targetRect.left - spotlightPadding,
      targetRect.top - spotlightPadding,
      targetRect.right + spotlightPadding,
      targetRect.bottom + spotlightPadding,
    );

    // Tooltip soll unterhalb des Targets sein, falls Platz; sonst oberhalb
    final spaceBelow = screenSize.height - targetRect.bottom;
    final showBelow = spaceBelow > 200;

    return Stack(
      children: [
        // Halbtransparenter Hintergrund mit Ausschnitt
        GestureDetector(
          onTap: tourService.next,
          child: CustomPaint(
            size: screenSize,
            painter: _SpotlightPainter(spotlightRect: spotlightRect),
          ),
        ),

        // Tooltip
        Positioned(
          left: DS.md,
          right: DS.md,
          top: showBelow ? targetRect.bottom + 16 : null,
          bottom: showBelow ? null : screenSize.height - targetRect.top + 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(DS.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${tourService.currentStep + 1}/${tourService.steps.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: DS.xs),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: DS.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: tourService.skip,
                        child: Text(l10n.skipTour),
                      ),
                      const SizedBox(width: DS.sm),
                      FilledButton(
                        onPressed: tourService.next,
                        child: Text(
                          tourService.currentStep < tourService.steps.length - 1
                              ? l10n.nextStep
                              : l10n.finishTour,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect spotlightRect;

  _SpotlightPainter({required this.spotlightRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.7);

    // Zeichne den gesamten Hintergrund
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Erstelle einen Pfad mit Loch
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(spotlightRect, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect;
  }
}
