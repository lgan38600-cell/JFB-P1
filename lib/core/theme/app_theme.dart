import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF080808);
  static const Color surface = Color(0xFF121212);
  static const Color elevatedSurface = Color(0xFF1A1A1A);
  static const Color outline = Color(0xFF2A2A2A);
  static const Color foreground = Color(0xFFF5F5F2);
  static const Color mutedForeground = Color(0xFFF5F5F2);
  static const Color accent = Color(0xFFE8E8E1);

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = base.textTheme
        .apply(bodyColor: foreground, displayColor: foreground)
        .copyWith(
          displaySmall: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.1,
            height: 1.08,
            color: foreground,
          ),
          headlineSmall: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: foreground,
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: foreground,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: foreground,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: foreground,
          ),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
          labelMedium: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: foreground,
          ),
        );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: foreground,
      hintColor: foreground,
      disabledColor: foreground,
      iconTheme: const IconThemeData(color: foreground),
      primaryIconTheme: const IconThemeData(color: foreground),
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: foreground,
        secondary: foreground,
        onSecondary: foreground,
        surface: surface,
        onSurface: foreground,
        outline: outline,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: outline,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        toolbarTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: outline),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: foreground,
        textColor: foreground,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: foreground,
        unselectedItemColor: foreground,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: foreground),
        unselectedLabelStyle: TextStyle(color: foreground),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: elevatedSurface,
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          disabledBackgroundColor: elevatedSurface,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: const BorderSide(color: outline),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
