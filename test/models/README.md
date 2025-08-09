# Model Unit Tests Summary

This directory contains comprehensive unit tests for the Vocab and ReviewLog models, covering all aspects requested in Step 7 of the project plan.

## Test Coverage

### ✅ JSON (De)Serialization
- **toMap()** method testing with all fields and null values
- **fromMap()** method testing with complete and incomplete data
- Round-trip serialization testing (toMap → fromMap → equals original)
- DateTime to milliseconds conversion and back
- Boolean to integer conversion for database storage
- Edge cases with extreme values and special characters

### ✅ Default Values
- Constructor default values (easiness: 2.5, repetitions: 0, intervalDays: 0, favorite: false)
- fromMap() default value fallbacks using null-coalescing operator (??)
- Testing both implicit and explicit default value scenarios

### ✅ Required Fields
- Constructor validation of required fields
- Error handling for missing required fields in fromMap()
- Type safety testing with invalid data types

### ✅ Error Cases
- Missing required fields handling
- Invalid timestamp handling
- Type mismatch scenarios
- Null safety edge cases

### ✅ Equality Overrides
- **operator ==** testing for identical objects
- **operator ==** testing for objects with same values
- **operator ==** testing for objects with different values
- **hashCode** consistency testing
- Type safety (non-Vocab objects return false)
- Null field difference detection
- DateTime precision difference detection

### ✅ copyWith Method
- No-parameter copyWith returns equal but different instance
- Single field updates preserve other fields
- Multiple field updates
- Null parameter handling (preserves original values due to ?? operator)
- Non-destructive copying (original object unchanged)
- Converting null fields to non-null values

## Files

### `vocab_model_test.dart`
Comprehensive tests for the `Vocab` class with 29 test cases covering:
- Constructor and default values (2 tests)
- JSON serialization - toMap() (3 tests)
- JSON deserialization - fromMap() (3 tests)
- Round-trip serialization (2 tests)
- Equality override (6 tests)
- copyWith method (5 tests)
- toString method (2 tests)
- Error cases (2 tests)
- Edge cases (4 tests)

### `review_log_model_test.dart`
Comprehensive tests for the `ReviewLog` class with 39 test cases covering:
- Constructor and required fields (2 tests)
- JSON serialization - toMap() (3 tests)
- JSON deserialization - fromMap() (3 tests)
- Round-trip serialization (3 tests)
- Equality override (8 tests)
- copyWith method (6 tests)
- toString method (2 tests)
- Error cases (3 tests)
- Edge cases (5 tests)
- Grade validation context (2 tests)
- SM-2 algorithm specific testing (grades 0-5)

## Model Enhancements

As part of this testing effort, the following methods were added to both models:

### Vocab Model
```dart
// Equality and hashing
@override bool operator ==(Object other)
@override int get hashCode
@override String toString()

// Immutable copying
Vocab copyWith({...})
```

### ReviewLog Model
```dart
// Equality and hashing
@override bool operator ==(Object other)
@override int get hashCode
@override String toString()

// Immutable copying
ReviewLog copyWith({...})
```

## Key Testing Insights

1. **copyWith Behavior**: The current implementation uses null-coalescing operator (`??`), which means passing `null` preserves the original value rather than setting it to null. This is documented in test comments.

2. **DateTime Precision**: Tests verify that millisecond precision is preserved through serialization/deserialization cycles.

3. **Boolean Storage**: Tests confirm proper boolean→int conversion for SQLite storage (true→1, false→0).

4. **SM-2 Algorithm**: ReviewLog tests include specific validation for SM-2 spaced repetition grades (0-5 valid range).

5. **Edge Cases**: Comprehensive testing of extreme values, empty strings, special characters, future dates, and negative numbers.

## Test Results

- **Total Test Cases**: 68
- **All Tests Passing**: ✅
- **Coverage**: Complete coverage of all requested features
- **Integration**: Tests work alongside existing project tests (124 total tests passing)

This comprehensive test suite ensures robust model behavior and catches regression issues during future development.
