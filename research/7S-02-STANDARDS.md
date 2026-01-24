# 7S-02-STANDARDS: simple_testing


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Language Standards

- **Eiffel**: ECMA-367 compliant
- **EQA**: EiffelStudio EQA framework extension

## Testing Standards

- Inherit from TEST_SET_BASE instead of EQA_TEST_SET
- Use TEST_SET_BRIDGE for internal feature access
- All assertions provide detailed failure messages
- Assertions include postconditions documenting behavior

## Simple Eiffel Ecosystem Standards

- Design by Contract (DBC) on all assertion features
- Void safety enabled
- Postconditions on all assertions
- Consistent naming: assert_* prefix for assertions

## Assertion Naming Conventions

| Pattern | Purpose |
|---------|---------|
| assert_X | Assert X is true |
| assert_not_X | Assert X is false |
| refute | Alias for assert_false |
| assert_X_equal | Assert equality |
| assert_X_in_range | Assert within bounds |

## Message Format Standards

All assertions produce messages with:
- Tag from caller
- Expected value/condition
- Actual value/result
- Context for debugging

Example: `"my_test: expected 5, got 3"`

## Inheritance Pattern

```eiffel
class MY_TESTS
inherit
    TEST_SET_BASE
    TEST_SET_BRIDGE  -- Optional, for internal access
feature
    test_something
        do
            assert_positive ("count", my_value)
        end
end
```
