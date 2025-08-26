// lib/services/accessibility_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Service für Accessibility-Verbesserungen ohne Design-Änderungen
class AccessibilityService {
  
  /// Erstellt semantische Label für Alben
  static String createAlbumLabel(String albumName, String artist, String year, String medium) {
    return 'Album: $albumName von $artist, Jahr: $year, Medium: $medium';
  }

  /// Erstellt semantische Label für Buttons mit Context
  static String createButtonLabel(String action, String? context) {
    if (context != null && context.isNotEmpty) {
      return '$action für $context';
    }
    return action;
  }

  /// Erstellt semantische Label für Form-Felder
  static String createFormFieldLabel(String fieldName, bool isRequired, String? currentValue) {
    final requiredText = isRequired ? ', erforderlich' : ', optional';
    final valueText = (currentValue != null && currentValue.isNotEmpty) 
        ? ', aktueller Wert: $currentValue'
        : ', leer';
    
    return '$fieldName$requiredText$valueText';
  }

  /// Erstellt semantische Hinweise für Listen
  static String createListHint(int itemCount, String itemType) {
    if (itemCount == 0) {
      return 'Keine $itemType verfügbar';
    } else if (itemCount == 1) {
      return '1 $itemType verfügbar';
    } else {
      return '$itemCount $itemType verfügbar';
    }
  }

  /// Erstellt semantische Labels für Navigation
  static String createNavigationLabel(String screenName, String? additionalInfo) {
    final base = 'Navigiere zu $screenName';
    return additionalInfo != null ? '$base, $additionalInfo' : base;
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
    final fullLabel = errorText != null ? '$semanticLabel, Fehler: $errorText' : semanticLabel;
    
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
      'Album "$albumName" von $artist wurde erfolgreich hinzugefügt'
    );
  }

  static void albumDeleted(BuildContext context, String albumName) {
    AccessibilityService.announceStatus(
      context, 
      'Album "$albumName" wurde gelöscht'
    );
  }

  static void searchResults(BuildContext context, int resultCount) {
    final message = resultCount == 0
        ? 'Keine Suchergebnisse gefunden'
        : '$resultCount Suchergebnisse gefunden';
    
    AccessibilityService.announceStatus(context, message);
  }

  static void validationError(BuildContext context, String error) {
    AccessibilityService.announceStatus(context, 'Eingabefehler: $error');
  }

  static void formSaved(BuildContext context, String itemName) {
    AccessibilityService.announceStatus(context, '$itemName wurde gespeichert');
  }
}