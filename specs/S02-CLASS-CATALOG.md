# S02-CLASS-CATALOG: simple_testing

**BACKWASH** | Date: 2026-01-23

## Classes

| Class | Type | Description |
|-------|------|-------------|
| TEST_SET_BASE | Deferred | Rich assertion library extending EQA |
| TEST_SET_BRIDGE | Concrete | Export target for internal access |

## TEST_SET_BASE

**Purpose**: Provide comprehensive assertions for Eiffel unit tests

**Inheritance**:
- EQA_TEST_SET (undefine assert)
- EQA_COMMONLY_USED_ASSERTIONS (redefine assert_attached, assert_void, assert_equal, assert_not_equal, assert_integers_equal)

**Feature Groups**:
- Boolean assertions
- Object/Reference assertions
- Equality assertions
- Numeric assertions (INTEGER)
- Numeric assertions (REAL)
- String assertions
- Collection assertions
- String diff implementation

## TEST_SET_BRIDGE

**Purpose**: Enable test access to {NONE} features

**Usage**:
1. Export feature group to {TEST_SET_BRIDGE} in tested class
2. Test class inherits TEST_SET_BRIDGE
3. Test can now call the internal feature

**Features**:
- test_folder: PATH - Returns path to test folder

## Inheritance Diagram

```
EQA_TEST_SET
      |
      v
EQA_COMMONLY_USED_ASSERTIONS
      |
      v
TEST_SET_BASE (deferred)
      |
      v
MY_TEST_CLASS (your tests)
```
