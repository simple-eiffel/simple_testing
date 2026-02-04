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

inherit
	ANY
		redefine
			default_create
		end

feature -- Model Queries (for MML postconditions)

	initialization_state: INTEGER
			-- Mathematical model of initialization state: 0 = uninitialized, 1 = initialized.
		do
			Result := (if is_initialized then 1 else 0 end)
		ensure
			valid_state: Result = 0 or Result = 1
		end

feature -- System-Level Hooks

	on_prepare_test_system
			-- Initialize system-level resources (database, server, pools).
			-- Called exactly once at test run start, before any test class.
		require
			system_not_initialized: not is_initialized
		do
			-- To be overridden by subclasses
		ensure
			system_initialized: is_initialized
			-- Frame condition: only initialization state changed
			state_transition: initialization_state = 1 and old initialization_state = 0
		end

	on_clean_test_system
			-- Clean up system-level resources.
			-- Called exactly once at test run end, after all tests.
			-- Must be exception-safe: cleanup always runs even if tests fail.
		require
			system_initialized: is_initialized
		do
			-- To be overridden by subclasses
		ensure
			system_cleaned: not is_initialized
			-- Frame condition: only initialization state changed
			state_transition: initialization_state = 0 and old initialization_state = 1
		end

feature -- Status Query

	is_initialized: BOOLEAN
			-- Is the test system initialized?
		deferred
		end

feature {NONE} -- Initialization

	default_create
			-- Create uninitialized system.
		do
			-- Subclasses will provide default initialization
		ensure then
			not_initialized: not is_initialized
		end

invariant
	system_consistent: True
		-- Invariant: initialization_state is well-formed (0 or 1)
		initialization_state_valid: initialization_state = 0 or initialization_state = 1
end
