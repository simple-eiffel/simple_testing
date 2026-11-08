# simple_testing

[Documentation](https://simple-eiffel.github.io/simple_testing/) •
[GitHub](https://github.com/simple-eiffel/simple_testing) •
[Issues](https://github.com/simple-eiffel/simple_testing/issues)

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Eiffel 25.02](https://img.shields.io/badge/Eiffel-25.02-purple.svg)
![DBC: Contracts](https://img.shields.io/badge/DBC-Contracts-green.svg)
![Tests: 71](https://img.shields.io/badge/Tests-71-blue.svg)
![Coverage: 100%](https://img.shields.io/badge/Coverage-100%25-brightgreen.svg)
![Windows: tests pass](https://img.shields.io/badge/Windows-tests%20pass-0078D6?logo=windows&logoColor=white) ![Linux: tests pass](https://img.shields.io/badge/Linux-tests%20pass-FCC624?logo=linux&logoColor=black) ![macOS: tests pass](https://img.shields.io/badge/macOS-tests%20pass-000000?logo=apple&logoColor=white)

Advanced test framework for Eiffel with Design by Contract, comprehensive fixtures, and formal verification.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.1.0

- **71 tests passing** with 100% pass rate
- **Zero compilation warnings** (strict ZERO WARNINGS POLICY)
- System-level, feature-level, and nested fixtures for complete test control
- Mathematical Model Library (MML) integration for formal specification
- Full Design by Contract implementation with preconditions, postconditions, and invariants
- SCOOP compatible (concurrency-ready with actor model semantics)
- Void-safe throughout (void_safety="all")

## Overview

`simple_testing` provides production-grade testing infrastructure for Eiffel that goes beyond standard assertions. It implements:

- **Three-tier fixture architecture** for testing at different scopes
- **40+ assertion methods** covering all common data types
- **Design by Contract** with formal verification of contracts via MML model queries
- **Exception-safe cleanup** patterns ensuring resources are released reliably
- **Frame conditions** specifying what state changes AND what state does NOT change

## Quick Start

### Basic Test Class

```eiffel
class MY_TEST_SET
inherit TEST_SET_BASE
feature
    test_basic_assertion
        do
            assert ("condition_true", True)
            assert_positive ("count_positive", 42)
            assert_string_contains ("has_error", "ERROR message", "ERROR")
        end
end
```

### System-Level Fixtures (Once Per Test Run)

```eiffel
class DATABASE_TEST_SYSTEM
inherit TEST_SYSTEM
feature
    on_prepare_test_system
        do
            -- Called once at test run start
            database.connect ("test_db")
            database.create_schema
        end

    on_clean_test_system
        do
            -- Called once at test run end
            database.drop_schema
            database.close
        end

    is_initialized: BOOLEAN
        do Result := database.is_connected end
end
```

### Feature-Level Fixtures (Once Per Test)

```eiffel
test_with_isolated_database
    local
        l_fixture: DATABASE_FIXTURE
    do
        create l_fixture
        l_fixture.on_create  -- Transaction begins

        database.insert_user ("john", "secret")
        assert ("user_inserted", database.user_exists ("john"))

        l_fixture.on_destroy  -- Transaction rolls back
        assert ("user_deleted", not database.user_exists ("john"))
    end
```

### Nested Fixtures (LIFO Cleanup)

```eiffel
test_with_nested_fixtures
    local
        l_test: FIXTURE_HOLDER
    do
        create l_test
        l_test.with_fixture (agent do
            database.begin_transaction
            -- Test logic here
            -- Automatic cleanup on exit (even if exception thrown)
        end)
    end
```

## Features

### Assertion Methods (40+)

- **Boolean**: `assert`, `assert_true`, `assert_false`
- **Object**: `assert_attached`, `assert_void`, `assert_same_reference`
- **Equality**: `assert_equal`, `assert_not_equal`
- **Numeric**: `assert_positive`, `assert_negative`, `assert_in_range`, `assert_greater_than`, `assert_less_than`
- **String**: `assert_string_contains`, `assert_string_starts_with`, `assert_string_ends_with`, `assert_string_empty`, `assert_string_length`
- **Collection**: `assert_count_equals`, `assert_iterable_empty`, `assert_iterable_not_empty`, `assert_array_has_item`
- **Advanced**: Real number assertions, NATURAL_64 assertions, with epsilon support for floating-point comparisons

### Three-Tier Fixture Architecture

#### System-Level (`TEST_SYSTEM`)
Runs **once per entire test run**. Perfect for expensive initialization (database setup, server startup):

```
Test Run Start
    ↓
on_prepare_test_system (called once)
    ↓
    [All test classes run here with shared resources]
    ↓
on_clean_test_system (called once)
    ↓
Test Run End
```

#### Feature-Level (`TEST_FIXTURE`)
Runs **once per test method**. Provides isolation (fresh state for each test):

```
For each test method:
    on_create (setup)
    ↓
    [Test logic here]
    ↓
    on_destroy (cleanup - always runs, even if exception thrown)
```

#### Nested/Scoped (`with_fixture`)
Execute callback in **scoped fixture context** with LIFO cleanup:

```
with_fixture {
    acquire fixture 1
        acquire fixture 2
            execute callback
        release fixture 2 (LIFO)
    release fixture 1 (LIFO)
}
```

### Design by Contract Throughout

Every class specifies its contract:

```eiffel
feature
    on_prepare_test_system
        require
            system_not_initialized: not is_initialized
        do
            -- Implementation
        ensure
            system_initialized: is_initialized
            state_transition: initialization_state = 1 and old initialization_state = 0
        end
end
```

Tests verify that:
- **Preconditions** are satisfied before calling
- **Postconditions** hold after calling
- **Invariants** are maintained throughout
- **Frame conditions** (what did NOT change) are respected

### Mathematical Model Library Integration

Uses `simple_mml` for formal verification:

```eiffel
feature -- Model Queries
    initialization_state: INTEGER
        -- 0 = uninitialized, 1 = initialized
        -- Invariant: state ∈ {0, 1}

test_state_transition
    local
        l_system: TEST_SYSTEM_MOCK
    do
        create l_system
        assert_equal ("initial", 0, l_system.initialization_state)
        l_system.on_prepare_test_system
        assert_equal ("after_prepare", 1, l_system.initialization_state)
    end
```

### Timing Without Contracts (`without_contracts`, 1.1.0)

`TEST_SET_BASE.without_contracts (a_work)` runs `a_work` with contract checking off, then turns it back on as it was, even when `a_work` raises. It is for timing tests. A frame budget or a throughput limit belongs to the shipping build, which has no assertions; with checking on, every call also evaluates its preconditions, postconditions and invariants, which is not what the budget measures. Wrap only the measured work. Everything outside still runs under contracts, and the test's own `assert_*` calls are not contracts.

From simple_widgets' 100,000-row grid test: the set-up and the scroll run
under contracts, and only the frame being timed runs without them.

```eiffel
grid.handle_wheel (120).do_nothing                -- under contracts
without_contracts (agent time_it (agent window.request_render))
assert_true ("wheel scrolling holds 60 Hz", last_ms < 16.7)
```

Here `time_it` is the test's own routine: it reads a clock, calls the agent,
and stores the elapsed milliseconds in `last_ms`.

### Exception-Safe Cleanup

Cleanup is guaranteed even if test logic throws:

```eiffel
test_exception_safety
    local
        l_fixture: TEST_FIXTURE_MOCK
    do
        create l_fixture
        l_fixture.on_create

        -- Even if this throws, on_destroy guaranteed to run
        perform_risky_operation

        l_fixture.on_destroy
        -- Postcondition holds: fixture.is_valid = False
    end
```

## Installation

Set environment variable (one-time):

```bash
export SIMPLE_EIFFEL=/path/to/simple/eiffel
```

Add to your ECF configuration:

```xml
<library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
```

## Dependencies

- **base** — Eiffel base library (ISE standard)
- **testing** — Eiffel testing library (EQA_TEST_SET)
- **simple_mml** — Mathematical Model Library for formal verification

## Key Differences from Standard EQA_TEST_SET

| Feature | Standard EQA | simple_testing |
|---------|--------------|----------------|
| Assertion Count | ~10 | 40+ |
| Fixture Scopes | None | 3 tiers (system, feature, nested) |
| Design by Contract | Manual | Built-in with MML |
| SCOOP Support | No | Yes (concurrency-ready) |
| Frame Conditions | No | Yes (via MML) |
| Exception-Safe Cleanup | Manual | Automatic |
| Void Safety | No | Yes (void_safety="all") |

## Test Coverage

**Total: 71 tests**, registered in `test/test_app.e`: test system (5), test fixture (6), nested fixtures (7), expanded assertions (12), adversarial and stress (22), SCOOP integration (17), and `without_contracts` (2: it switches checking off and back, and restores it after an exception).

**Result:** 100% pass rate, zero warnings

## Use Cases

### Scenario 1: Database Testing
Use system-level fixture for database setup, feature-level fixtures for transaction rollback:

```eiffel
test_user_creation
    local l_fixture: DATABASE_FIXTURE do
        create l_fixture; l_fixture.on_create

        database.create_user ("alice")
        assert ("user_created", database.user_exists ("alice"))

        l_fixture.on_destroy  -- Transaction rolled back
    end
```

### Scenario 2: API Testing
System-level for server startup, feature-level for request isolation:

```eiffel
test_api_endpoint
    local l_fixture: HTTP_FIXTURE do
        create l_fixture; l_fixture.on_create

        response := http_client.get ("/api/users/1")
        assert_equal ("status", 200, response.status)

        l_fixture.on_destroy
    end
```

### Scenario 3: Formal Verification
Use MML model queries to verify contract satisfaction:

```eiffel
test_contract_verification
    local l_cache: SIMPLE_CACHE [STRING, INTEGER] do
        create l_cache.make (10)

        l_cache.put ("key", 42)

        assert ("has_key", l_cache.items_model.has ("key"))
        assert ("value_correct", l_cache.items_model ["key"] = 42)
    end
```

## Documentation

For detailed information, see:

- **[Quick API](https://simple-eiffel.github.io/simple_testing/quick.html)** — One-page reference with common operations
- **[User Guide](https://simple-eiffel.github.io/simple_testing/user-guide.html)** — Comprehensive tutorial with real-world examples
- **[API Reference](https://simple-eiffel.github.io/simple_testing/api-reference.html)** — Complete class and feature documentation
- **[Architecture](https://simple-eiffel.github.io/simple_testing/architecture.html)** — Design decisions and internal structure
- **[Cookbook](https://simple-eiffel.github.io/simple_testing/cookbook.html)** — 8 real-world recipes and patterns

## License

MIT License — See [LICENSE](LICENSE) file for details.

## Support

- **Documentation:** https://simple-eiffel.github.io/simple_testing/
- **GitHub Repository:** https://github.com/simple-eiffel/simple_testing
- **Report Issues:** https://github.com/simple-eiffel/simple_testing/issues
- **Simple Eiffel:** https://github.com/simple-eiffel
