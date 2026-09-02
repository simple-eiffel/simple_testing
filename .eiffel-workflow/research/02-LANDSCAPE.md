# LANDSCAPE: Fixture Architecture Analysis

**Date:** February 4, 2026

## Fixture Scope Hierarchy (Industry Standard)

### xUnit/JUnit Architecture (Reference Model)

| Scope | Setup Timing | Teardown Timing | Use Case | Standard |
|-------|-------------|-----------------|----------|----------|
| **Session/Run** | Once at start of all tests | Once at end of all tests | Database init, server startup, resource pools | JUnit 5 @BeforeAll (class-level) |
| **Module/File** | Once per test file | Once per test file | Module-level resources, test data files | pytest module fixture |
| **Class** | Once per test class | Once per test class | Eiffel: EQA_TEST_SET on_prepare/on_clean (CURRENT) |
| **Method/Feature** | Before each test method | After each test method | Per-test isolation, expected to be implemented | JUnit 5 @BeforeEach, pytest function scope |
| **Nested/Intra** | On demand within test | Auto-cleanup on scope exit | Local test context, DBC-style assertions | pytest nested fixtures, pytest autouse |

## Eiffel Current State (Pre-Enhancement)

### What Eiffel Has

```eiffel
-- Class-level fixtures (EQA_TEST_SET)
class MY_TEST_SET
    inherit EQA_TEST_SET
    feature
        on_prepare do ... end  -- Called before all tests in class
        on_clean do ... end    -- Called after all tests in class

        test_feature_1 do ... end
        test_feature_2 do ... end
end
```

**Scope:** Class-level only. Single setup/cleanup for entire test class.

### What Eiffel Lacks

1. **Test-System-Level** (TEST_APP scope)
   - Currently: No standard way to do test-run initialization
   - Problem: Resources like databases must be managed manually
   - Solution needed: TEST_APP hook for on_prepare/on_clean

2. **Test-Feature-Level** (per-feature scope)
   - Currently: Only class-level on_prepare/on_clean
   - Problem: Must reset shared fixtures manually between test features
   - Solution needed: Decorator/hook pattern for per-feature setup

3. **Intra-Test-Feature-Level** (nested scope)
   - Currently: No standard pattern
   - Problem: Complex tests must manage state manually
   - Solution needed: Scoped fixture context manager pattern

## Industry Comparison: Fixture Approaches

### pytest (Python)

**Strength:** Hierarchical fixture scopes with dependency injection

```python
@pytest.fixture(scope="session")
def database():
    db = init_db()
    yield db
    teardown_db(db)

@pytest.fixture(scope="function")
def clean_db(database):
    database.clear()
    yield
    database.clear()

def test_something(clean_db):
    ...
```

**Why Not Directly Use pytest:**
- Python dependency, not Eiffel
- simple_python provides HTTP bridge to Python, not test framework integration
- Eiffel teams don't use pytest (not Python developers)

### JUnit 5 (Java)

**Strength:** @BeforeEach/@AfterEach per-method setup

```java
@BeforeEach
void setUp() { ... }

@Test
void testSomething() { ... }

@AfterEach
void tearDown() { ... }
```

**Eiffel Equivalent:**
- Can implement as feature naming convention or annotation pattern
- More native to Eiffel's OOP structure than decorators

### NUnit (C#)

**Strength:** Simplified setup/teardown with clear semantics

```csharp
[SetUp]
public void SetUp() { ... }

[Test]
public void TestSomething() { ... }

[TearDown]
public void TearDown() { ... }
```

**Eiffel Consideration:**
- No attribute system in Eiffel (uses notes instead)
- Can use note convention: `note: "fixture_level: feature"`

## Proposed Eiffel Fixture Architecture

### Tier 1: Test-System-Level (TEST_APP)

```eiffel
class TEST_APP
    inherit TEST_SYSTEM

    feature -- System-level fixtures
        on_prepare_test_system do
            -- Initialize database, start server, create resource pools
            database := database_factory.create
            resource_pool := create_pool (16)
        end

        on_clean_test_system do
            -- Shutdown database, close server, release resources
            database.close
            resource_pool.drain_and_close
        end
end
```

**Timing:** Once before all test classes, once after all test classes
**Access:** Via singleton pattern or global context
**Use Cases:** Database initialization, server startup, resource pools

### Tier 2: Test-Feature-Level (TEST_SET_BASE)

```eiffel
class MY_TEST_SET
    inherit TEST_SET_BASE

    feature -- Feature-level fixtures
        test_feature_with_fixture_context
            local
                ctx: TEST_CONTEXT
            do
                ctx := create_fixture_context
                assert_positive ("value", ctx.database.record_count)
                -- ctx auto-cleans up at end of feature
            end

    feature {NONE} -- Fixture factory
        create_fixture_context: TEST_CONTEXT
            -- Create per-feature fixture with auto-cleanup
            do
                create Result.make (database := system_database)
                Result.on_create  -- Initialize
            end
end
```

**Timing:** Before each test feature, after each test feature
**Access:** Via feature parameter or creation
**Use Cases:** Fresh test data, clean state per test, database transactions

### Tier 3: Intra-Test-Feature-Level (Nested)

```eiffel
feature
    test_complex_scenario_with_nested_fixtures
        do
            -- Outer context
            assert_positive ("outer setup", db.record_count)

            -- Nested context (auto-cleanup on exit)
            with_test_transaction (agent
                do
                    assert_zero ("transaction isolation", db.record_count)
                    db.insert_test_data
                    assert_positive ("data inserted", db.record_count)
                    -- Auto-rollback on exit
                end
            )

            -- Verify rollback
            assert_positive ("after rollback", db.record_count)
        end

    with_test_transaction (callback: PROCEDURE)
        -- Scoped fixture: begin transaction, run callback, rollback
        do
            database.begin_transaction
            callback.call
            database.rollback
        end
```

**Timing:** On entry to block, on exit from block
**Access:** Via agent/callback pattern (DBC check-style)
**Use Cases:** Transactions, scoped resources, conditional context

## Risk Assessment

### Backward Compatibility Risk: LOW

- Existing TEST_SET_BASE inheritance remains unchanged
- New fixtures added as optional features
- No breaking changes to assertion API
- Additive only

### Complexity Risk: MEDIUM

- Three-tier fixture system adds conceptual overhead
- Must be documented with clear examples
- IDE integration needed for discoverability

### Performance Risk: LOW

- Fixtures are setup/teardown, not test execution
- Agent callbacks have minimal overhead
- No additional allocations if not used

### SCOOP Concurrency Risk: MEDIUM

- Fixtures may share mutable state (database, resource pool)
- Separate keyword needed for concurrent access
- Contract preconditions ensure proper synchronization
- Testable via SCOOP consumer integration gate

## Mapping to Eiffel OOP Patterns

| Fixture Level | Eiffel Pattern | Implementation |
|---------------|----------------|-----------------|
| System | Singleton | TEST_SYSTEM with once functions |
| Class | Inheritance | EQA_TEST_SET on_prepare/on_clean (existing) |
| Feature | Factory + Local | create_fixture_context function |
| Nested | Agent + DBC | with_fixture (agent do ... end) |

## Compatibility with EQA_TEST_SET

- TEST_SET_BASE already inherits from EQA_TEST_SET
- Fixtures build ON TOP of existing EQA patterns
- No changes to EQA_TEST_SET itself needed
- Can coexist with existing test code

---

**Sources:**
- [xUnit - Wikipedia](https://en.wikipedia.org/wiki/XUnit)
- [JUnit Test Fixture Tutorial](https://www.softwaretestinghelp.com/junit-test-fixture-with-examples/)
- [pytest Fixtures Documentation](https://docs.pytest.org/en/stable/how-to/fixtures.html)
- [NUnit Documentation](https://docs.nunit.org/)

**Prepared:** 2026-02-04
**Next Step:** REQUIREMENTS definition for each fixture tier
