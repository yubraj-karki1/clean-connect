import 'package:cleanconnect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen1.dart';
import 'package:cleanconnect/features/splash/presentation/pages/splash_screen1.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SplashScreen1 Widget Tests', () {
    
    testWidgets('UI renders correctly (Logo checks)', (WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  
  await tester.pumpWidget(const MaterialApp(home: SplashScreen1()));

  final imageFinder = find.byType(Image);
  expect(imageFinder, findsOneWidget);

  final imageWidget = tester.widget<Image>(imageFinder);
  final imageProvider = imageWidget.image as AssetImage;
  expect(imageProvider.assetName, 'assets/images/image1.jpg');

  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle(); 
});

    testWidgets('Navigates to OnboardingScreen1 when NO token exists', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({}); 
      await tester.pumpWidget(const MaterialApp(home: SplashScreen1()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen1), findsOneWidget);
      expect(find.byType(SplashScreen1), findsNothing);
    });

    testWidgets('Navigates to DashboardScreen when token EXISTS', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'fake_access_token_123',
      });
      await tester.pumpWidget(const MaterialApp(home: SplashScreen1()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}