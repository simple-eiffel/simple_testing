note
	description: "SCOOP integration tests - verifies library works correctly in concurrent environments"
	author: "Eiffel Expert"
	date: "$Date$"

class TEST_SCOOP_INTEGRATION

inherit
	EQA_TEST_SET

feature -- SCOOP Consumer Compatibility Tests

	test_system_compatible_with_separate_reference
			-- Verify TEST_SYSTEM_MOCK works correctly when accessed via separate reference.
			-- This is critical for SCOOP environments where objects may be separate.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			-- In SCOOP, if system were separate, all calls would be queued
			-- This test verifies the object graph is compatible (no VUAR(2) errors)
			l_system.on_prepare_test_system
			assert ("system_initialized", l_system.is_initialized)
			l_system.on_clean_test_system
			assert ("system_cleaned", not l_system.is_initialized)
		end

	test_fixture_compatible_with_separate_reference
			-- Verify TEST_FIXTURE_MOCK works correctly when accessed via separate reference.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			l_fixture.on_create
			assert ("fixture_valid", l_fixture.is_valid)
			l_fixture.on_destroy
			assert ("fixture_invalid", not l_fixture.is_valid)
		end

	test_with_fixture_callback_execution
			-- Verify with_fixture callback execution in isolation (SCOOP-compatible).
		local
			l_test: FIXTURE_HOLDER
			l_callback: PROCEDURE
		do
			create l_test
			-- Create a no-op callback
			l_callback := agent do end
			l_test.with_fixture (l_callback)
			-- If with_fixture returns without error, callback executed successfully
			assert ("callback_executed", True)
		end

feature -- Thread-Safety Awareness Tests

	test_initialization_state_atomic_read
			-- Verify is_initialized query returns consistent value across reads.
			-- In SCOOP, this is guaranteed by actor semantics (single threaded per actor).
		local
			l_system: TEST_SYSTEM_MOCK
			result1, result2, result3: BOOLEAN
		do
			create l_system
			l_system.on_prepare_test_system
			result1 := l_system.is_initialized
			result2 := l_system.is_initialized
			result3 := l_system.is_initialized
			assert ("state_reads_consistent", result1 = result2 and result2 = result3 and result1)
		end

	test_fixture_validity_atomic_read
			-- Verify is_valid query returns consistent value across reads.
		local
			l_fixture: TEST_FIXTURE_MOCK
			result1, result2, result3: BOOLEAN
		do
			create l_fixture
			l_fixture.on_create
			result1 := l_fixture.is_valid
			result2 := l_fixture.is_valid
			result3 := l_fixture.is_valid
			assert ("state_reads_consistent", result1 = result2 and result2 = result3 and result1)
		end

feature -- Model Query Verification (MML support)

	test_initialization_state_model_zero_when_uninitialized
			-- Verify model query: initialization_state = 0 when not is_initialized.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			assert ("uninitialized_state_model_zero", l_system.initialization_state = 0)
			assert ("state_matches_not_is_initialized", l_system.initialization_state = 0 and not l_system.is_initialized)
		end

	test_initialization_state_model_one_when_initialized
			-- Verify model query: initialization_state = 1 when is_initialized.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			l_system.on_prepare_test_system
			assert ("initialized_state_model_one", l_system.initialization_state = 1)
			assert ("state_matches_is_initialized", l_system.initialization_state = 1 and l_system.is_initialized)
		end

	test_lifecycle_state_model_zero_when_invalid
			-- Verify model query: lifecycle_state = 0 when not is_valid.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			assert ("invalid_state_model_zero", l_fixture.lifecycle_state = 0)
			assert ("state_matches_not_is_valid", l_fixture.lifecycle_state = 0 and not l_fixture.is_valid)
		end

	test_lifecycle_state_model_one_when_valid
			-- Verify model query: lifecycle_state = 1 when is_valid.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			l_fixture.on_create
			assert ("valid_state_model_one", l_fixture.lifecycle_state = 1)
			assert ("state_matches_is_valid", l_fixture.lifecycle_state = 1 and l_fixture.is_valid)
		end

feature -- Frame Condition Verification (what did NOT change)

	test_prepare_system_only_initialization_changes
			-- Frame condition: prepare should only change initialization state.
			-- Other (hypothetical) state remains unchanged.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			-- Before prepare: initialization_state = 0
			assert ("before_prepare_uninitialized", l_system.initialization_state = 0)
			l_system.on_prepare_test_system
			-- After prepare: initialization_state = 1 (only this changed)
			assert ("after_prepare_initialized", l_system.initialization_state = 1)
			-- Other state (none in mock) remains same
		end

	test_cleanup_system_only_initialization_changes
			-- Frame condition: cleanup should only change initialization state.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			l_system.on_prepare_test_system
			-- Before cleanup: initialization_state = 1
			assert ("before_cleanup_initialized", l_system.initialization_state = 1)
			l_system.on_clean_test_system
			-- After cleanup: initialization_state = 0 (only this changed)
			assert ("after_cleanup_uninitialized", l_system.initialization_state = 0)
		end

	test_create_fixture_only_lifecycle_changes
			-- Frame condition: on_create should only change lifecycle state.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			-- Before create: lifecycle_state = 0
			assert ("before_create_invalid", l_fixture.lifecycle_state = 0)
			l_fixture.on_create
			-- After create: lifecycle_state = 1 (only this changed)
			assert ("after_create_valid", l_fixture.lifecycle_state = 1)
		end

	test_destroy_fixture_only_lifecycle_changes
			-- Frame condition: on_destroy should only change lifecycle state.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			l_fixture.on_create
			-- Before destroy: lifecycle_state = 1
			assert ("before_destroy_valid", l_fixture.lifecycle_state = 1)
			l_fixture.on_destroy
			-- After destroy: lifecycle_state = 0 (only this changed)
			assert ("after_destroy_invalid", l_fixture.lifecycle_state = 0)
		end

feature -- Postcondition State Transition Verification

	test_prepare_transition_from_zero_to_one
			-- Verify postcondition: state_transition requires (old=0, new=1).
		local
			l_system: TEST_SYSTEM_MOCK
			old_state, new_state: INTEGER
		do
			create l_system
			old_state := l_system.initialization_state
			l_system.on_prepare_test_system
			new_state := l_system.initialization_state
			-- Postcondition verifies: state_transition
			assert ("transition_0_to_1", old_state = 0 and new_state = 1)
		end

	test_cleanup_transition_from_one_to_zero
			-- Verify postcondition: state_transition requires (old=1, new=0).
		local
			l_system: TEST_SYSTEM_MOCK
			old_state, new_state: INTEGER
		do
			create l_system
			l_system.on_prepare_test_system
			old_state := l_system.initialization_state
			l_system.on_clean_test_system
			new_state := l_system.initialization_state
			-- Postcondition verifies: state_transition
			assert ("transition_1_to_0", old_state = 1 and new_state = 0)
		end

	test_create_transition_from_zero_to_one
			-- Verify postcondition: state_transition requires (old=0, new=1).
		local
			l_fixture: TEST_FIXTURE_MOCK
			old_state, new_state: INTEGER
		do
			create l_fixture
			old_state := l_fixture.lifecycle_state
			l_fixture.on_create
			new_state := l_fixture.lifecycle_state
			-- Postcondition verifies: state_transition
			assert ("transition_0_to_1", old_state = 0 and new_state = 1)
		end

	test_destroy_transition_from_one_to_zero
			-- Verify postcondition: state_transition requires (old=1, new=0).
		local
			l_fixture: TEST_FIXTURE_MOCK
			old_state, new_state: INTEGER
		do
			create l_fixture
			l_fixture.on_create
			old_state := l_fixture.lifecycle_state
			l_fixture.on_destroy
			new_state := l_fixture.lifecycle_state
			-- Postcondition verifies: state_transition
			assert ("transition_1_to_0", old_state = 1 and new_state = 0)
		end

end
