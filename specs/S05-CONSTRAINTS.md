# S05-CONSTRAINTS: simple_testing

**BACKWASH** | Date: 2026-01-23

## Technical Constraints

### Inheritance Constraints
- TEST_SET_BASE is deferred (cannot instantiate directly)
- Must inherit from TEST_SET_BASE for tests
- TEST_SET_BRIDGE is optional, for internal access only

### Type Constraints
- Assertions use READABLE_STRING_GENERAL for tags
- Integer assertions use INTEGER_32 or INTEGER
- Real assertions use REAL_64
- Collection assertions use ITERABLE or FINITE

### Epsilon Constraint
- assert_reals_equal requires epsilon >= 0.0
- Caller determines appropriate epsilon for use case

### Range Constraints
- assert_in_range requires min <= max
- assert_real_in_range requires min <= max

## Design Constraints

### Message Format
- All assertions build detailed error messages
- Format: "tag: expected X, got Y" or similar
- Uses STRING_32 for Unicode support

### Assertion Behavior
- All assertions call inherited `assert` method
- Postconditions document what was verified
- Failure stops test execution (EQA behavior)

### Bridge Pattern
- TEST_SET_BRIDGE must be inherited for internal access
- Tested class must export features to TEST_SET_BRIDGE
- No runtime overhead, purely compile-time access control
