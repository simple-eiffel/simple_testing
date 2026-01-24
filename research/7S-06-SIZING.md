# 7S-06-SIZING: simple_testing

**BACKWASH** | Date: 2026-01-23

## Codebase Metrics

- **Source Files**: 2 .e files
- **LOC Estimate**: ~900 lines

## Class Breakdown

| Class | Type | LOC | Features |
|-------|------|-----|----------|
| TEST_SET_BASE | Deferred | ~850 | 40+ assertions |
| TEST_SET_BRIDGE | Concrete | ~40 | test_folder helper |

## Assertion Categories

| Category | Count | Methods |
|----------|-------|---------|
| Boolean | 3 | assert_true, assert_false, refute |
| Object | 4 | assert_attached, assert_void, assert_same_reference, assert_not_same_reference |
| Equality | 4 | assert_equal, assert_not_equal, assert_integers_equal, assert_naturals_equal |
| Integer Comparison | 10 | greater_than, less_than, in_range, positive, negative, zero, non_zero, non_negative, non_positive, greater_or_equal, less_or_equal |
| Real Comparison | 4 | assert_reals_equal, real_greater_than, real_less_than, real_in_range |
| String | 8 | contains, not_contains, starts_with, ends_with, empty, not_empty, length, case_insensitive |
| Collection | 4 | array_has_item, array_not_has_item, iterable_empty, iterable_not_empty, count_equals |
| Utility | 1 | assert_strings_equal_diff |

## Complexity

- **Low Complexity**: Each assertion is a simple check + message
- **String Diff**: Most complex (character-by-character comparison)
- **No External Dependencies**: Pure Eiffel
