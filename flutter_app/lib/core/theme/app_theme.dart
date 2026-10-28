import 'package:flutter/material.dart';

class AppTheme {
  static const Color oppoGreen = Color(0xFF00C853); // Vivid aquatic green
  static const Color oppoBlue = Color(0xFF2979FF);  // Deep aqua blue
  static const Color bgLight = Color(0xFFF4F6F9);   // Warm, soft grey-white
  static const Color textDark = Color(0xFF1C1C1E);  // Soft black
  static const Color textMuted = Color(0xFF8E8E93); // iOS-style muted grey

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: oppoBlue,
          primary: oppoBlue,
          secondary: oppoGreen,
          surface: Colors.white,
          background: bgLight,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: textDark),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: textDark, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: textDark, height: 1.4),
          bodyMedium: TextStyle(color: textMuted, height: 1.4),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: oppoBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w500),
          floatingLabelStyle: const TextStyle(color: oppoBlue, fontWeight: FontWeight.w600),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: oppoBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            elevation: 0,
          ),
        ),
      );
}