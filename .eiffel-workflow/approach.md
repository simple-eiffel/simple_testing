# Implementation Approach: simple_testing Fixture Enhancement

## Overview

This document outlines the implementation strategy for enhancing simple_testing with three-tier fixture architecture and 20+ domain-specific assertions.

## Phases and Timeline

### Phase 1: Core Fixture Infrastructure (Completed ✓)

**Status**: Contract skeletons created, all tests compile.

**Delivered:**
- TEST_SYSTEM abstract class (system-level fixture lifecycle)
- TEST_FIXTURE abstract class (feature-level fixture factory pattern)
- TEST_SET_BASE_EXTENDED extension points (on_prepare_feature/on_clean_feature hooks)
- Skeletal test classes for all three fixture tiers

### Phase 2: Progressive AI Review (Current)

**Status**: Contract review by multiple AIs (Ollama → Claude → Grok → Gemini)

**Goals:**
- Identify weak preconditions/postconditions
- Detect missing invariants
- Verify MML model query design
- Confirm frame conditions are correct

### Phase 3: Implementation Tasks (Next)

**Planned**: Break Phase 1 contracts into 40-50 implementation tasks with acceptance criteria.

Tasks will be organized by:
- System-level fixture initialization and cleanup
- Feature-level fixture lifecycle management
- Nested fixture (with_fixture) implementation
- Domain-specific assertions (date/time, paths, collections, exceptions)

### Phase 4: Feature Implementation

**Planned**: Implement each feature body while keeping contracts FROZEN.

Key implementation patterns:
- Registry pattern for TEST_SYSTEM singleton
- Factory pattern for TEST_FIXTURE instances
- Agent-based scoping for with_fixture callback execution
- Exception-safe cleanup using SCOOP rescue clauses

### Phase 5: Comprehensive Test Coverage

**Planned**: Generate 150+ adversarial tests covering:
- Boundary conditions (empty collections, zero/negative values)
- Stress tests (10K+ operations, resource exhaustion)
- Concurrency tests (SCOOP with many separate actors)
- Exception-safety tests (failure modes, cleanup guarantees)

### Phase 6: Production Hardening

**Planned**: Final review, documentation, release preparation.

## Architecture Decisions

### 1. Three-Tier Fixture Model

```
Test System (once per run)
  ├── System Resources
  │   ├── Database
  │   ├── Server
  │   └── Connection Pools
  │
  └── Test Features (once per feature)
        ├── Feature Resources
        │   ├── Test Data
        │   ├── Transactions
        │   └── Temporary Files
        │
        └── Nested Fixtures (once per scope)
              ├── Scoped Resources
              │   ├── Locks
              │   ├── Savepoints
              │   └── Temp Objects
              └── LIFO Cleanup Guarantee
```

**Rationale:** Explicit tier separation reduces fixture interaction bugs, enables per-tier lifecycle management, and supports SCOOP actor isolation patterns.

### 2. Exception-Safe Design

All fixture cleanup (on_clean_test_system, on_clean_feature, with_fixture exit) must run even if callbacks throw exceptions.

**Pattern:** SCOOP rescue clauses with re-raise:
```eiffel
do
    acquire_resource
    callback.call (Void)
rescue
    -- Guarantee cleanup runs before re-raising
    cleanup_resource
    raise_if_exception
end
```

**Rationale:** Prevents resource leaks on test failure, matches strong exception guarantee from ISO C++.

### 3. MML Model Queries (Phase 5B+)

For collections, model queries will provide precise semantics:

```eiffel
-- Example: TEST_FIXTURE with internal collection
feature -- Model Queries
    items_model: MML_SEQUENCE [ITEM]
        -- Mathematical model of internal items.
        do
            create Result.make_empty
            across internal_list as ic loop
                Result := Result & @ic.item
            end
        end
```

Then postconditions use frame conditions:
```eiffel
ensure
    item_added: items_model.count = old items_model.count + 1
    item_at_end: items_model [items_model.count] = a_item
    others_unchanged: items_model.removed_last |=| old items_model
```

**Rationale:** Enables formal verification of collection invariants, particularly important for nested fixture LIFO ordering guarantees.

### 4. DBC as First-Class Documentation

Contracts are not just assertions—they document the intended behavior explicitly:

```eiffel
on_prepare_feature
    require
        -- Precondition documents when this hook runs
        all_system_fixtures_ready: system_initialized
    do
        -- Implementation
    ensure
        -- Postcondition documents what this hook guarantees
        feature_isolation_ready: transaction_active
```

**Rationale:** Eiffel's Design by Contract makes intentions explicit at compile time, catching bugs earlier than languages with weak type systems.

### 5. SCOOP Compatibility

All classes use `separate` generic constraints for SCOOP compatibility:

```eiffel
class TEST_FIXTURE [G -> detachable separate ANY]
    -- Generic parameter supports separate actors
```

This allows test systems to work with SCOOP-enabled libraries without type conflicts (VUAR(2) errors).

**Rationale:** Ecosystem-wide SCOOP support ensures libraries can be tested in actor contexts.

## Feature Breakdown

### System-Level Fixtures (TEST_SYSTEM)

**Features to Implement:**
1. on_prepare_test_system
   - Initialize singleton resource registry
   - Start external services (database, server)
   - Verify all resources acquired

2. on_clean_test_system
   - Shutdown all services in reverse order
   - Release all resources
   - Verify no leaks

**Test Coverage:** 5 tests
- test_system_initialized_once
- test_system_cleaned_once
- test_system_cleanup_on_exception
- test_system_cleanup_order_lifo
- test_system_stress_many_resources

### Feature-Level Fixtures (TEST_FIXTURE + Hooks)

**Features to Implement:**
1. on_prepare_feature (TEST_SET_BASE_EXTENDED)
   - Called before each test feature
   - Set up feature-scoped state

2. on_clean_feature (TEST_SET_BASE_EXTENDED)
   - Called after each test feature
   - Clean up feature state (even on exception)

3. TEST_FIXTURE factory pattern
   - create_test_fixture: create fresh fixture instance
   - is_valid: query fixture state

**Test Coverage:** 10 tests
- test_prepare_feature_called_before_each_test
- test_clean_feature_called_after_each_test
- test_clean_feature_called_on_test_failure
- test_fixture_factory_creates_fresh_instances
- test_fixture_composition_multiple_types
- test_no_overhead_if_hooks_not_overridden

### Nested Fixtures (with_fixture Agent Pattern)

**Features to Implement:**
1. with_fixture (callback: PROCEDURE)
   - Execute callback in scoped context
   - Acquire resources on entry
   - Release resources on exit
   - Support nesting (LIFO order)
   - Exception-safe: cleanup even if callback throws

**Test Coverage:** 7 tests
- test_with_fixture_scoped_execution
- test_with_fixture_cleanup_on_success
- test_with_fixture_cleanup_on_exception
- test_with_fixture_exception_reraise
- test_nested_with_fixture_composition
- test_with_fixture_zero_resource_leaks (10K iterations)
- test_transaction_savepoint_pattern

### Domain-Specific Assertions

**Features to Implement (20+):**

**Date/Time Assertions (3):**
1. assert_date_before (tag, date, threshold)
2. assert_date_after (tag, date, threshold)
3. assert_date_in_range (tag, date, min, max)

**Path/File Assertions (3):**
1. assert_path_exists (tag, path)
2. assert_file_readable (tag, path)
3. assert_directory_writable (tag, path)

**Exception Assertions (2):**
1. assert_exception_thrown (tag, agent_code)
2. assert_exception_message_contains (tag, exception, substring)

**Collection Assertions (2+):**
1. assert_collection_contains_all (tag, collection, expected_items)
2. assert_collection_has_distinct_items (tag, collection)

**Complex Type Assertions (2+):**
1. assert_json_equal (tag, expected_json, actual_json)
2. assert_xml_contains (tag, xml, xpath_expression)

**Test Coverage:** 24 tests (one per assertion plus edge cases)

## Verification Strategy

### Unit Tests (Phases 4-5)

Each feature has explicit unit tests:
```eiffel
test_on_prepare_feature_called_before_test
    local
        l_test: MY_TEST_SET
    do
        create l_test
        l_test.run_feature ("test_something")
        -- Hook call verified via internal state change
        assert_true ("prepare_called", l_test.prepare_was_called)
    end
```

### Integration Tests

Multi-tier fixture interaction:
```eiffel
test_nested_with_fixture_composition
    -- Verify outer fixture exits AFTER inner fixture
    -- Verify LIFO cleanup order maintained
```

### Stress Tests

Pathological cases:
```eiffel
test_with_fixture_zero_resource_leaks
    -- 10K+ nested with_fixture blocks
    -- Monitor memory to ensure no accumulation
```

### SCOOP Consumer Integration

Verify library works when consumed by SCOOP-enabled projects (catches VUAR(2) errors).

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Exception-safe cleanup complex | Use SCOOP rescue pattern consistently; heavy testing |
| LIFO ordering hard to verify | MML model queries (Phase 5B+) provide formal semantics |
| Performance regression | Benchmark before/after; lazy initialization for hooks |
| Fixture leaks on exception | Mandatory exception test for each tier |

## Success Criteria

- [ ] All contracts compile without warnings (Phase 1) ✓
- [ ] AI reviews identify no semantic issues (Phase 2)
- [ ] 40-50 implementation tasks generated (Phase 3)
- [ ] All feature bodies implemented (Phase 4)
- [ ] 150+ tests pass (Phase 5)
- [ ] Zero warnings, zero stubs (Phase 6)
- [ ] Documentation complete and reviewed

## Next Steps

1. Complete Phase 2 (AI Review) - current
2. Generate implementation tasks from contracts (Phase 3)
3. Implement feature bodies (Phase 4)
4. Add comprehensive tests (Phase 5)
5. Final hardening and release (Phase 6)
