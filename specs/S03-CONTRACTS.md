# S03-CONTRACTS: simple_testing

**BACKWASH** | Date: 2026-01-23

## TEST_SET_BASE Contracts

### Boolean Assertions

```eiffel
refute (a_tag: READABLE_STRING_GENERAL; a_condition: BOOLEAN)
    ensure
        condition_was_false: not a_condition

assert_true (a_tag: READABLE_STRING_GENERAL; a_condition: BOOLEAN)
    ensure
        condition_was_true: a_condition

assert_false (a_tag: READABLE_STRING_GENERAL; a_condition: BOOLEAN)
    ensure
        condition_was_false: not a_condition
```

### Object Assertions

```eiffel
assert_attached (a_tag: READABLE_STRING_GENERAL; object: detachable ANY)
    ensure then
        object_attached: object /= Void

assert_void (a_tag: READABLE_STRING_GENERAL; object: detachable ANY)
    ensure then
        object_void: object = Void

assert_same_reference (a_tag: ...; a_expected, a_actual: ANY)
    ensure
        same_reference: a_expected = a_actual
```

### Numeric Assertions

```eiffel
assert_in_range (a_tag: ...; a_value, a_min, a_max: INTEGER)
    require
        valid_range: a_min <= a_max
    ensure
        value_in_range: a_value >= a_min and a_value <= a_max

assert_reals_equal (a_tag: ...; a_expected, a_actual, a_epsilon: REAL_64)
    require
        epsilon_non_negative: a_epsilon >= 0.0
    ensure
        within_epsilon: (a_expected - a_actual).abs <= a_epsilon
```

### String Assertions

```eiffel
assert_string_contains (a_tag: ...; a_string, a_substring: READABLE_STRING_GENERAL)
    ensure
        contains_substring: a_string.has_substring (a_substring)

assert_string_empty (a_tag: ...; a_string: READABLE_STRING_GENERAL)
    ensure
        string_is_empty: a_string.is_empty
```

### Collection Assertions

```eiffel
assert_count_equals (a_tag: ...; a_expected: INTEGER; a_collection: FINITE [...])
    ensure
        count_matches: a_collection.count = a_expected
```
