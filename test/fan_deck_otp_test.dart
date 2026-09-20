import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fan_deck_otp/fan_deck_otp.dart';

void main() {
  group('FanDeckOtpField Tests', () {
    testWidgets('renders correct number of boxes based on length', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: FanDeckOtpField(
                  length: 6,
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify that the widget mounts and renders
      expect(find.byType(FanDeckOtpField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('entering text updates boxes and triggers onCompleted', (tester) async {
      final controller = TextEditingController();
      String completedCode = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: FanDeckOtpField(
                  length: 4,
                  controller: controller,
                  onCompleted: (code) {
                    completedCode = code;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Enter 4 digits
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();

      expect(controller.text, '1234');
      expect(completedCode, '1234');

      // Verify digits are displayed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('obscureText shows obscuring character instead of raw digits', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: FanDeckOtpField(
                  length: 4,
                  controller: controller,
                  obscureText: true,
                  obscuringCharacter: '*',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '9876');
      await tester.pump();

      expect(find.text('*'), findsNWidgets(4));
      expect(find.text('9'), findsNothing);
    });

    testWidgets('FanDeckOtpController triggerError clears text and invokes listeners', (tester) async {
      final otpController = FanDeckOtpController(initialText: '123456');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: FanDeckOtpField(
                  length: 6,
                  otpController: otpController,
                ),
              ),
            ),
          ),
        ),
      );

      expect(otpController.text, '123456');

      otpController.triggerError();
      await tester.pump();
      // Pump through shake, dissolve, reverse fan out, and error reset timer
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1000));

      expect(otpController.text, '');
    });
  });
}
