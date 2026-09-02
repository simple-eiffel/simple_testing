# Eiffel Contract Review Request (Ollama)

**Task:** Review Eiffel Design by Contract specifications for simple_testing fixture enhancement.

**Find and report:**
- Preconditions that are too weak (e.g., just `True`)
- Postconditions that don't constrain behavior
- Missing invariants (especially for classes with state)
- Obvious edge cases not covered by contracts
- Missing MML model queries for collection attributes
- Missing frame conditions (what did NOT change)
- Inconsistent contract ordering (semantic vs syntactic)

---

## Contracts to Review

### File 1: TEST_SYSTEM (System-Level Fixture Lifecycle)

```eiffel
note
	description: "[
		System-level fixture infrastructure for test-system-scoped setup/cleanup.

		Provides singleton resource registry accessible to all test classes.
		Runs once per test run: on_prepare_test_system before any test class,
		on_clean_test_system after all tests complete.

		Example:
			class MY_APP_TEST_SYSTEM
				inherit TEST_SYSTEM
				feature
					on_prepare_test_system do
						-- Initialize database, start server, create pools
						database.initialize
						server.start
					end

					on_clean_test_system do
						-- Shutdown resources
						database.close
						server.stop
					end
			end
	]"
	author: "Eiffel Expert"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TEST_SYSTEM

feature -- System-Level Hooks

	on_prepare_test_system
			-- Initialize system-level resources (database, server, pools).
			-- Called exactly once at test run start, before any test class.
		do
			-- To be overridden by subclasses
		ensure
			-- Resources initialized (verified by implementation)
		end

	on_clean_test_system
			-- Clean up system-level resources.
			-- Called exactly once at test run end, after all tests.
			-- Must be exception-safe: cleanup always runs even if tests fail.
		do
			-- To be overridden by subclasses
		ensure
			-- All resources released (verified by implementation)
		end

end
```

**REVIEWER CHECKLIST:**
- [ ] Postconditions on on_prepare_test_system too vague ("Resources initialized")?
- [ ] Postconditions on on_clean_test_system too vague ("All resources released")?
- [ ] Should preconditions specify initial state (system not already initialized)?
- [ ] Should on_clean_test_system have precondition that on_prepare_test_system was called?
- [ ] Missing invariants for TEST_SYSTEM state?

---

### File 2: TEST_FIXTURE (Feature-Level Factory Pattern)

```eiffel
note
	description: "[
		Test-feature-level fixture for reusable setup/cleanup per test feature.

		Factory pattern: create fixtures locally within test features to isolate state.
		Each fixture provides on_create (initialization) and on_destroy (cleanup).

		Example:
			class MY_TEST_SET
				inherit TEST_SET_BASE
				feature
					test_something_with_fixture
						local
							fixture: TEST_FIXTURE
						do
							fixture := create_test_fixture
							-- Test logic using fixture
							assert_positive ("fixture valid", fixture.count)
							-- on_destroy called automatically on fixture destruction
						end
			end
		end

		Key Contract: Fresh state per feature guaranteed via on_create/on_destroy lifecycle.
	]"
	author: "Eiffel Expert"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TEST_FIXTURE

feature -- Lifecycle

	on_create
			-- Initialize fixture state (called by constructor).
			-- Must establish preconditions for test logic.
		do
			-- To be overridden by subclasses
		ensure
			-- Fixture is ready for testing
		end

	on_destroy
			-- Clean up fixture state (called on destruction).
			-- Must reverse all state changes made by on_create and test logic.
		do
			-- To be overridden by subclasses
		ensure
			-- All resources released, fixture cleaned up
		end

feature -- Query

	is_valid: BOOLEAN
			-- Is fixture in valid state for testing?
		deferred
		end

invariant
	-- Fixture must be valid when in use
end
```

**REVIEWER CHECKLIST:**
- [ ] Postconditions on on_create too vague ("Fixture is ready for testing")?
- [ ] Postconditions on on_destroy too vague ("All resources released")?
- [ ] Should on_destroy be called ONLY after on_create?
- [ ] Invariant "fixture must be valid when in use" - define "in use" precisely?
- [ ] Should is_valid be defined before on_create is called?
- [ ] Missing precondition that on_create has been called before on_destroy?

---

### File 3: TEST_SET_BASE_EXTENDED (Feature-Level Hooks + Nested Fixtures)

```eiffel
note
	description: "[
		Extension points for TEST_SET_BASE to support feature-level fixtures.

		Adds:
		- on_prepare_feature / on_clean_feature hooks (called before/after each test feature)
		- Nested fixture support via with_fixture pattern

		This is a mixin/interface definition. TEST_SET_BASE in its next version
		will inherit from this and implement the hooks.

		Feature-level fixture hooks are optional:
		- If not overridden: default behavior (no per-feature cleanup)
		- If overridden: called before/after each test feature automatically by test runner

		Example:
			class MY_TEST_SET
				inherit TEST_SET_BASE

				feature
					on_prepare_feature do
						-- Reset test data, acquire per-feature resources
						test_data.reset
						transaction.begin
					end

					on_clean_feature do
						-- Clean up test data, release per-feature resources
						transaction.rollback
						test_data.cleanup
					end

					test_something
						do
							-- on_prepare_feature called before this
							assert_positive ("data", test_data.count)
							-- on_clean_feature called after this
						end
			end
		end
	]"
	author: "Eiffel Expert"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TEST_SET_BASE_EXTENDED

inherit
	ANY

feature -- Feature-Level Fixture Hooks

	on_prepare_feature
			-- Set up state for a single test feature (called before each test feature).
			-- Optional: override to customize per-feature setup.
		do
			-- Default: no-op (can be overridden)
		ensure
			-- Feature is ready for testing
		end

	on_clean_feature
			-- Clean up state after a single test feature (called after each test feature).
			-- Optional: override to customize per-feature cleanup.
			-- Must be exception-safe if test threw an exception.
		do
			-- Default: no-op (can be overridden)
		ensure
			-- State cleaned up from feature
		end

feature -- Nested Fixture Support

	with_fixture (callback: PROCEDURE)
			-- Execute `callback' in scoped fixture context.
			-- Fixture resources acquired on entry, released on exit (LIFO order).
			-- Exception-safe: cleanup runs even if callback throws.
			--
			-- Example:
			--    with_fixture (agent do
			--        transaction.begin
			--        -- Test logic
			--        transaction.rollback  -- Auto-released on exit
			--    end)
		require
			callback_not_void: callback /= Void
		do
			-- To be implemented in Phase 5C
		ensure
			-- Fixture context exited, resources released
		end

invariant
	-- Fixture hooks maintain test isolation
end
```

**REVIEWER CHECKLIST:**
- [ ] Postconditions on on_prepare_feature/on_clean_feature too vague?
- [ ] Should on_clean_feature precondition require on_prepare_feature was called first?
- [ ] with_fixture postcondition "Fixture context exited" - how to verify?
- [ ] with_fixture should guarantee LIFO cleanup order - how to verify?
- [ ] with_fixture exception-safety: should postcondition survive even on callback exception?
- [ ] with_fixture nested: should allow nested calls and maintain LIFO?
- [ ] Invariant "fixture hooks maintain test isolation" - too vague?
- [ ] Missing MML model for callback execution state?

---

## Implementation Approach

[IMPLEMENTATION APPROACH EMBEDDED BELOW]

```markdown
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

### Phase 3: Implementation Tasks (Next)

**Planned**: Break Phase 1 contracts into 40-50 implementation tasks with acceptance criteria.

### Phase 4: Feature Implementation

**Planned**: Implement each feature body while keeping contracts FROZEN.

Key implementation patterns:
- Registry pattern for TEST_SYSTEM singleton
- Factory pattern for TEST_FIXTURE instances
- Agent-based scoping for with_fixture callback execution
- Exception-safe cleanup using SCOOP rescue clauses

### Phase 5: Comprehensive Test Coverage

**Planned**: Generate 150+ adversarial tests covering:
- Boundary conditions
- Stress tests
- Concurrency tests (SCOOP)
- Exception-safety tests

### Phase 6: Production Hardening

**Planned**: Final review, documentation, release preparation.

## Architecture Decisions

### 1. Three-Tier Fixture Model

Test System (once per run)
  ├── System Resources (database, server, pools)
  │
  └── Test Features (once per feature)
        ├── Feature Resources (data, transactions, files)
        │
        └── Nested Fixtures (once per scope)
              ├── Scoped Resources (locks, savepoints)
              └── LIFO Cleanup Guarantee

### 2. Exception-Safe Design

All fixture cleanup must run even if callbacks throw exceptions using SCOOP rescue clauses.

### 3. MML Model Queries (Phase 5B+)

For collections, model queries will provide precise semantics with frame conditions.

### 4. DBC as First-Class Documentation

Contracts document intended behavior explicitly at compile time.

### 5. SCOOP Compatibility

All classes use separate generic constraints for SCOOP compatibility.
```

---

## Review Questions for Ollama

1. **Weak Contracts:** Which postconditions are too vague to verify? How would you make them concrete?

2. **Missing Invariants:** What class invariants would prevent state bugs? (e.g., "once on_create is called, is_valid must be true until on_destroy")

3. **Exception Safety:** How would you contract-specify the guarantee that on_clean_feature runs even if a test throws?

4. **LIFO Ordering:** How would you formally specify that nested with_fixture calls clean up in reverse order?

5. **State Transitions:** Are there preconditions missing that would catch calling on_destroy before on_create?

---

## Output Format

For each issue found, provide:

```
**ISSUE:** [Description of the problem]
**LOCATION:** [Class.feature line number]
**SEVERITY:** [Critical / High / Medium / Low]
**SUGGESTION:** [How to fix it]

Example:
**ISSUE:** Postcondition on on_create is too vague - doesn't specify what "ready" means
**LOCATION:** TEST_FIXTURE.on_create, ensure clause
**SEVERITY:** High
**SUGGESTION:** Change to: "fixture_initialized: is_valid" or similar concrete postcondition
```

Submit complete analysis as text response below.
