import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF1976D2); // Angelehnt an euer Blau

  static ThemeData get light {
    final base = ThemeData(
      colorScheme:
          ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
      useMaterial3: true,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        titleMedium:
            base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.2),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: base.colorScheme.primary.withOpacity(0.15),
        checkmarkColor: base.colorScheme.primary,
        side: BorderSide(color: base.colorScheme.outlineVariant),
        shape: StadiumBorder(
            side: BorderSide(color: base.colorScheme.outlineVariant)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        prefixIconColor: base.colorScheme.primary,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      iconTheme: IconThemeData(color: base.colorScheme.primary),
      dividerColor: base.colorScheme.outlineVariant,
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      colorScheme:
          ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
      useMaterial3: true,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.surfaceContainerHighest,
        foregroundColor: base.colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: base.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: base.colorScheme.surfaceContainerHigh,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: base.colorScheme.primary.withOpacity(0.25),
        side: BorderSide(color: base.colorScheme.outline),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: base.colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: base.colorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
