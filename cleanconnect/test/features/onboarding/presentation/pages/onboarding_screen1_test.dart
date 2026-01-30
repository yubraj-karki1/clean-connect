import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen1.dart';
import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper method to create the widget under test wrapped in a MaterialApp.
  /// We need MaterialApp because Scaffold and Navigator rely on it.
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: OnboardingScreen1(),
    );
  }

  group('OnboardingScreen1 Widget Tests', () {
    testWidgets('renders all text elements and styling correctly',
        (WidgetTester tester) async {
      // 1. Build the widget
      await tester.pumpWidget(createWidgetUnderTest());

      // 2. Verify Title Texts exist
      expect(find.text('Clean Home'), findsOneWidget);
      expect(find.text('Clean Life.'), findsOneWidget);

      // 3. Verify Subtitle Text exists
      // We use find.textContaining to avoid issues with line breaks (\n)
      expect(find.textContaining('Book Cleaners at the Comfort'), findsOneWidget);
    });

    testWidgets('renders the main image', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify that an Image widget is present in the tree
      expect(find.byType(Image), findsOneWidget);
      
      // Optional: Verify specific asset name (if you want to be strict)
      final imageWidget = tester.widget<Image>(find.byType(Image));
      final imageProvider = imageWidget.image as AssetImage;
      expect(imageProvider.assetName, 'assets/images/onboard.jpg');
    });

    testWidgets('renders "Next" button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify ElevatedButton exists with the text "Next"
      expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
    });

    testWidgets('navigates to OnboardingScreen2 when "Next" is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Find the Next button
      final nextButton = find.widgetWithText(ElevatedButton, 'Next');

      // 2. Perform a tap event
      await tester.tap(nextButton);

      // 3. Rebuild the widget after the state has changed.
      // pumpAndSettle waits for the navigation animation to finish.
      await tester.pumpAndSettle();

      // 4. Verify that OnboardingScreen2 is now currently in the view
      expect(find.byType(OnboardingScreen2), findsOneWidget);
    });
  });
}