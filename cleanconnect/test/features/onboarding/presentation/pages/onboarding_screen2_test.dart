import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen2.dart';
import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: OnboardingScreen2(),
    );
  }

  group('OnboardingScreen2 Widget Tests', () {
    testWidgets('renders specific text elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Dust-Free'), findsOneWidget);
      expect(find.text('Worry-Free.'), findsOneWidget);

      expect(find.textContaining('Where cleanliness'), findsOneWidget);
      expect(find.textContaining('meets comfort.'), findsOneWidget);
    });

    testWidgets('renders the specific illustration image', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final imageProvider = imageWidget.image as AssetImage;
      expect(imageProvider.assetName, 'assets/images/onboard1.jpg');
    });

    testWidgets('navigates to OnboardingScreen3 on "Next" tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final nextButton = find.widgetWithText(ElevatedButton, 'Next');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen3), findsOneWidget);
    });
  });
}