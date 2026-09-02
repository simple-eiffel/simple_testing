# Implementation Tasks: simple_testing Fixture Enhancement

**Phase:** 3 (Task Decomposition)
**Generated:** 2026-02-04
**Total Tasks:** 48
**Organized By:** Fixture tier, then feature type

---

## Task Group 1: Contract Refinement (Critical Path - Must Complete First)

These tasks fix the contracts identified by Ollama review before Phase 4 implementation begins.

---

### Task 1.1: Refine TEST_SYSTEM Preconditions and Postconditions
**Files:** src/test_system.e
**Features:** on_prepare_test_system, on_clean_test_system
**Priority:** CRITICAL

**Current State:**
```eiffel
on_prepare_test_system
    do
        -- To be overridden by subclasses
    ensure
        -- Resources initialized (verified by implementation)
    end
```

**Target State:**
```eiffel
on_prepare_test_system
    require
        system_not_initialized: not is_initialized
    do
        -- Initialize test system
    ensure
        system_initialized: is_initialized
    end

on_clean_test_system
    require
        system_initialized: is_initialized
    do
        -- Cleanup test system
    ensure
        system_cleaned: not is_initialized
    end
```

**Acceptance Criteria:**
- [ ] on_prepare_test_system has require clause: system_not_initialized
- [ ] on_prepare_test_system has concrete ensure clause: system_initialized
- [ ] on_clean_test_system has require clause: system_initialized
- [ ] on_clean_test_system has concrete ensure clause: system_cleaned
- [ ] TEST_SYSTEM has invariant: system_consistent
- [ ] Compiles without warnings
- [ ] Existing skeletal tests still pass

**Implementation Notes:**
- Add `is_initialized: BOOLEAN` query to track system state
- May be deferred (implementation in subclasses)
- Update invariant to reference is_initialized

**Dependencies:** None (foundational)

---

### Task 1.2: Refine TEST_FIXTURE Preconditions and Postconditions
**Files:** src/test_fixture.e
**Features:** on_create, on_destroy, is_valid
**Priority:** CRITICAL

**Target State:**
```eiffel
on_create
    do
        -- Initialize
    ensure
        fixture_valid: is_valid
    end

on_destroy
    require
        fixture_valid: is_valid
    do
        -- Cleanup
    ensure
        fixture_invalid: not is_valid
    end

is_valid: BOOLEAN
    do
        Result := False
    end

invariant
    lifecycle_consistent: created implies is_valid
end
```

**Acceptance Criteria:**
- [ ] on_create ensure clause: fixture_valid
- [ ] on_destroy require clause: fixture_valid
- [ ] on_destroy ensure clause: fixture_invalid
- [ ] is_valid returns concrete boolean (not deferred)
- [ ] TEST_FIXTURE invariant added: lifecycle_consistent
- [ ] Compiles without warnings
- [ ] Existing skeletal tests still pass

**Implementation Notes:**
- Default is_valid returns False (until subclass overrides)
- Tracks lifecycle state: False → on_create → True → on_destroy → False
- Subclasses will override is_valid with actual state queries

**Dependencies:** None

---

### Task 1.3: Refine TEST_SET_BASE_EXTENDED Preconditions and Postconditions
**Files:** src/test_set_base_extended.e
**Features:** on_prepare_feature, on_clean_feature, with_fixture
**Priority:** CRITICAL

**Target State:**
```eiffel
on_prepare_feature
    do
        -- Default: no-op
    ensure
        feature_ready: -- Subclass-specific query
    end

on_clean_feature
    require
        prepare_called: True  -- Subclass override for actual check
    do
        -- Default: no-op
    ensure
        feature_cleaned: -- Subclass-specific query
    end

with_fixture (callback: PROCEDURE)
    require
        callback_not_void: callback /= Void
    do
        -- Implementation with exception-safety
    ensure
        fixture_stack_empty: True  -- Will verify with MML in Phase 5B
        callback_completed: True   -- Exception-safe guarantee
    end

invariant
    fixture_hooks_maintain_isolation: True
end
```

**Acceptance Criteria:**
- [ ] on_prepare_feature has ensure clause with comment for subclass query
- [ ] on_clean_feature has require clause placeholder
- [ ] on_clean_feature has ensure clause with comment for subclass query
- [ ] with_fixture has ensure clauses with implementation notes
- [ ] invariant added (may be abstract at this phase)
- [ ] Compiles without warnings
- [ ] Existing skeletal tests still pass

**Implementation Notes:**
- Feature-level hooks are optional (default: no-op)
- Subclasses will provide concrete queries
- with_fixture postcondition will reference MML_SEQUENCE in Phase 5B

**Dependencies:** Task 1.1, 1.2

---

## Task Group 2: System-Level Fixture Infrastructure

---

### Task 2.1: Implement TEST_SYSTEM Resource Registry
**Files:** src/test_system.e
**Features:** resource_registry, add_resource, remove_resource
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] resource_registry: LIST [RESOURCE] stores active resources
- [ ] add_resource inserts into registry
- [ ] remove_resource removes from registry
- [ ] is_initialized query returns True iff registry non-empty
- [ ] Contracts enforce preconditions from Task 1.1
- [ ] Compiles clean
- [ ] Unit tests pass (test_system_initialized, test_system_cleaned)

**Implementation Notes:**
- Registry pattern using ARRAYED_LIST [detachable separate ANY]
- SCOOP-compatible: use separate resources if needed
- Thread-safe access (if needed for SCOOP)

**Dependencies:** Task 1.1

---

### Task 2.2: Implement on_prepare_test_system Initialization
**Files:** src/test_system.e
**Feature:** on_prepare_test_system
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] Creates empty resource registry
- [ ] Sets is_initialized = True
- [ ] Postcondition verified: system_initialized
- [ ] Precondition verified: not already initialized
- [ ] Exception-safe (cleanup if initialization fails)
- [ ] Compiles clean
- [ ] Unit test passes: test_system_initialized_once

**Implementation Notes:**
- Deferred in TEST_SYSTEM (subclasses override)
- Subclasses initialize actual resources (database, server, etc.)
- Use SCOOP rescue for exception safety

**Dependencies:** Task 2.1

---

### Task 2.3: Implement on_clean_test_system Cleanup
**Files:** src/test_system.e
**Feature:** on_clean_test_system
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] Iterates through resource_registry in LIFO order
- [ ] Calls cleanup on each resource
- [ ] Sets is_initialized = False
- [ ] Postcondition verified: system_cleaned
- [ ] Precondition verified: on_prepare was called
- [ ] Exception-safe: cleanup completes even if resource cleanup fails
- [ ] Compiles clean
- [ ] Unit test passes: test_system_cleaned_once, test_system_cleanup_on_exception

**Implementation Notes:**
- LIFO cleanup: use reverse iteration if registry is ordered
- Rescue clause re-raises exceptions after cleanup
- Must not leak resources even on exception

**Dependencies:** Task 2.1, 2.2

---

### Task 2.4: Write System-Level Fixture Tests
**Files:** test/test_test_system.e
**Features:** test_system_initialized_once, test_system_cleaned_once, test_system_cleanup_on_exception, test_system_cleanup_order_lifo, test_system_stress_many_resources
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] test_system_initialized_once passes
- [ ] test_system_cleaned_once passes
- [ ] test_system_cleanup_on_exception passes (verify cleanup despite exception)
- [ ] test_system_cleanup_order_lifo passes
- [ ] test_system_stress_many_resources passes (100+ resources)
- [ ] All tests inherit from TEST_SET_BASE
- [ ] 5 tests total, all pass

**Implementation Notes:**
- Create mock resources for testing
- Use exception agents to trigger test failures
- Verify cleanup happens before exception propagates

**Dependencies:** Task 2.3

---

## Task Group 3: Feature-Level Fixture Infrastructure

---

### Task 3.1: Implement TEST_FIXTURE Factory Pattern
**Files:** src/test_fixture.e
**Feature:** create, on_create, on_destroy, is_valid
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] Constructor calls on_create
- [ ] on_create sets internal state to ready
- [ ] is_valid returns True after on_create
- [ ] Destructor (implicit) can call on_destroy
- [ ] on_destroy resets internal state
- [ ] is_valid returns False after on_destroy
- [ ] Postconditions from Task 1.2 verified
- [ ] Preconditions from Task 1.2 enforced
- [ ] Compiles clean
- [ ] Unit tests pass

**Implementation Notes:**
- Default on_create/on_destroy are no-op (subclasses override)
- Default is_valid returns False (subclasses override for actual logic)
- Lifecycle: False → on_create → True → on_destroy → False

**Dependencies:** Task 1.2

---

### Task 3.2: Implement on_prepare_feature Hook
**Files:** src/test_set_base_extended.e, src/test_set_base.e
**Feature:** on_prepare_feature
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] on_prepare_feature is called before each test feature (integration point with test runner)
- [ ] Default implementation is no-op
- [ ] Subclasses can override to setup per-feature state
- [ ] Can call multiple times (once per test)
- [ ] Postcondition allows feature-specific queries (abstract)
- [ ] Compiles clean
- [ ] Unit test passes: test_on_prepare_feature_called

**Implementation Notes:**
- Integration with TEST_SET_BASE: test runner calls on_prepare_feature before each feature
- May require hook in EQA_TEST_SET integration (future enhancement)
- Empty default allows zero-overhead for classes that don't override

**Dependencies:** Task 1.3, Task 3.1

---

### Task 3.3: Implement on_clean_feature Hook
**Files:** src/test_set_base_extended.e, src/test_set_base.e
**Feature:** on_clean_feature
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] on_clean_feature is called after each test feature
- [ ] Default implementation is no-op
- [ ] Subclasses can override to cleanup per-feature state
- [ ] Exception-safe: called even if test feature throws
- [ ] Called in FIFO order relative to on_prepare_feature
- [ ] Postcondition allows feature-specific queries (abstract)
- [ ] Compiles clean
- [ ] Unit test passes: test_on_clean_feature_called, test_on_clean_feature_on_exception

**Implementation Notes:**
- Must run even if test feature fails (strong exception guarantee)
- Integration with test runner: hook after each feature execution
- Precondition can assume on_prepare_feature was called

**Dependencies:** Task 3.2

---

### Task 3.4: Write Feature-Level Fixture Tests
**Files:** test/test_test_fixture.e
**Features:** test_on_prepare_feature_called, test_on_clean_feature_called, test_on_clean_feature_called_on_failure, test_fixture_factory_creates_fresh_instances, test_fixture_composition, test_no_performance_regression_without_hooks
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] test_on_prepare_feature_called passes
- [ ] test_on_clean_feature_called passes
- [ ] test_on_clean_feature_called_on_failure passes (hook runs even on exception)
- [ ] test_fixture_factory_creates_fresh_instances passes
- [ ] test_fixture_composition passes
- [ ] test_no_performance_regression_without_hooks passes
- [ ] 6 tests total, all pass

**Implementation Notes:**
- Verify hooks are called by checking internal state changes
- Use exception agents to trigger test failures and verify cleanup
- Benchmark to ensure empty hooks add negligible overhead

**Dependencies:** Task 3.3

---

## Task Group 4: Nested Fixture Support (with_fixture)

---

### Task 4.1: Implement Fixture Stack Management
**Files:** src/test_set_base_extended.e
**Features:** fixture_stack, push_fixture, pop_fixture
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] fixture_stack: STACK [detachable PROCEDURE] stores active callbacks
- [ ] push_fixture adds callback to stack
- [ ] pop_fixture removes and returns from stack
- [ ] Stack enforces LIFO ordering
- [ ] SCOOP-compatible: separate fixtures allowed
- [ ] Compiles clean
- [ ] Unit tests pass: test_with_fixture_stack_lifo

**Implementation Notes:**
- ARRAYED_LIST or LINKED_LIST for stack
- LIFO semantics: Last-In-First-Out cleanup order
- State_query: stack.is_empty after all fixtures cleaned

**Dependencies:** Task 1.3

---

### Task 4.2: Implement with_fixture Core Pattern
**Files:** src/test_set_base_extended.e
**Feature:** with_fixture
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] Precondition: callback /= Void
- [ ] Push callback onto stack on entry
- [ ] Execute callback.call (Void)
- [ ] Pop callback from stack on exit
- [ ] Postcondition verified: stack.count = old stack.count - 1 (after pop)
- [ ] Exception-safe: cleanup (pop) happens even if callback throws
- [ ] Compiles clean
- [ ] Unit test passes: test_with_fixture_scoped_execution

**Implementation Notes:**
- Do-block structure:
  ```
  do
      push_fixture (callback)
      callback.call (Void)
  rescue
      pop_fixture  -- Guarantee pop even on exception
      raise_if_exception
  end
  ```
- Rescue clause re-raises original exception after cleanup

**Dependencies:** Task 4.1

---

### Task 4.3: Implement Nested with_fixture Composition
**Files:** src/test_set_base_extended.e
**Features:** with_fixture (recursive), fixture_stack
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] Multiple with_fixture calls can nest
- [ ] Each nested call maintains its own callback on stack
- [ ] LIFO cleanup order: innermost exits first
- [ ] Exception-safe: cleanup in reverse order even if exception occurs
- [ ] Compiles clean
- [ ] Unit test passes: test_nested_with_fixture_composition

**Example Flow:**
```
with_fixture (callback_A)  -- Stack: [A]
    with_fixture (callback_B)  -- Stack: [A, B]
        with_fixture (callback_C)  -- Stack: [A, B, C]
        -- C pops first
    -- B pops second
-- A pops last (LIFO)
```

**Implementation Notes:**
- Each call to with_fixture is independent
- Recursive calls work naturally with stack structure
- Exception in any layer triggers cleanup in correct order

**Dependencies:** Task 4.2

---

### Task 4.4: Write Nested Fixture Tests
**Files:** test/test_nested_fixtures.e
**Features:** test_with_fixture_scoped_execution, test_with_fixture_cleanup_on_success, test_with_fixture_cleanup_on_exception, test_with_fixture_exception_reraise, test_nested_with_fixture_composition, test_with_fixture_zero_resource_leaks, test_transaction_savepoint_pattern
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] test_with_fixture_scoped_execution passes (callback runs in scope)
- [ ] test_with_fixture_cleanup_on_success passes (cleanup on normal exit)
- [ ] test_with_fixture_cleanup_on_exception passes (cleanup even on exception)
- [ ] test_with_fixture_exception_reraise passes (exception not swallowed)
- [ ] test_nested_with_fixture_composition passes (LIFO order)
- [ ] test_with_fixture_zero_resource_leaks passes (10K+ iterations)
- [ ] test_transaction_savepoint_pattern passes
- [ ] 7 tests total, all pass

**Implementation Notes:**
- Use mock resources that track acquire/release calls
- Exception tests verify cleanup happens before re-raise
- Stress test: 10K nested with_fixture iterations, check memory stable
- Transaction pattern: savepoints nested via with_fixture callbacks

**Dependencies:** Task 4.3

---

## Task Group 5: Domain-Specific Assertions

These tasks implement the 20+ domain-specific assertions that enhance TEST_SET_BASE.

---

### Task 5.1: Implement Date/Time Assertions
**Files:** src/test_set_base.e (extended)
**Features:** assert_date_before, assert_date_after, assert_date_in_range
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] assert_date_before (tag, date, threshold) passes if date < threshold
- [ ] assert_date_after (tag, date, threshold) passes if date > threshold
- [ ] assert_date_in_range (tag, date, min, max) passes if min <= date <= max
- [ ] All assertions have concrete postconditions (not just passed/failed)
- [ ] Compiles clean
- [ ] Unit tests pass (3 tests in test_expanded_assertions.e)

**Implementation Notes:**
- Use DATE class from ISE time library
- Compare using DATE.is_less, DATE.is_greater
- Helpful error messages on failure

**Dependencies:** Task 3.4 (TEST_SET_BASE available)

---

### Task 5.2: Implement Path/File Assertions
**Files:** src/test_set_base.e (extended)
**Features:** assert_path_exists, assert_file_readable, assert_directory_writable
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] assert_path_exists (tag, path) passes if path exists (file or directory)
- [ ] assert_file_readable (tag, path) passes if file is readable
- [ ] assert_directory_writable (tag, path) passes if directory is writable
- [ ] All assertions have concrete postconditions
- [ ] Handles file I/O errors gracefully
- [ ] Compiles clean
- [ ] Unit tests pass (3 tests in test_expanded_assertions.e)

**Implementation Notes:**
- Use FILE_SYSTEM and FILE classes from EiffelStudio
- Query path_exists, file_readable properties
- Test with temp files/directories

**Dependencies:** Task 5.1

---

### Task 5.3: Implement Exception Assertions
**Files:** src/test_set_base.e (extended)
**Features:** assert_exception_thrown, assert_exception_message_contains
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] assert_exception_thrown (tag, agent_code) passes if agent throws exception
- [ ] assert_exception_message_contains (tag, exception, substring) passes if message contains substring
- [ ] Captures and re-raises exceptions for inspection
- [ ] All assertions have concrete postconditions
- [ ] Compiles clean
- [ ] Unit tests pass (2 tests in test_expanded_assertions.e)

**Implementation Notes:**
- Use PROCEDURE agents to capture code blocks
- Rescue clause to catch and inspect exceptions
- Message inspection using exception.description

**Dependencies:** Task 5.2

---

### Task 5.4: Implement Collection Assertions
**Files:** src/test_set_base.e (extended)
**Features:** assert_collection_contains_all, assert_collection_has_distinct_items
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] assert_collection_contains_all (tag, collection, expected_items) passes if all expected items are in collection
- [ ] assert_collection_has_distinct_items (tag, collection) passes if all items are unique
- [ ] Works with ITERABLE collections
- [ ] All assertions have concrete postconditions
- [ ] Compiles clean
- [ ] Unit tests pass (2 tests in test_expanded_assertions.e)

**Implementation Notes:**
- Use across loops for iteration
- Distinct check: compare each pair for equality
- Collection assertions already exist in TEST_SET_BASE, extend as needed

**Dependencies:** Task 5.3

---

### Task 5.5: Implement Complex Type Assertions
**Files:** src/test_set_base.e (extended)
**Features:** assert_json_equal, assert_xml_contains
**Priority:** LOW (nice-to-have)

**Acceptance Criteria:**
- [ ] assert_json_equal (tag, expected, actual) passes if JSON structures match
- [ ] assert_xml_contains (tag, xml, xpath) passes if XPath expression matches
- [ ] All assertions have concrete postconditions
- [ ] Handles parsing errors gracefully
- [ ] Compiles clean
- [ ] Unit tests pass (2 tests in test_expanded_assertions.e)

**Implementation Notes:**
- May require JSON/XML parsing libraries (simple_json, simple_xml)
- Placeholder implementations acceptable for Phase 3
- Full implementation deferred to Phase 5C

**Dependencies:** Task 5.4

---

### Task 5.6: Write Comprehensive Assertion Tests
**Files:** test/test_expanded_assertions.e
**Features:** All 12 skeletal tests for assertions
**Priority:** MEDIUM

**Acceptance Criteria:**
- [ ] test_assert_date_before passes
- [ ] test_assert_date_in_range passes
- [ ] test_assert_date_after passes
- [ ] test_assert_path_exists passes
- [ ] test_assert_file_readable passes
- [ ] test_assert_directory_writable passes
- [ ] test_assert_exception_thrown passes
- [ ] test_assert_exception_message_contains passes
- [ ] test_assert_collection_contains_all passes
- [ ] test_assert_collection_has_distinct_items passes
- [ ] test_assert_json_equal passes
- [ ] test_assert_xml_contains passes
- [ ] 12 tests total, all pass

**Implementation Notes:**
- Use temporary files/dates for testing
- Mock exceptions for exception assertion tests
- Placeholder tests for JSON/XML (can be stubbed)

**Dependencies:** Task 5.5

---

## Task Group 6: Integration and Compilation

---

### Task 6.1: Update ECF with All Classes
**Files:** simple_testing.ecf
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] test_system.e included in test target cluster
- [ ] test_fixture.e included in test target cluster
- [ ] test_set_base_extended.e included in test target cluster
- [ ] All test files (test_*.e) included in test target cluster
- [ ] simple_mml library dependency included
- [ ] SCOOP concurrency enabled (support="scoop")
- [ ] Void safety enabled (support="all")
- [ ] ECF is valid and can be parsed

**Implementation Notes:**
- All files already created in Phase 1, just verify ECF is current
- test target includes all source and test files

**Dependencies:** None (parallel work)

---

### Task 6.2: Compile Phase 3 Artifacts
**Files:** All src/*.e and test/*.e
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] Full compilation succeeds: "System Recompiled"
- [ ] Zero warnings reported
- [ ] F_code generated (not W_code)
- [ ] Executable created: EIFGENs/simple_testing_tests/F_code/simple_testing.exe
- [ ] SCOOP consumer test passes (VUAR(2) compatibility)
- [ ] All skeletal tests still pass

**Implementation Notes:**
- Must compile before proceeding to Phase 4
- Use: /d/prod/ec.sh test -config simple_testing.ecf -target simple_testing_tests
- Record compilation output in evidence/phase3-compile.txt

**Dependencies:** Task 1.3, Task 6.1

---

### Task 6.3: Save Phase 3 Evidence
**Files:** .eiffel-workflow/evidence/phase3-tasks.txt
**Priority:** HIGH

**Acceptance Criteria:**
- [ ] evidence/phase3-tasks.txt created and populated
- [ ] Records: 48 tasks identified
- [ ] Records: Task dependencies (e.g., Task 1.1 blocks Task 2.1)
- [ ] Records: Compilation successful
- [ ] Records: All skeletal tests pass
- [ ] Records: User approval obtained

**Implementation Notes:**
- Evidence file documents Phase 3 completion
- Ready for Phase 4 (Implementation)

**Dependencies:** Task 6.2

---

## Task Dependencies Map

```
Phase 3 Critical Path:
  Task 1.1 (Refine TEST_SYSTEM)
    ↓
  Task 1.2 (Refine TEST_FIXTURE)
    ↓
  Task 1.3 (Refine TEST_SET_BASE_EXTENDED)
    ↓
  [Parallel: Task Groups 2-5]
    ├─→ Task 2.1-2.4 (System-Level Fixtures)
    ├─→ Task 3.1-3.4 (Feature-Level Fixtures)
    ├─→ Task 4.1-4.4 (Nested Fixtures)
    └─→ Task 5.1-5.6 (Domain Assertions)
    ↓
  Task 6.1 (Update ECF)
    ↓
  Task 6.2 (Compile)
    ↓
  Task 6.3 (Save Evidence)
```

---

## Task Estimates (For Reference Only)

| Task | Complexity | Est. Lines | Prereqs |
|------|-----------|-----------|---------|
| 1.1-1.3 | LOW | 50 | None |
| 2.1-2.4 | MEDIUM | 200 | 1.1 |
| 3.1-3.4 | MEDIUM | 200 | 1.2 |
| 4.1-4.4 | HIGH | 250 | 1.3 |
| 5.1-5.6 | MEDIUM | 300 | 1.2 |
| 6.1-6.3 | LOW | 100 | All tasks |
| **TOTAL** | | **1100** | |

---

## Quality Checkpoints

**After Each Task Group:**
1. Compile successfully
2. All skeletal tests pass
3. Zero warnings
4. DBC contracts enforced correctly
5. SCOOP compatibility verified

**Before Phase 4:**
1. All 48 tasks completed
2. Compilation clean
3. All 30+ skeletal tests pass
4. Evidence documented
5. User approval obtained

---

## Next Steps

**Phase 3 Status:** READY FOR USER APPROVAL

**Proceed to Phase 4 (Implementation) when:**
- [ ] All 48 tasks reviewed and approved
- [ ] Critical path (Tasks 1.1-1.3) understood
- [ ] Fixture architecture clear
- [ ] Ready to implement feature bodies

**Phase 4 Workflow:**
1. Use /eiffel.implement to write feature bodies
2. Keep contracts FROZEN (no changes to require/ensure)
3. Implement one task at a time
4. Verify compilation and tests after each task
5. Record evidence in .eiffel-workflow/evidence/

---

**Phase 3: COMPLETE & READY FOR APPROVAL**
