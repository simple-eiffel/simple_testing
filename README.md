# simple_testing

Enhanced test framework for Eiffel with comprehensive assertions.

## Overview

`simple_testing` provides a rich set of assertion methods that extend the standard EQA_TEST_SET framework. Inherit from TEST_SET_BASE to get access to 40+ assertion methods for booleans, numbers, strings, collections, and object references.

## Features

- **Boolean Assertions**: `assert_true`, `assert_false`, `refute`
- **Object/Reference Assertions**: `assert_attached`, `assert_void`, `assert_same_reference`, `assert_not_same_reference`
- **Equality Assertions**: `assert_equal`, `assert_not_equal`
- **Integer Assertions**: `assert_integers_equal`, `assert_greater_than`, `assert_less_than`, `assert_in_range`, `assert_positive`, `assert_negative`, `assert_zero`, `assert_non_zero`, `assert_non_negative`, `assert_non_positive`
- **Real Assertions**: `assert_reals_equal` (with epsilon), `assert_real_greater_than`, `assert_real_less_than`, `assert_real_in_range`
- **String Assertions**: `assert_string_contains`, `assert_string_not_contains`, `assert_string_starts_with`, `assert_string_ends_with`, `assert_string_empty`, `assert_string_not_empty`, `assert_string_length`, `assert_strings_equal_case_insensitive`, `assert_strings_equal_diff`
- **Collection Assertions**: `assert_array_has_item`, `assert_array_not_has_item`, `assert_iterable_is_empty`, `assert_iterable_not_empty`, `assert_count_equals`
- **NATURAL_64 Assertions**: `assert_naturals_equal`

## Installation

1. Set the ecosystem environment variable (one-time setup for all simple_* libraries):
   ```
   SIMPLE_EIFFEL=D:\prod
   ```

2. Add to your ECF file:
   ```xml
   <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
   ```

## Usage

### Basic Test Class

```eiffel
class
    MY_TEST_SET

inherit
    TEST_SET_BASE

feature -- Tests

    test_example
        do
            -- Boolean assertions
            assert_true ("condition_met", some_condition)
            assert_false ("should_not_happen", bad_condition)

            -- Numeric assertions
            assert_positive ("count_positive", my_list.count)
            assert_in_range ("valid_index", index, 1, 100)
            assert_integers_equal ("expected_count", 5, actual_count)

            -- String assertions
            assert_string_contains ("has_error", output, "ERROR")
            assert_string_starts_with ("header", response, "HTTP/1.1")
            assert_string_not_empty ("has_content", body)

            -- Object assertions
            assert_attached ("result_exists", result)
            assert_void ("should_be_void", optional_value)

            -- Collection assertions
            assert_count_equals ("list_size", 3, my_list)
            assert_iterable_not_empty ("has_items", my_collection)
        end

end
```

### Using TEST_SET_BRIDGE for {NONE} Access

When you need to test features exported to {NONE}:

1. In your library class, export to TEST_SET_BRIDGE:
   ```eiffel
   feature {TEST_SET_BRIDGE} -- Test access

       internal_state: INTEGER
   ```

2. In your test class, inherit from both:
   ```eiffel
   class
       MY_TEST_SET

   inherit
       TEST_SET_BASE
       TEST_SET_BRIDGE

   feature -- Tests

       test_internal_state
           local
               obj: MY_CLASS
           do
               create obj.make
               -- Now we can access internal_state
               assert_positive ("state_valid", obj.internal_state)
           end

   end
   ```

### String Diff for Detailed Comparison

When comparing strings, use `assert_strings_equal_diff` for detailed character-by-character comparison on failure:

```eiffel
test_output_format
    do
        assert_strings_equal_diff ("output_matches", expected_output, actual_output)
    end
```

On failure, this shows:
- Expected and actual string lengths
- Position of first difference
- Character-by-character comparison with character codes
- Special character visualization (\n, \r, \t, etc.)

## Classes

| Class | Description |
|-------|-------------|
| TEST_SET_BASE | Deferred base class with 40+ assertion methods |
| TEST_SET_BRIDGE | Bridge class for accessing {NONE} exported features |

## Dependencies

- EiffelBase
- EiffelTesting

## Documentation

See the [docs](docs/index.html) folder for detailed API documentation.

## License

MIT License

## Author

Larry Rix
