import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/onboarding_cycle_day_screen.dart';
import 'screens/onboarding_conception_screen.dart';
import 'screens/onboarding_step3_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: WommiApp(),
    ),
  );
}

class WommiApp extends StatelessWidget {
  const WommiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wommi',
      debugShowCheckedModeBanner: false,
      theme: WommiTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => const LandingScreen(),
        '/onboarding': (context) => const OnboardingCycleDayScreen(),
        '/onboarding-step2': (context) => const OnboardingConceptionScreen(),
        '/onboarding-step3': (context) => const OnboardingStep3Screen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
