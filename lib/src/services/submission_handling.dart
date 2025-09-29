import 'package:flutter/widgets.dart';

/// Result of form submission
enum FormSubmissionResult {
  validationPassed,
  validationFailed,
  submissionInProgress,
}

/// State of form submission
class SubmissionHandlingState {
  final bool isSubmitting;
  final int submissionAttempts;
  final FormSubmissionResult? lastSubmissionResult;

  const SubmissionHandlingState({
    required this.isSubmitting,
    required this.submissionAttempts,
    this.lastSubmissionResult,
  });

  SubmissionHandlingState copyWith({
    bool? isSubmitting,
    int? submissionAttempts,
    FormSubmissionResult? lastSubmissionResult,
  }) {
    return SubmissionHandlingState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionAttempts: submissionAttempts ?? this.submissionAttempts,
      lastSubmissionResult: lastSubmissionResult ?? this.lastSubmissionResult,
    );
  }
}

/// Result of form submission operation
class SubmissionHandlingResult {
  final bool shouldProceedWithSubmission;
  final SubmissionHandlingState submissionState;

  const SubmissionHandlingResult({
    required this.shouldProceedWithSubmission,
    required this.submissionState,
  });
}

/// Interface for managing form submission operations
abstract class SubmissionHandling {
  /// Get initial submission state
  SubmissionHandlingState getInitialSubmissionState();

  /// Submit form with validation
  SubmissionHandlingResult submitForm({
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
    required VoidCallback onValidationPass,
    required VoidCallback? onValidationFail,
  });

  /// Submit form without validation (validation disabled)
  SubmissionHandlingResult submitFormWithValidationDisabled({
    required Map<String, Object?> currentValues,
    required BuildContext context,
    required VoidCallback onValidationPass,
    required VoidCallback? onValidationFail,
  });

  /// Reset submission state
  SubmissionHandlingState resetSubmissionState();
}

/// Default implementation of FormSubmissionService
class DefaultSubmissionHandling implements SubmissionHandling {
  SubmissionHandlingState _currentState = const SubmissionHandlingState(
    isSubmitting: false,
    submissionAttempts: 0,
  );
  DefaultSubmissionHandling();

  @override
  SubmissionHandlingState getInitialSubmissionState() {
    return _currentState;
  }

  @override
  SubmissionHandlingResult submitForm({
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
    required VoidCallback onValidationPass,
    required VoidCallback? onValidationFail,
  }) {
    // Note: fieldService access removed as it's not needed for submission logic
    // Update submission state
    _currentState = _currentState.copyWith(
      isSubmitting: true,
      submissionAttempts: _currentState.submissionAttempts + 1,
    );

    // Check if form is valid (no errors)
    final isValid = currentErrors.isEmpty;

    if (isValid) {
      // Execute success callback
      onValidationPass();

      _currentState = _currentState.copyWith(
        lastSubmissionResult: FormSubmissionResult.validationPassed,
      );

      return SubmissionHandlingResult(
        shouldProceedWithSubmission: true,
        submissionState: _currentState,
      );
    } else {
      // Execute failure callback
      onValidationFail?.call();

      _currentState = _currentState.copyWith(
        isSubmitting: false,
        lastSubmissionResult: FormSubmissionResult.validationFailed,
      );

      return SubmissionHandlingResult(
        shouldProceedWithSubmission: false,
        submissionState: _currentState,
      );
    }
  }

  @override
  SubmissionHandlingResult submitFormWithValidationDisabled({
    required Map<String, Object?> currentValues,
    required BuildContext context,
    required VoidCallback onValidationPass,
    required VoidCallback? onValidationFail,
  }) {
    // Note: fieldService access removed as it's not needed for submission logic
    // Update submission state
    _currentState = _currentState.copyWith(
      isSubmitting: true,
      submissionAttempts: _currentState.submissionAttempts + 1,
    );

    // Always proceed with submission when validation is disabled
    onValidationPass();

    _currentState = _currentState.copyWith(
      lastSubmissionResult: FormSubmissionResult.validationPassed,
    );

    return SubmissionHandlingResult(
      shouldProceedWithSubmission: true,
      submissionState: _currentState,
    );
  }

  @override
  SubmissionHandlingState resetSubmissionState() {
    _currentState = const SubmissionHandlingState(
      isSubmitting: false,
      submissionAttempts: 0,
    );
    return _currentState;
  }
}
