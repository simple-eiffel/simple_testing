# S01-PROJECT-INVENTORY: simple_testing

**BACKWASH** | Date: 2026-01-23

## Project Structure

```
simple_testing/
├── src/
│   ├── test_set_base.e         # Main assertion class
│   └── test_set_bridge.e       # Internal access bridge
├── testing/
│   ├── test_app.e              # Test application
│   └── lib_tests.e             # Test suite
├── simple_testing.ecf          # Library ECF
├── research/                   # Research documents
└── specs/                      # Specification documents
```

## Key Files

| File | Purpose |
|------|---------|
| test_set_base.e | Deferred class with 40+ assertion methods |
| test_set_bridge.e | Enables access to internal features |

## ECF Configuration

```xml
<library name="simple_testing" location="$SIMPLE/simple_testing/simple_testing.ecf"/>
```

## Usage Pattern

Test classes inherit TEST_SET_BASE:

```eiffel
class MY_TESTS
inherit
    TEST_SET_BASE
feature
    test_something
        do
            assert_positive ("value", compute_result)
        end
end
```
