# Phase 2 Review Synopsis: simple_testing Fixture Contracts

**Status:** REVIEW COMPLETE - Ready for User Approval

**Date:** 2026-02-04
**Reviewed By:** Ollama (qwen2.5-coder:14b)
**Issues Identified:** 20 total (11 High, 9 Medium)
**Recommendation:** APPROVE WITH MINOR REFINEMENTS

---

## Executive Summary

The Phase 1 contract skeletons for simple_testing are **semantically sound** but suffer from **vague postconditions and missing structural contracts**. The three-tier fixture architecture (system-level, feature-level, nested) is well-designed, but the DBC specifications need concrete verification conditions.

**Overall Assessment:** ✓ **VIABLE FOR IMPLEMENTATION** with recommended contract improvements before Phase 4.

---

## Detailed Findings

### 1. System-Level Fixtures (TEST_SYSTEM)

**Status:** Structurally sound, contracts too vague

**Issues Found:**
- ❌ Postcondition on `on_prepare_test_system`: "Resources initialized" is not verifiable
- ❌ Postcondition on `on_clean_test_system`: "All resources released" is not verifiable
- ⚠️ Missing: Precondition on `on_prepare_test_system` to check system not already initialized
- ⚠️ Missing: Precondition on `on_clean_test_system` to check `on_prepare_test_system` was called
- ⚠️ Missing: Invariant for TEST_SYSTEM state consistency

**Recommendations:**
```eiffel
on_prepare_test_system
    require
        system_not_initialized: not is_initialized
    do
        -- Implementation
    ensure
        system_initialized: is_initialized
        database_connected: database.is_connected
        server_running: server.is_running
    end

on_clean_test_system
    require
        system_initialized: is_initialized
    do
        -- Implementation
    ensure
        system_cleaned: not is_initialized
        database_closed: not database.is_connected
        server_stopped: not server.is_running
    end

invariant
    system_consistent: is_initialized = (database.is_connected and server.is_running)
end
```

**Impact:** Medium - These are deferred classes, so concrete implementations will provide the actual state queries

---

### 2. Feature-Level Fixtures (TEST_FIXTURE)

**Status:** Lifecycle pattern correct, but vague postconditions

**Issues Found:**
- ❌ Postcondition on `on_create`: "Fixture is ready for testing" is not verifiable
- ❌ Postcondition on `on_destroy`: "All resources released" is not verifiable
- ⚠️ Missing: Precondition on `on_destroy` to ensure `on_create` was called
- ⚠️ Unclear: Invariant "Fixture must be valid when in use" - what does "in use" mean?
- ⚠️ Missing: Default implementation of `is_valid` query

**Recommendations:**
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
        Result := False  -- Default: invalid until explicitly created and initialized
    end

invariant
    -- State machine: False → on_create → True → on_destroy → False
    lifecycle_consistent: created implies is_valid
end
```

**Impact:** Medium - Simple fixes that make the contract queryable

---

### 3. Feature-Level Hooks (TEST_SET_BASE_EXTENDED)

**Status:** Hook design good, but postconditions too weak

**Issues Found:**
- ⚠️ Postconditions on `on_prepare_feature/on_clean_feature`: "Ready for testing" and "State cleaned" are too vague
- ⚠️ Missing: Precondition on `on_clean_feature` to verify `on_prepare_feature` was called
- ❌ Postcondition on `with_fixture`: "Fixture context exited" - how to verify?
- ❌ Missing: Formal specification of LIFO cleanup ordering
- ❌ Missing: Exception-safety guarantee in postcondition

**Recommendations:**
```eiffel
on_prepare_feature
    do
        -- Setup
    ensure
        feature_ready: -- Feature-specific query from subclass
    end

on_clean_feature
    require
        prepare_called: -- Feature-specific pre-check
    do
        -- Cleanup
    ensure
        feature_cleaned: -- Feature-specific query from subclass
    end

with_fixture (callback: PROCEDURE)
    require
        callback_not_void: callback /= Void
    do
        -- Implementation with exception-safety
    ensure
        fixture_stack_empty: fixture_stack.is_empty
        callback_completed: callback_executed_or_exception_thrown
        lifo_order_maintained: fixture_stack.count = old fixture_stack.count - 1
        exception_safe: -- Even if callback throws, this postcondition holds
    end

invariant
    fixture_stack_consistent: fixture_stack_model |=| old fixture_stack_model or fixture_stack_model.count = old fixture_stack_model.count + 1
end
```

**Note:** With MML_SEQUENCE, LIFO ordering can be formally verified:
- Before: `old fixture_stack = [A, B, C]`
- After: `fixture_stack = [A, B]` (C was removed)
- Postcondition: `fixture_stack.removed_last |=| old fixture_stack`

**Impact:** Medium - Requires careful implementation with MML model queries in Phase 5B

---

### 4. MML (Mathematical Model Library) Readiness

**Assessment:** Contracts are compatible with MML but don't yet use it

**Recommendation for Phase 5B:**

Once implementation bodies exist, add model queries:

```eiffel
class TEST_SYSTEM
    feature -- Model Queries
        resources_model: MML_SET [RESOURCE]
            -- Mathematical model of active resources
            do
                create Result.make_empty
                across active_resources as ic loop
                    Result := Result & @ic.item
                end
            end

    feature -- Updated postcondition with frame condition
        on_clean_test_system
            ensure
                all_resources_released: resources_model.is_empty
                other_state_unchanged: system_data |=| old system_data
            end
end
```

---

## Approval Checklist

**Before Proceeding to Phase 3 (Tasks), Address:**

- [ ] **Critical:** Replace vague postconditions with concrete state queries
  - Affected: on_prepare_test_system, on_clean_test_system, on_create, on_destroy, on_prepare_feature, on_clean_feature, with_fixture
  - Severity: Must fix before Phase 4 (implementation)

- [ ] **Important:** Add preconditions to cleanup/destroy features
  - Affected: on_clean_test_system, on_destroy, on_clean_feature
  - Severity: Prevents misuse, should be in place

- [ ] **Important:** Add invariants for state consistency
  - Affected: TEST_SYSTEM, TEST_FIXTURE, TEST_SET_BASE_EXTENDED
  - Severity: Clarifies class contracts, important for verification

- [ ] **Deferred to Phase 5B:** Add MML model queries for collection semantics
  - Affected: with_fixture fixture_stack, system resources_model, fixture state_model
  - Severity: Phase 5B task (after implementation bodies exist)

---

## Risk Assessment

| Risk | Likelihood | Severity | Mitigation |
|------|------------|----------|-----------|
| Vague postconditions allow incorrect implementation | Medium | High | Fix postconditions now, before Phase 3 tasks |
| Cleanup order bugs in with_fixture | Medium | High | Add MML-based LIFO postcondition in Phase 5B |
| Exception-safety not verified | Medium | Medium | Heavy testing in Phase 5 (50+ exception test cases) |
| Resource leaks in cleanup | Low | High | Add frame conditions in Phase 5B |

---

## Recommendation

**✓ APPROVE FOR PHASE 3** with requirement to refine contracts in Phase 2B (Claude review for MML patterns)

**Next Steps:**
1. Generate Phase 3 implementation tasks from these refined contracts
2. Focus on concrete state queries (`is_valid`, `is_initialized`, `is_connected`, etc.)
3. Implement exception-safe cleanup patterns
4. Phase 5B: Add MML model queries and frame conditions

---

## Files Ready for Review

- `.eiffel-workflow/approach.md` - Implementation strategy ✓
- `.eiffel-workflow/evidence/phase1-compile.txt` - Compilation proof ✓
- `.eiffel-workflow/evidence/phase2-ollama-response.md` - AI review ✓
- `.eiffel-workflow/prompts/phase2-claude-review.md` - Claude ready (contains Ollama summary)

---

## Summary of Contract Improvements Needed

| Class | Feature | Issue | Fix |
|-------|---------|-------|-----|
| TEST_SYSTEM | on_prepare | Vague postcondition | Add concrete state queries |
| TEST_SYSTEM | on_clean | Vague postcondition | Add concrete state queries |
| TEST_SYSTEM | on_clean | Missing precondition | Require on_prepare was called |
| TEST_SYSTEM | class | Missing invariant | Add state consistency check |
| TEST_FIXTURE | on_create | Vague postcondition | Ensure is_valid = True |
| TEST_FIXTURE | on_destroy | Vague postcondition | Ensure is_valid = False |
| TEST_FIXTURE | on_destroy | Missing precondition | Require is_valid = True |
| TEST_FIXTURE | class | Vague invariant | Define "in use" = created and not destroyed |
| TEST_SET_BASE_EXTENDED | on_prepare_feature | Vague postcondition | Add feature-specific query |
| TEST_SET_BASE_EXTENDED | on_clean_feature | Vague postcondition | Add feature-specific query |
| TEST_SET_BASE_EXTENDED | on_clean_feature | Missing precondition | Require on_prepare was called |
| TEST_SET_BASE_EXTENDED | with_fixture | Vague postcondition | Add fixture_stack.is_empty |
| TEST_SET_BASE_EXTENDED | with_fixture | No LIFO verification | Add MML-based frame condition (Phase 5B) |
| TEST_SET_BASE_EXTENDED | with_fixture | No exception-safety contract | Add rescue guarantee (Phase 5B) |

**Total Contract Improvements Needed: 14** (7 vague postconditions, 4 missing preconditions, 3 missing invariants/frame conditions)

---

**Phase 2 Status: READY FOR USER APPROVAL**

Proceed to Phase 3 (Tasks) to break these improvements into implementation tasks, or revise contracts further with additional AI reviews (Claude, Grok, Gemini).
