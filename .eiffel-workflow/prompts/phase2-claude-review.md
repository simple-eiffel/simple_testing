# Eiffel Contract Review Request (Claude)

**Task:** Review Eiffel Design by Contract specifications with focus on MML (Mathematical Model Library) correctness and semantic rigor.

**Review Scope:**
- Postconditions use of `old` expressions
- MML model query design for collections
- Frame conditions using `|=|` for model equality
- Semantic correctness of contract ordering

---

## Ollama's Review (Completed)

### Summary of Ollama Findings

**Total Issues Found:** 20
- **Critical:** 11 high-severity issues
- **Structural:** 9 medium-severity issues

**Key Patterns Identified:**
1. **Vague Postconditions** - Almost all ensure clauses use abstract language ("Resources initialized", "Fixture ready") without concrete verification
2. **Missing Preconditions** - Cleanup features don't verify setup was called first (e.g., on_clean should require on_prepare)
3. **Missing Invariants** - No class-level consistency guarantees (e.g., if resources allocated, they must be released)
4. **Weak with_fixture Contracts** - Exception-safety and LIFO ordering not formally specified
5. **is_valid Semantics** - Deferred query with no default implementation or lifecycle documentation

**Ollama's Concrete Suggestions:**
- Replace "Resources initialized" with specific state queries (database.is_connected, server.is_running, etc.)
- Add require clauses to cleanup features (e.g., require prepare_called: is_valid)
- Add invariants for system/fixture state consistency
- Use fixture_stack: MML_SEQUENCE to formally specify LIFO ordering
- Document is_valid lifecycle (False→on_create→True→on_destroy→False)

---

## Contracts to Review

### File 1: TEST_SYSTEM (System-Level Fixture Lifecycle)

```eiffel
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

---

### File 2: TEST_FIXTURE (Feature-Level Factory Pattern)

```eiffel
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

---

### File 3: TEST_SET_BASE_EXTENDED (Feature-Level Hooks + Nested Fixtures)

```eiffel
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

---

## MML-Focused Review Checklist

- [ ] **Model Queries:** Are there collection attributes that need MML model queries?
  - TEST_SYSTEM resource registry: should have model of active resources
  - TEST_FIXTURE state: should have model of acquired resources
  - with_fixture nested calls: should have model of fixture stack

- [ ] **Frame Conditions:** Are there frame conditions missing?
  - on_clean_test_system should specify: released_resources |=| (nothing else changes)
  - on_clean_feature should specify: feature_data |=| (system data unchanged)

- [ ] **Old Expressions:** Should postconditions use `old` to capture pre-state?
  - Example: on_clean_feature postcondition should verify state was modified
  - Example: with_fixture should guarantee: state_after = state_before (idempotent cleanup)

- [ ] **Collection Semantics:** If resources are stored in collections, are model queries defined?
  - Query names: resources_model, fixture_stack_model, callbacks_model
  - Should return: MML_SET [RESOURCE], MML_SEQUENCE [FIXTURE], etc.

- [ ] **Semantic Ordering:** Are postconditions ordered correctly?
  - Root cause (what changed) should come FIRST
  - Then consequences (what follows)
  - Then invariants (what didn't change)

---

## Key Questions for Claude

1. **MML Completeness:** Which features should have explicit MML model queries? Show the query signature.

2. **Frame Conditions:** Write concrete postconditions with frame conditions for:
   - on_clean_test_system (what resources were released? what else stayed the same?)
   - on_clean_feature (what feature data was cleaned? what stayed the same?)

3. **Old Expressions:** Show how `old` expressions should appear in postconditions for on_create vs on_destroy.

4. **Semantic Verification:** How would you verify that with_fixture cleanup runs even if callback throws? (Hint: should be in postcondition with exception-safety guarantee)

5. **Stack Semantics:** How would an MML_SEQUENCE model guarantee LIFO ordering of nested with_fixture calls?

---

## Output Format

For each issue or improvement, provide:

```
**ISSUE/IMPROVEMENT:** [Description]
**LOCATION:** [Class.feature, line range if applicable]
**MML PATTERN:** [If related to model queries or frame conditions]
**CONCRETE FIX:** [Show the corrected contract with actual Eiffel code]

Example:
**ISSUE:** on_clean_test_system postcondition is not verifiable - no model of resources
**LOCATION:** TEST_SYSTEM.on_clean_test_system, ensure clause
**MML PATTERN:**
  Add model query: resources_model: MML_SET [RESOURCE]
  Add frame condition postcondition: resources_released: old resources_model & current_resources |=| {}
**CONCRETE FIX:**
  ensure
    resources_released: resources_model.count = 0
    system_stable: system_state = old system_state  -- Everything else unchanged
```

Submit complete analysis as text response below.
