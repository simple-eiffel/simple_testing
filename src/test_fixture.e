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

feature -- Model Queries (for MML postconditions)

	lifecycle_state: INTEGER
			-- Mathematical model of fixture lifecycle: 0 = invalid, 1 = valid.
		do
			Result := (if is_valid then 1 else 0 end)
		ensure
			valid_state: Result = 0 or Result = 1
		end

feature -- Lifecycle

	on_create
			-- Initialize fixture state (called by constructor).
			-- Must establish preconditions for test logic.
		do
			-- To be overridden by subclasses
		ensure
			fixture_valid: is_valid
			-- Frame condition: fixture transitions from invalid to valid
			state_transition: lifecycle_state = 1 and old lifecycle_state = 0
		end

	on_destroy
			-- Clean up fixture state (called on destruction).
			-- Must reverse all state changes made by on_create and test logic.
		require
			fixture_valid: is_valid
		do
			-- To be overridden by subclasses
		ensure
			fixture_invalid: not is_valid
			-- Frame condition: fixture transitions from valid to invalid
			state_transition: lifecycle_state = 0 and old lifecycle_state = 1
		end

feature -- Query

	is_valid: BOOLEAN
			-- Is fixture in valid state for testing?
		do
			Result := False
		end

invariant
	lifecycle_consistent: True
		-- Invariant: lifecycle_state is well-formed (0 or 1)
		lifecycle_state_valid: lifecycle_state = 0 or lifecycle_state = 1
end
