# REQUIREMENTS: simple_testing Enhancement

**Date:** February 4, 2026

## Functional Requirements

### Phase 5A: Test-System-Level Fixtures (FR-5A)

**FR-5A-01: System Initialization Hook**
- Requirement: TEST_SYSTEM class with on_prepare_test_system hook
- Acceptance Criteria:
  - Called exactly once at test run start
  - Runs before any TEST_SET_BASE.on_prepare
  - Can throw exceptions to prevent test execution
  - Can access TEST_APP properties

**FR-5A-02: System Cleanup Hook**
- Requirement: TEST_SYSTEM with on_clean_test_system hook
- Acceptance Criteria:
  - Called exactly once at test run end
  - Runs after all TEST_SET_BASE.on_clean
  - Guaranteed to run even if tests fail
  - Exceptions logged but don't prevent other cleanup

**FR-5A-03: Resource Registry**
- Requirement: System-level singleton access to resources
- Acceptance Criteria:
  - TEST_SYSTEM.system_database returns same instance to all test classes
  - TEST_SYSTEM.resource_pool accessible from any test
  - Resources are thread-safe (SCOOP compatible)

**FR-5A-04: Hierarchical Initialization**
- Requirement: Session → Module → Class fixture ordering
- Acceptance Criteria:
  - on_prepare_test_system runs first
  - Then module-level setup (future)
  - Then TEST_SET_BASE.on_prepare for each class
  - Then test features

### Phase 5B: Test-Feature-Level Fixtures (FR-5B)

**FR-5B-01: Per-Feature Setup/Teardown**
- Requirement: on_prepare_feature and on_clean_feature hooks
- Acceptance Criteria:
  - Called before/after each individual test feature
  - Runs after TEST_SET_BASE.on_prepare, before test logic
  - Runs after test logic, before TEST_SET_BASE.on_clean
  - Can be overridden per test class

**FR-5B-02: Fixture Context Factory**
- Requirement: create_test_fixture feature returning TEST_FIXTURE object
- Acceptance Criteria:
  - TEST_FIXTURE is reusable across test features
  - on_create initializes fixture state
  - on_destroy cleans up fixture state
  - Fixture can be local to a test feature

**FR-5B-03: Fixture Dependency Injection**
- Requirement: Features can request fixture via parameter
- Acceptance Criteria:
  - Test feature can have fixture parameter: `test_something (fixture: TEST_FIXTURE)`
  - Fixture automatically injected
  - Fixture lifecycle managed by test runner
  - Optional: fixture parameter vs local creation

**FR-5B-04: Isolation Guarantee**
- Requirement: Each test feature gets fresh fixture state
- Acceptance Criteria:
  - Database transactions rolled back between tests
  - Shared mutable state reset
  - Collections cleared
  - No state leak between features

### Phase 5C: Intra-Test-Feature-Level Fixtures (FR-5C)

**FR-5C-01: Scoped Resource Blocks**
- Requirement: with_fixture (agent do ... end) pattern
- Acceptance Criteria:
  - Enter block: resource acquired
  - Exit block: resource released (even on exception)
  - Syntax: `with_database_transaction (agent do ... end)`
  - No manual cleanup needed

**FR-5C-02: Nested Fixture Composition**
- Requirement: Multiple with_fixture blocks can nest
- Acceptance Criteria:
  - Inner block exits before outer block
  - Resource cleanup order reversed from creation
  - No deadlocks on concurrent access

**FR-5C-03: DBC-Style Fixture Assertions**
- Requirement: check_fixture pattern mirroring DBC check assertions
- Acceptance Criteria:
  - `check_fixture ("description", condition)` within test
  - Behaves like DBC check but in test context
  - Failure halts test with fixture cleanup

**FR-5C-04: Exception Handling in Fixtures**
- Requirement: Exceptions in fixture don't prevent cleanup
- Acceptance Criteria:
  - Exception in callback doesn't prevent resource release
  - Original exception propagated after cleanup
  - Cleanup exceptions chained to result

### Phase 5D: Expanded Assertions (FR-5D)

**FR-5D-01: Domain-Specific Assertions**
- Requirement: 20+ new assertion methods for common domains
- Categories:
  - Date/Time: assert_date_before, assert_date_in_range
  - Path/File: assert_path_exists, assert_file_readable
  - Exception: assert_exception_thrown, assert_exception_message
  - Collection: assert_collection_contains_all, assert_collection_distinct
  - Complex Types: assert_json_equal, assert_xml_contains
- Acceptance Criteria:
  - Each assertion has clear failure message
  - All include postconditions with contracts

**FR-5D-02: Custom Assertion Builder**
- Requirement: DSL for creating custom assertions
- Acceptance Criteria:
  - `custom_assertion (tag: STRING) do ... assert (...) end`
  - Builder pattern for complex assertions
  - Reusable across test classes

**FR-5D-03: Improved Diagnostic Messages**
- Requirement: Better failure output for complex types
- Acceptance Criteria:
  - Collection failures show subset with diff
  - Nested object failures show path to difference
  - String failures use existing diff algorithm (already in TEST_SET_BASE)
  - Performance: diff generation < 100ms for 10K item collections

**FR-5D-04: Assertion Chaining**
- Requirement: Optional fluent assertion API
- Acceptance Criteria:
  - `assert_that (value).is_positive.is_less_than (100)`
  - Chain multiple assertions
  - Single failure message for chain
  - Optional: fluent vs traditional function style

## Non-Functional Requirements

### Performance (NFR-PERF)

**NFR-PERF-01: Zero Overhead When Fixtures Not Used**
- Fixtures add no overhead to existing tests
- Measurement: Tests without fixtures run at same speed as before

**NFR-PERF-02: Fixture Overhead < 10% of Test Execution**
- Fixture setup/teardown should be < 10% of total test time
- Measurement: 1000-test suite with fixtures vs without

**NFR-PERF-03: Nested Fixture Performance**
- 100 nested fixture blocks: execution time < 50ms
- Memory per block: < 1 KB overhead

### Scalability (NFR-SCALE)

**NFR-SCALE-01: Support 1000+ Test Classes**
- System fixtures work with 1000+ inheriting test classes
- No quadratic performance degradation
- Memory usage linear in test class count

**NFR-SCALE-02: Concurrent Test Execution**
- Fixtures support SCOOP separate processor pools
- Resource synchronization via contracts
- No race conditions in fixture setup/teardown

### Compatibility (NFR-COMPAT)

**NFR-COMPAT-01: Backward Compatibility**
- All existing TEST_SET_BASE usage continues working
- No breaking changes to assertion API
- Fixtures are additive only

**NFR-COMPAT-02: EiffelStudio Version Support**
- Works with EiffelStudio 25.02+
- No VUAR(2) errors in SCOOP consumer integration gate
- Void-safety: Strict (void_safety=all)

**NFR-COMPAT-03: SCOOP Safety**
- All system-level resources are separate
- Feature-level fixtures are attached objects (not separate)
- Nested fixtures use agents (safe)

### Maintainability (NFR-MAINT)

**NFR-MAINT-01: Code Coverage**
- Test suite coverage: >= 95% of fixture library
- All fixture code under contracts
- All failure paths tested

**NFR-MAINT-02: Documentation**
- API documentation on all public features
- 10+ runnable examples in docs
- Architectural guide explaining three fixture tiers

**NFR-MAINT-03: Error Messages**
- Fixture failures show:
  - What fixture is being set up
  - What resource is being acquired/released
  - Stack trace if available
  - Suggestion for fixing

## Constraints

**C-01: No External Dependencies**
- Use only simple_* and Eiffel stdlib
- No Python dependencies (simple_python is for different use case)

**C-02: Eiffel Language Constraints**
- No decorators (use note conventions instead)
- No metaclass/reflection needed
- No dynamic code generation
- Pattern-based architecture only

**C-03: EQA Framework Integration**
- Must work within EQA_TEST_SET architecture
- Cannot modify EiffelStudio's AutoTest
- Fixtures implemented in simple_testing library only

**C-04: Concurrency Model**
- Must be SCOOP-compatible (concurrency=scoop)
- Separate keyword for shared resources
- No "thread" concurrency model

---

## Requirement Mapping to Implementation

| Requirement | Implementation Class | Phase |
|------------|---------------------|-------|
| FR-5A-01/02 | TEST_SYSTEM | 5A |
| FR-5A-03/04 | TEST_SYSTEM + singleton | 5A |
| FR-5B-01/02/03/04 | TEST_SET_BASE + TEST_FIXTURE | 5B |
| FR-5C-01/02/03/04 | TEST_FIXTURE + agents | 5C |
| FR-5D-01/02/03/04 | TEST_SET_BASE expansion | 5D |

---

**Prepared:** 2026-02-04
**Next Step:** DECISIONS on architecture and design patterns
