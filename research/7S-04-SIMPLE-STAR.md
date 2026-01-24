# 7S-04-SIMPLE-STAR: simple_testing


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Ecosystem Integration

### Dependencies (Incoming)
- **EiffelBase**: Core types
- **EQA Framework**: EQA_TEST_SET, EQA_COMMONLY_USED_ASSERTIONS

### Dependents (Outgoing)
- **ALL simple_* libraries**: Use for testing
- All test classes inherit TEST_SET_BASE

## Integration Patterns

### Basic Test Class
```eiffel
class MY_LIBRARY_TESTS
inherit
    TEST_SET_BASE

feature -- Tests

    test_positive_value
        do
            assert_positive ("result", my_function)
        end

    test_string_content
        do
            assert_string_contains ("output", result, "expected")
        end
end
```

### Accessing Internal Features
```eiffel
class MY_LIBRARY_TESTS
inherit
    TEST_SET_BASE
    TEST_SET_BRIDGE  -- Grants access to {TEST_SET_BRIDGE} features

feature -- Tests

    test_internal
        local
            obj: MY_CLASS
        do
            create obj
            -- Can now call obj.internal_feature if exported to TEST_SET_BRIDGE
        end
end
```

## Ecosystem Fit

- Foundation testing library
- Used by all simple_* test suites
- Standard assertion vocabulary
