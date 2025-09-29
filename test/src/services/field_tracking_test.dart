import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/services/field_tracking.dart';

void main() {
  group('fieldTracking', () {
    late DefaultFieldTracking fieldTracking;

    setUp(() {
      fieldTracking = DefaultFieldTracking(
        fieldNames: ['email', 'password', 'age'],
      );
    });

    group('Initialization', () {
      test('should initialize all fields as untouched', () {
        expect(fieldTracking.isFieldTouched('email'), false);
        expect(fieldTracking.isFieldTouched('password'), false);
        expect(fieldTracking.isFieldTouched('age'), false);
      });

      test('should return touched fields map with all fields initially', () {
        expect(fieldTracking.touchedFields, isNotEmpty);
        expect(fieldTracking.touchedFields.length, 3);
      });

      test('should have correct field names in touched fields map', () {
        final touchedFields = fieldTracking.touchedFields;
        expect(touchedFields.keys, containsAll(['email', 'password', 'age']));
        expect(touchedFields.values, everyElement(false));
      });
    });

    group('Field Touch Operations', () {
      test('should mark single field as touched', () {
        fieldTracking.markFieldAsTouched('email');

        expect(fieldTracking.isFieldTouched('email'), true);
        expect(fieldTracking.isFieldTouched('password'), false);
        expect(fieldTracking.isFieldTouched('age'), false);
      });

      test('should mark multiple fields as touched', () {
        fieldTracking.markFieldsAsTouched(['email', 'password']);

        expect(fieldTracking.isFieldTouched('email'), true);
        expect(fieldTracking.isFieldTouched('password'), true);
        expect(fieldTracking.isFieldTouched('age'), false);
      });

      test('should mark all fields as touched', () {
        fieldTracking.markAllFieldsAsTouched();

        expect(fieldTracking.isFieldTouched('email'), true);
        expect(fieldTracking.isFieldTouched('password'), true);
        expect(fieldTracking.isFieldTouched('age'), true);
      });

      test('should ignore non-existent fields when marking as touched', () {
        fieldTracking.markFieldAsTouched('nonExistent');

        // Should not throw and should not affect existing fields
        expect(fieldTracking.isFieldTouched('email'), false);
        expect(fieldTracking.isFieldTouched('nonExistent'), false);
      });
    });

    group('Field Reset Operations', () {
      setUp(() {
        // Mark all fields as touched first
        fieldTracking.markAllFieldsAsTouched();
      });

      test('should reset single field to untouched', () {
        fieldTracking.resetFieldTouched('email');

        expect(fieldTracking.isFieldTouched('email'), false);
        expect(fieldTracking.isFieldTouched('password'), true);
        expect(fieldTracking.isFieldTouched('age'), true);
      });

      test('should reset multiple fields to untouched', () {
        fieldTracking.resetFieldsTouched(['email', 'password']);

        expect(fieldTracking.isFieldTouched('email'), false);
        expect(fieldTracking.isFieldTouched('password'), false);
        expect(fieldTracking.isFieldTouched('age'), true);
      });

      test('should reset all fields to untouched', () {
        fieldTracking.resetTouchedFields();

        expect(fieldTracking.isFieldTouched('email'), false);
        expect(fieldTracking.isFieldTouched('password'), false);
        expect(fieldTracking.isFieldTouched('age'), false);
      });

      test('should ignore non-existent fields when resetting', () {
        fieldTracking.resetFieldTouched('nonExistent');

        // Should not throw and should not affect existing fields
        expect(fieldTracking.isFieldTouched('email'), true);
        expect(fieldTracking.isFieldTouched('nonExistent'), false);
      });
    });

    group('Field Query Operations', () {
      test('should return correct touched field names', () {
        fieldTracking.markFieldsAsTouched(['email', 'age']);

        final touchedNames = fieldTracking.getTouchedFieldNames();
        expect(touchedNames, containsAll(['email', 'age']));
        expect(touchedNames, isNot(contains('password')));
      });

      test('should return correct untouched field names', () {
        fieldTracking.markFieldsAsTouched(['email', 'age']);

        final untouchedNames = fieldTracking.getUntouchedFieldNames();
        expect(untouchedNames, contains('password'));
        expect(untouchedNames, isNot(containsAll(['email', 'age'])));
      });

      test('should return empty list when no fields are touched', () {
        final touchedNames = fieldTracking.getTouchedFieldNames();
        expect(touchedNames, isEmpty);
      });

      test('should return all field names when no fields are touched', () {
        final untouchedNames = fieldTracking.getUntouchedFieldNames();
        expect(untouchedNames, containsAll(['email', 'password', 'age']));
      });
    });

    group('Field State Queries', () {
      test('should return false when no fields are touched', () {
        expect(fieldTracking.hasAnyTouchedFields(), false);
        expect(fieldTracking.areAllFieldsTouched(), false);
      });

      test('should return true when some fields are touched', () {
        fieldTracking.markFieldAsTouched('email');

        expect(fieldTracking.hasAnyTouchedFields(), true);
        expect(fieldTracking.areAllFieldsTouched(), false);
      });

      test('should return true when all fields are touched', () {
        fieldTracking.markAllFieldsAsTouched();

        expect(fieldTracking.hasAnyTouchedFields(), true);
        expect(fieldTracking.areAllFieldsTouched(), true);
      });

      test('should return false for areAllFieldsTouched when no fields exist',
          () {
        final emptyService = DefaultFieldTracking();

        expect(emptyService.areAllFieldsTouched(), false);
      });
    });

    group('Field Count Operations', () {
      test('should return correct touched fields count', () {
        expect(fieldTracking.getTouchedFieldsCount(), 0);

        fieldTracking.markFieldAsTouched('email');
        expect(fieldTracking.getTouchedFieldsCount(), 1);

        fieldTracking.markFieldAsTouched('password');
        expect(fieldTracking.getTouchedFieldsCount(), 2);
      });

      test('should return correct untouched fields count', () {
        expect(fieldTracking.getUntouchedFieldsCount(), 3);

        fieldTracking.markFieldAsTouched('email');
        expect(fieldTracking.getUntouchedFieldsCount(), 2);

        fieldTracking.markAllFieldsAsTouched();
        expect(fieldTracking.getUntouchedFieldsCount(), 0);
      });
    });

    group('Field Lifecycle Operations', () {
      test('should initialize new field as untouched', () {
        fieldTracking.initializeFieldTouchedState('newField');

        expect(fieldTracking.isFieldTouched('newField'), false);
        expect(fieldTracking.touchedFields.keys, contains('newField'));
      });

      test('should remove field touched state', () {
        fieldTracking.markFieldAsTouched('email');
        fieldTracking.removeFieldTouchedState('email');

        expect(fieldTracking.touchedFields.keys, isNot(contains('email')));
        expect(fieldTracking.isFieldTouched('email'), false);
      });

      test('should handle removing non-existent field gracefully', () {
        fieldTracking.removeFieldTouchedState('nonExistent');

        // Should not throw
        expect(fieldTracking.touchedFields.keys,
            containsAll(['email', 'password', 'age']));
      });
    });

    group('Touched Fields Map Immutability', () {
      test('should return unmodifiable touched fields map', () {
        final touchedFields = fieldTracking.touchedFields;

        expect(() => touchedFields['email'] = true,
            throwsA(isA<UnsupportedError>()));
      });
    });

    group('Edge Cases', () {
      test('should handle empty field names list', () {
        final emptyService = DefaultFieldTracking();

        expect(emptyService.touchedFields, isEmpty);
        expect(emptyService.hasAnyTouchedFields(), false);
        expect(emptyService.areAllFieldsTouched(), false);
        expect(emptyService.getTouchedFieldsCount(), 0);
        expect(emptyService.getUntouchedFieldsCount(), 0);
      });

      test('should handle duplicate field names in initialization', () {
        final serviceWithDuplicates = DefaultFieldTracking(
          fieldNames: ['email', 'email', 'password'],
        );

        // Should handle duplicates gracefully (last one wins)
        expect(serviceWithDuplicates.touchedFields.keys.length, 2);
        expect(serviceWithDuplicates.touchedFields.keys,
            containsAll(['email', 'password']));
      });
    });
  });
}
