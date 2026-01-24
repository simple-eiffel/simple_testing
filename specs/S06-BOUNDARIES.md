# S06-BOUNDARIES: simple_testing

**BACKWASH** | Date: 2026-01-23

## System Boundaries

### External Dependencies

```
+----------------+     +------------------+     +---------------+
| Test Classes   | --> | simple_testing   | --> | EQA Framework |
+----------------+     +------------------+     +---------------+
```

### Inheritance Boundary

```
EQA_TEST_SET
      |
EQA_COMMONLY_USED_ASSERTIONS
      |
TEST_SET_BASE (deferred)
      |
+-----+-----+
|           |
v           v
MY_TESTS   OTHER_TESTS
```

### API Boundary

**Public API** (TEST_SET_BASE):
- 40+ assertion methods
- All take tag + values to assert

**Internal API** ({NONE}):
- String diff implementation helpers
- Message building helpers

**Bridge API** (TEST_SET_BRIDGE):
- test_folder query
- Export target for internal features

## Data Type Boundaries

| Parameter | Eiffel Type | Notes |
|-----------|-------------|-------|
| tag | READABLE_STRING_GENERAL | Test identification |
| boolean | BOOLEAN | Condition to test |
| object | detachable ANY | Reference checks |
| integer | INTEGER_32 | Numeric checks |
| real | REAL_64 | Float checks |
| string | READABLE_STRING_GENERAL | String checks |
| collection | ITERABLE/FINITE | Collection checks |

## Responsibility Boundaries

### simple_testing Responsible For:
- Rich assertion methods
- Detailed failure messages
- Internal access bridge pattern

### EQA Responsible For:
- Test discovery and execution
- Test fixtures
- Pass/fail reporting

### Test Class Responsible For:
- Test method implementation
- Test data setup
- Expected value definition
