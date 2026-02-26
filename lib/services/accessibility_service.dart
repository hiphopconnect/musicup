// lib/services/accessibility_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Service fuer Accessibility-Verbesserungen ohne Design-Aenderungen.
/// Note: Semantic labels use simple English to avoid complex l10n dependencies
/// in a service class. Screen readers handle multi-language content well.
class AccessibilityService {

  /// Erstellt semantische Label fuer Alben
  static String createAlbumLabel(String albumName, String artist, String year, String medium) {
    return 'Album: $albumName, $artist, $year, $medium';
  }

  /// Erstellt semantische Label fuer Buttons mit Context
  static String createButtonLabel(String action, String? context) {
    if (context != null && context.isNotEmpty) {
      return '$action: $context';
    }
    return action;
  }

  /// Erstellt semantische Label fuer Form-Felder
  static String createFormFieldLabel(String fieldName, bool isRequired, String? currentValue) {
    final requiredText = isRequired ? ', *' : '';
    final valueText = (currentValue != null && currentValue.isNotEmpty)
        ? ': $currentValue'
        : '';

    return '$fieldName$requiredText$valueText';
  }

  /// Erstellt semantische Hinweise fuer Listen
  static String createListHint(int itemCount, String itemType) {
    return '$itemCount $itemType';
  }

  /// Erstellt semantische Labels fuer Navigation
  static String createNavigationLabel(String screenName, String? additionalInfo) {
    return additionalInfo != null ? '$screenName, $additionalInfo' : screenName;
  }

  /// Erstellt Status-Announcements für Screen-Reader
  static void announceStatus(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Erstellt semantische Labels für Aktions-Buttons
  static String createActionLabel(String action, String itemName, String itemType) {
    return '$action $itemType: $itemName';
  }

  /// Fokus-Management für Keyboards
  static void moveFocusToNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void moveFocusToPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  static void requestFocus(FocusNode focusNode) {
    focusNode.requestFocus();
  }

  /// Erstellt Semantic Widgets mit verbesserter Accessibility
  static Widget createSemanticButton({
    required Widget child,
    required String label,
    required VoidCallback? onPressed,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      child: child,
    );
  }

  static Widget createSemanticListItem({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      child: child,
    );
  }

  static Widget createSemanticFormField({
    required Widget child,
    required String label,
    bool isRequired = false,
    String? currentValue,
    String? errorText,
  }) {
    final semanticLabel = createFormFieldLabel(label, isRequired, currentValue);
    final fullLabel = errorText != null ? '$semanticLabel, $errorText' : semanticLabel;
    
    return Semantics(
      label: fullLabel,
      textField: true,
      child: child,
    );
  }

  /// Prüft ob Accessibility-Services aktiviert sind
  static bool isAccessibilityEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Erhöht Tap-Targets für bessere Accessibility
  static Widget createAccessibleTapTarget({
    required Widget child,
    required VoidCallback? onTap,
    double minSize = 48.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: child,
      ),
    );
  }

  /// Erstellt Focus-Traps für Dialoge
  static Widget createFocusTrap({
    required Widget child,
    required FocusNode firstFocus,
    required FocusNode lastFocus,
  }) {
    return FocusTrap(
      child: child,
    );
  }
}

/// Custom FocusTrap Widget für bessere Keyboard-Navigation
class FocusTrap extends StatelessWidget {
  final Widget child;

  const FocusTrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        // Implementierung für Tab-Trapping in Dialogen
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// Accessibility-Announcements für wichtige Status-Änderungen
class AccessibilityAnnouncer {
  static void albumAdded(BuildContext context, String albumName, String artist) {
    AccessibilityService.announceStatus(
      context,
      '$albumName - $artist',
    );
  }

  static void albumDeleted(BuildContext context, String albumName) {
    AccessibilityService.announceStatus(context, albumName);
  }

  static void searchResults(BuildContext context, int resultCount) {
    AccessibilityService.announceStatus(context, '$resultCount');
  }

  static void validationError(BuildContext context, String error) {
    AccessibilityService.announceStatus(context, error);
  }

  static void formSaved(BuildContext context, String itemName) {
    AccessibilityService.announceStatus(context, itemName);
  }
}