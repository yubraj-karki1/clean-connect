import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen1.dart';
import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: OnboardingScreen1(),
    );
  }

  group('OnboardingScreen1 Widget Tests', () {
    testWidgets('renders all text elements and styling correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Clean Home'), findsOneWidget);
      expect(find.text('Clean Life.'), findsOneWidget);

      expect(find.textContaining('Book Cleaners at the Comfort'), findsOneWidget);
    });

    testWidgets('renders the main image', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Image), findsOneWidget);
      
      final imageWidget = tester.widget<Image>(find.byType(Image));
      final imageProvider = imageWidget.image as AssetImage;
      expect(imageProvider.assetName, 'assets/images/onboard.jpg');
    });

    testWidgets('renders "Next" button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
    });

    testWidgets('navigates to OnboardingScreen2 when "Next" is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final nextButton = find.widgetWithText(ElevatedButton, 'Next');

      await tester.tap(nextButton);

      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen2), findsOneWidget);
    });
  });
}