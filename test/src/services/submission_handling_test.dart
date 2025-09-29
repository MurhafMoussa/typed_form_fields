import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/services/submission_handling.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('SubmissionHandling', () {
    late SubmissionHandling submissionHandler;
    late BuildContext context;

    setUp(() {
      submissionHandler = DefaultSubmissionHandling();
    });

    testWidgets('should initialize with default state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return Container();
              },
            ),
          ),
        ),
      );

      final initialState = submissionHandler.getInitialSubmissionState();

      expect(initialState.isSubmitting, isFalse);
      expect(initialState.submissionAttempts, 0);
      expect(initialState.lastSubmissionResult, isNull);
    });

    group('Form Submission Workflow', () {
      testWidgets('should handle successful form submission',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = submissionHandler.submitForm(
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldProceedWithSubmission, isTrue);
        expect(result.submissionState.isSubmitting, isTrue);
        expect(result.submissionState.submissionAttempts, 1);
      });

      testWidgets('should handle failed form submission',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = submissionHandler.submitForm(
          currentValues: {'email': '', 'password': ''}, // Invalid values
          currentErrors: {'email': 'Email is required'},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldProceedWithSubmission, isFalse);
        expect(result.submissionState.isSubmitting, isFalse);
        expect(result.submissionState.submissionAttempts, 1);
        expect(result.submissionState.lastSubmissionResult,
            FormSubmissionResult.validationFailed);
      });

      testWidgets('should handle submission with validation disabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = submissionHandler.submitFormWithValidationDisabled(
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldProceedWithSubmission, isTrue);
        expect(result.submissionState.isSubmitting, isTrue);
        expect(result.submissionState.submissionAttempts, 1);
      });
    });

    group('Submission State Management', () {
      testWidgets('should track submission attempts',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        // First submission attempt
        final result1 = submissionHandler.submitForm(
          currentValues: {'email': '', 'password': ''},
          currentErrors: {'email': 'Email is required'},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result1.submissionState.submissionAttempts, 1);

        // Second submission attempt
        final result2 = submissionHandler.submitForm(
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result2.submissionState.submissionAttempts, 2);
      });

      testWidgets('should track submission results',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        // Failed submission
        final failedResult = submissionHandler.submitForm(
          currentValues: {'email': '', 'password': ''},
          currentErrors: {'email': 'Email is required'},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(failedResult.submissionState.lastSubmissionResult,
            FormSubmissionResult.validationFailed);

        // Successful submission
        final successResult = submissionHandler.submitForm(
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(successResult.submissionState.lastSubmissionResult,
            FormSubmissionResult.validationPassed);
      });

      testWidgets('should reset submission state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        // Submit form to change state
        submissionHandler.submitForm(
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        // Reset state
        final resetState = submissionHandler.resetSubmissionState();

        expect(resetState.isSubmitting, isFalse);
        expect(resetState.submissionAttempts, 0);
        expect(resetState.lastSubmissionResult, isNull);
      });
    });

    group('Callback Execution', () {
      testWidgets(
          'should execute onValidationPass callback on successful validation',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        bool onValidationPassCalled = false;
        bool onValidationFailCalled = false;

        submissionHandler.submitForm(
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () => onValidationPassCalled = true,
          onValidationFail: () => onValidationFailCalled = true,
        );

        expect(onValidationPassCalled, isTrue);
        expect(onValidationFailCalled, isFalse);
      });

      testWidgets(
          'should execute onValidationFail callback on failed validation',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        bool onValidationPassCalled = false;
        bool onValidationFailCalled = false;

        submissionHandler.submitForm(
          currentValues: {'email': '', 'password': ''},
          currentErrors: {'email': 'Email is required'},
          context: context,
          onValidationPass: () => onValidationPassCalled = true,
          onValidationFail: () => onValidationFailCalled = true,
        );

        expect(onValidationPassCalled, isFalse);
        expect(onValidationFailCalled, isTrue);
      });

      testWidgets('should handle null onValidationFail callback gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        bool onValidationPassCalled = false;

        // This should not throw an error even with null onValidationFail
        final result = submissionHandler.submitForm(
          currentValues: {'email': '', 'password': ''},
          currentErrors: {'email': 'Email is required'},
          context: context,
          onValidationPass: () => onValidationPassCalled = true,
          onValidationFail: null, // Null callback
        );

        expect(result.shouldProceedWithSubmission, isFalse);
        expect(onValidationPassCalled, isFalse);
      });
    });

    group('Submission Result Processing', () {
      testWidgets('should determine submission success based on validation',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        // Test successful submission
        final successResult = submissionHandler.submitForm(
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(successResult.submissionState.lastSubmissionResult,
            FormSubmissionResult.validationPassed);
        expect(successResult.shouldProceedWithSubmission, isTrue);

        // Test failed submission
        final failedResult = submissionHandler.submitForm(
          currentValues: {'email': '', 'password': ''},
          currentErrors: {'email': 'Email is required'},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(failedResult.submissionState.lastSubmissionResult,
            FormSubmissionResult.validationFailed);
        expect(failedResult.shouldProceedWithSubmission, isFalse);
      });

      testWidgets('should handle submission with empty form',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = submissionHandler.submitForm(
          currentValues: {},
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldProceedWithSubmission, isTrue);
        expect(result.submissionState.lastSubmissionResult,
            FormSubmissionResult.validationPassed);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle submission with null values',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = submissionHandler.submitForm(
          currentValues: {'email': null, 'password': null},
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.submissionState.submissionAttempts, 1);
        expect(result.submissionState.isSubmitting, isTrue);
      });

      testWidgets(
          'should handle submission with mixed valid and invalid fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = submissionHandler.submitForm(
          currentValues: {
            'email': 'test@example.com',
            'password': ''
          }, // Mixed validity
          currentErrors: {'password': 'Password is required'},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldProceedWithSubmission, isFalse);
        expect(result.submissionState.lastSubmissionResult,
            FormSubmissionResult.validationFailed);
      });
    });
  });
}

// Mock validator for testing
class MockValidator<T> extends Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    if (value == null || value.toString().isEmpty) {
      return 'Field is required';
    }
    return null;
  }
}
