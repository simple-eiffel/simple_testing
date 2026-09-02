# Phase 6: Adversarial Test Suggestions

## Contracts to Review

### TEST_SYSTEM (System-Level Lifecycle)
```eiffel
deferred class TEST_SYSTEM
feature
  on_prepare_test_system
    require: system_not_initialized: not is_initialized
    ensure: system_initialized: is_initialized

  on_clean_test_system
    require: system_initialized: is_initialized
    ensure: system_cleaned: not is_initialized

  is_initialized: BOOLEAN (deferred)
end
```

### TEST_FIXTURE (Feature-Level Lifecycle)
```eiffel
deferred class TEST_FIXTURE
feature
  on_create
    ensure: fixture_valid: is_valid

  on_destroy
    require: fixture_valid: is_valid
    ensure: fixture_invalid: not is_valid

  is_valid: BOOLEAN
end
```

### TEST_SET_BASE_EXTENDED (Nested Fixtures)
```eiffel
deferred class TEST_SET_BASE_EXTENDED
feature
  on_prepare_feature
    ensure: feature_ready: True

  on_clean_feature
    ensure: feature_cleaned: True

  with_fixture (callback: PROCEDURE)
    require: callback_not_void: callback /= Void
    ensure: fixture_context_exited: True
end
```

## Current Tests

All existing tests are placeholder assertions (contract-only verification).

## Adversarial Test Categories

### 1. STATE TRANSITION EDGE CASES
- [ ] Multiple prepare calls without cleanup (should fail precondition)
- [ ] Multiple cleanup calls without prepare (should fail precondition)
- [ ] Prepare → Prepare → Cleanup (state violation)
- [ ] Cleanup → Cleanup (double cleanup)

### 2. FIXTURE LIFECYCLE EDGE CASES
- [ ] Create fixture, destroy without create (should fail precondition)
- [ ] Create → Create without destroy (state violation)
- [ ] Destroy → Destroy (double destroy)
- [ ] Long-lived fixture with 1000+ state transitions

### 3. EXCEPTION-SAFETY TESTS (CRITICAL)
- [ ] on_prepare_test_system throws → is_initialized must still be False (precondition must hold)
- [ ] on_clean_test_system throws → is_initialized must still be False (cleanup must complete)
- [ ] on_create throws → is_valid must still be False
- [ ] on_destroy throws → is_valid must still be False
- [ ] callback in with_fixture throws → cleanup must run (LIFO ordering verified)

### 4. SCOOP CONCURRENCY STRESS (CRITICAL)
- [ ] Multiple threads calling on_prepare_test_system simultaneously (race condition test)
- [ ] Multiple threads creating/destroying fixtures (concurrent lifecycle test)
- [ ] Nested with_fixture with SCOOP separate objects
- [ ] Concurrent access to is_initialized during prepare/cleanup

### 5. RESOURCE EXHAUSTION TESTS
- [ ] 10,000+ fixture creations in loop (memory leak detection)
- [ ] 10,000+ on_prepare/on_clean cycles (resource accumulation test)
- [ ] Deeply nested with_fixture (100+ levels deep) (stack overflow test)

### 6. LIFO ORDERING VERIFICATION (MML)
- [ ] Nested with_fixture: fixture1 → fixture2 → fixture3 → cleanup order must be 3,2,1
- [ ] Exception during fixture2 → fixture3 must clean up, then fixture2, then fixture1 (LIFO)
- [ ] MML model verification: fixture stack state matches expected order

### 7. INVARIANT VIOLATION DETECTION
- [ ] is_initialized state inconsistency (should violate class invariant)
- [ ] is_valid state inconsistency (should violate class invariant)

### 8. BOUNDARY VALUE TESTS
- [ ] Empty callback (no-op in with_fixture)
- [ ] Callback that immediately throws
- [ ] Callback that returns a value (should be ignored)

## Test Implementation Strategy

For each category, implement:
1. **Happy path**: Normal operation (contract satisfied)
2. **Precondition violation**: Contract broken intentionally (should fail gracefully)
3. **Postcondition violation**: Implementation fails to satisfy contract (bug detection)
4. **Exception safety**: Cleanup runs even if logic throws (rescue clause testing)
5. **SCOOP concurrent**: Multiple actors simultaneously (concurrency verification)

## Evidence Required

For each test:
- Test name (clear intent)
- Test input (what triggers the test)
- Expected outcome (contract verified)
- Actual outcome (what tests prove)
- Category (from list above)
