# 7S-01-SCOPE: simple_testing

**BACKWASH** | Date: 2026-01-23

## Problem Domain

Simple_testing provides enhanced testing support for Eiffel applications, extending EiffelStudio's EQA (Eiffel Quality Assurance) framework with:

- Rich assertion methods for common testing patterns
- Detailed failure messages with expected vs actual values
- Boolean, object, numeric, string, and collection assertions
- Test set bridge pattern for accessing internal features
- String diff visualization for debugging

## Target Users

- Eiffel developers writing unit tests
- Simple Eiffel ecosystem libraries
- Applications using EQA testing framework

## Business Value

- Reduces test code verbosity
- Improves failure message clarity
- Standardizes testing patterns across ecosystem
- Enables access to internal features during testing

## Core Assertions

- **Boolean**: assert_true, assert_false, refute
- **Object**: assert_attached, assert_void, assert_same_reference
- **Equality**: assert_equal, assert_not_equal, assert_integers_equal
- **Numeric**: assert_positive, assert_negative, assert_in_range
- **Real**: assert_reals_equal (with epsilon), assert_real_in_range
- **String**: assert_string_contains, starts_with, ends_with, empty
- **Collection**: assert_iterable_is_empty, assert_count_equals

## Out of Scope

- Test discovery/execution (EQA handles this)
- Test fixtures/setup (use EQA patterns)
- Mocking framework
- Code coverage analysis
