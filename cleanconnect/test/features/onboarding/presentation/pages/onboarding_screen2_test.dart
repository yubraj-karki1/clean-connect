import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen2.dart';
import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper to create the widget under test
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: OnboardingScreen2(),
    );
  }

  group('OnboardingScreen2 Widget Tests', () {
    testWidgets('renders specific text elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Verify Main Titles
      expect(find.text('Dust-Free'), findsOneWidget);
      expect(find.text('Worry-Free.'), findsOneWidget);

      // 2. Verify Subtitle
      // Using find.textContaining handles the new line character easily
      expect(find.textContaining('Where cleanliness'), findsOneWidget);
      expect(find.textContaining('meets comfort.'), findsOneWidget);
    });

    testWidgets('renders the specific illustration image', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify the image widget exists
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      // Verify the correct asset path is being used
      final imageWidget = tester.widget<Image>(imageFinder);
      final imageProvider = imageWidget.image as AssetImage;
      expect(imageProvider.assetName, 'assets/images/onboard1.jpg');
    });

    testWidgets('navigates to OnboardingScreen3 on "Next" tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Find the "Next" button
      final nextButton = find.widgetWithText(ElevatedButton, 'Next');
      expect(nextButton, findsOneWidget);

      // 2. Tap the button
      await tester.tap(nextButton);

      // 3. Wait for the navigation animation to settle
      await tester.pumpAndSettle();

      // 4. Verify that OnboardingScreen3 is pushed onto the stack
      expect(find.byType(OnboardingScreen3), findsOneWidget);
    });
  });
}