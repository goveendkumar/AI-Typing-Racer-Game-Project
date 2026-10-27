import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:find_your_calm/main.dart';
import 'package:find_your_calm/features/splash/splash_screen.dart';
import 'package:find_your_calm/features/onboarding/onboarding_screen.dart';

void main() {
  sqfliteFfiInit();

  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App renders Find Your Calm app root', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FindYourCalmApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Find Your Calm'), findsOneWidget);
  });

  testWidgets('Splash screen displays title and branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SplashScreen(onInitialized: () {}),
        ),
      ),
    );
    expect(find.text('Find Your Calm'), findsOneWidget);
    expect(find.text('Mindfulness & Simple Meditation'), findsOneWidget);
  });

  testWidgets('Onboarding screen steps and duration selection render', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(onOnboardingCompleted: () {}),
        ),
      ),
    );
    expect(find.text('Find a Moment of Calm'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
