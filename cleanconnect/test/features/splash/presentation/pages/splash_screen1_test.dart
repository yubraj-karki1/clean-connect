import 'package:cleanconnect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen1.dart';
// Update this import to point to your actual SplashScreen1 file location
import 'package:cleanconnect/features/splash/presentation/pages/splash_screen1.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SplashScreen1 Widget Tests', () {
    
    testWidgets('UI renders correctly (Logo checks)', (WidgetTester tester) async {
  // 1. Setup Mock
  SharedPreferences.setMockInitialValues({});
  
  // 2. Build Widget
  await tester.pumpWidget(const MaterialApp(home: SplashScreen1()));

  // 3. Verify Logo (The actual test)
  final imageFinder = find.byType(Image);
  expect(imageFinder, findsOneWidget);

  final imageWidget = tester.widget<Image>(imageFinder);
  final imageProvider = imageWidget.image as AssetImage;
  expect(imageProvider.assetName, 'assets/images/image1.jpg');

  // -----------------------------------------------------------
  // 4. CRITICAL FIX: Drain the Timer
  // We must let the 3 seconds pass so the pending timer doesn't crash the test.
  // -----------------------------------------------------------
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle(); // Let the resulting navigation finish
});

    testWidgets('Navigates to OnboardingScreen1 when NO token exists', (WidgetTester tester) async {
      // 1. Mock SharedPreferences with empty values (User is NOT logged in)
      SharedPreferences.setMockInitialValues({}); 

      await tester.pumpWidget(const MaterialApp(home: SplashScreen1()));

      // 2. Fast-forward time by 3 seconds (plus a little buffer)
      // This forces the Future.delayed in your code to complete immediately
      await tester.pump(const Duration(seconds: 3));
      
      // 3. Wait for the navigation animation to finish
      await tester.pumpAndSettle();

      // 4. Verify we are now at OnboardingScreen1
      expect(find.byType(OnboardingScreen1), findsOneWidget);
      // Ensure we are NO LONGER at SplashScreen
      expect(find.byType(SplashScreen1), findsNothing);
    });

    testWidgets('Navigates to DashboardScreen when token EXISTS', (WidgetTester tester) async {
      // 1. Mock SharedPreferences WITH a fake token (User IS logged in)
      SharedPreferences.setMockInitialValues({
        'auth_token': 'fake_access_token_123',
      });

      await tester.pumpWidget(const MaterialApp(home: SplashScreen1()));

      // 2. Fast-forward time by 3 seconds
      await tester.pump(const Duration(seconds: 3));
      
      // 3. Wait for navigation animation
      await tester.pumpAndSettle();

      // 4. Verify we are now at DashboardScreen
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}