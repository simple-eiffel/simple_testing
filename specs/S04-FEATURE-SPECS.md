# S04-FEATURE-SPECS: simple_testing

**BACKWASH** | Date: 2026-01-23

## TEST_SET_BASE Features

### Boolean Assertions

| Feature | Signature | Description |
|---------|-----------|-------------|
| refute | (tag, condition: BOOLEAN) | Assert false |
| assert_true | (tag, condition: BOOLEAN) | Assert true |
| assert_false | (tag, condition: BOOLEAN) | Assert false |

### Object/Reference Assertions

| Feature | Signature | Description |
|---------|-----------|-------------|
| assert_attached | (tag, object: detachable ANY) | Not Void |
| assert_void | (tag, object: detachable ANY) | Is Void |
| assert_same_reference | (tag, expected, actual: ANY) | Same object (=) |
| assert_not_same_reference | (tag, expected, actual: ANY) | Different objects |

### Equality Assertions

| Feature | Signature | Description |
|---------|-----------|-------------|
| assert_equal | (tag, expected, actual: detachable ANY) | is_equal |
| assert_not_equal | (tag, expected, actual: detachable ANY) | not is_equal |
| assert_integers_equal | (tag, expected, actual: INTEGER_32) | Integers equal |
| assert_naturals_equal | (tag, expected, actual: NATURAL_64) | Naturals equal |

### Integer Comparison Assertions

| Feature | Signature | Description |
|---------|-----------|-------------|
| assert_greater_than | (tag, value, threshold: INTEGER) | value > threshold |
| assert_greater_or_equal | (tag, value, threshold: INTEGER) | value >= threshold |
| assert_less_than | (tag, value, threshold: INTEGER) | value < threshold |
| assert_less_or_equal | (tag, value, threshold: INTEGER) | value <= threshold |
| assert_in_range | (tag, value, min, max: INTEGER) | min <= value <= max |
| assert_positive | (tag, value: INTEGER) | value > 0 |
| assert_negative | (tag, value: INTEGER) | value < 0 |
| assert_zero | (tag, value: INTEGER) | value = 0 |
| assert_non_zero | (tag, value: INTEGER) | value /= 0 |
| assert_non_negative | (tag, value: INTEGER) | value >= 0 |
| assert_non_positive | (tag, value: INTEGER) | value <= 0 |

### Real Comparison Assertions

| Feature | Signature | Description |
|---------|-----------|-------------|
| assert_reals_equal | (tag, expected, actual, epsilon: REAL_64) | Within epsilon |
| assert_real_greater_than | (tag, value, threshold: REAL_64) | value > threshold |
| assert_real_less_than | (tag, value, threshold: REAL_64) | value < threshold |
| assert_real_in_range | (tag, value, min, max: REAL_64) | In range |

### String Assertions

| Feature | Signature | Description |
|---------|-----------|-------------|
| assert_string_contains | (tag, string, substring) | Has substring |
| assert_string_not_contains | (tag, string, substring) | No substring |
| assert_string_starts_with | (tag, string, prefix) | Starts with |
| assert_string_ends_with | (tag, string, suffix) | Ends with |
| assert_string_empty | (tag, string) | Is empty |
| assert_string_not_empty | (tag, string) | Not empty |
| assert_string_length | (tag, expected_length, string) | Length equals |
| assert_strings_equal_case_insensitive | (tag, expected, actual) | Case-insensitive |
| assert_strings_equal_diff | (tag, expected, actual: STRING_32) | Detailed diff |

### Collection Assertions

| Feature | Signature | Description |
|---------|-----------|-------------|
| assert_array_has_item | (tag, array, item) | Contains item |
| assert_array_not_has_item | (tag, array, item) | Not contains |
| assert_iterable_is_empty | (tag, collection) | Empty |
| assert_iterable_not_empty | (tag, collection) | Not empty |
| assert_count_equals | (tag, expected, collection) | Count matches |

## TEST_SET_BRIDGE Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| test_folder | : PATH | Path to test folder |
