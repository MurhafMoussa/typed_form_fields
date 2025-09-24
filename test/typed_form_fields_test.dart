import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'src/core/core_form_cubit_test.dart' as core_form_cubit_tests;
import 'src/models/core_form_state_test.dart' as core_form_state_tests;
import 'src/services/form_debounced_validation_service_test.dart'
    as form_debounced_validation_service_tests;
import 'src/services/form_field_manager_test.dart' as form_field_manager_tests;
import 'src/services/form_state_computer_test.dart'
    as form_state_computer_tests;
import 'src/services/form_validation_service_test.dart'
    as form_validation_service_tests;
import 'src/validators/composite_validator_test.dart'
    as composite_validator_tests;
import 'src/validators/validator_test.dart' as validator_tests;

void main() {
  group('TypedFormFields Package Tests', () {
    group('Core Tests', () {
      core_form_cubit_tests.main();
    });

    group('Models Tests', () {
      core_form_state_tests.main();
    });

    group('Services Tests', () {
      form_validation_service_tests.main();
      form_field_manager_tests.main();
      form_debounced_validation_service_tests.main();
      form_state_computer_tests.main();
    });

    group('Validators Tests', () {
      validator_tests.main();
      composite_validator_tests.main();
    });


  });
}
