import 'package:flutter/material.dart';

class LibraryTheme {
  static const forest = Color(0xFF235D48);
  static const cream = Color(0xFFFAF7F1);
  static const ink = Color(0xFF1D2925);
  static const mint = Color(0xFFDCEEE5);
  static const copper = Color(0xFFB7744D);

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: forest,
      brightness: brightness,
      surface: dark ? const Color(0xFF111C1B) : cream,
      primary: dark ? const Color(0xFF9ACDB4) : forest,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme:
          (dark
                  ? Typography.material2021().white
                  : Typography.material2021().black)
              .copyWith(
                headlineLarge: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : ink,
                ),
                headlineMedium: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : ink,
                ),
                titleLarge: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : ink,
                ),
              ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF1D2A29) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .55)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1D2A29) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF192625) : Colors.white,
        indicatorColor: dark ? const Color(0xFF325744) : mint,
        height: 72,
      ),
    );
  }
}
