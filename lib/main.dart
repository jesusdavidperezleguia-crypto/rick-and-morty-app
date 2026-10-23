
import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/screens/login_screen.dart';
import 'package:rick_and_morty_app/screens/main_navigation.dart';
import 'package:rick_and_morty_app/services/auth_service.dart';

const Color portalGreen = Color(0xFF97CE4C);
const Color appBackground = Color(0xFF12141A);
const Color surfaceColor = Color(0xFF20232B);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick and Morty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: appBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: portalGreen,
          brightness: Brightness.dark,
          surface: surfaceColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: appBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: portalGreen,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: portalGreen,
            foregroundColor: const Color(0xFF17200F),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF353945),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: portalGreen,
              width: 1.5,
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: surfaceColor,
          indicatorColor: portalGreen,
          elevation: 0,
          labelBehavior:
          NavigationDestinationLabelBehavior.alwaysShow,
        ),
        dividerColor: const Color(0xFF353945),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: portalGreen,
        ),
      ),
      home: FutureBuilder<bool>(
        future: AuthService().isLogged(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return LoginScreen();
          }

          return snapshot.data == true
              ? const MainNavigation()
              : LoginScreen();
        },
      ),
    );
  }
}
