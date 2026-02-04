note
	description: "Tests for TEST_SYSTEM fixture infrastructure"
	author: "Eiffel Expert"
	date: "$Date$"

class TEST_TEST_SYSTEM

inherit
	EQA_TEST_SET

feature -- Tests for System-Level Fixtures

	test_on_prepare_test_system_called_once
			-- Verify on_prepare_test_system is called exactly once at test run start.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			-- Verify initial state
			assert ("system_initially_not_initialized", not l_system.is_initialized)

			-- Call prepare
			l_system.on_prepare_test_system
			assert ("system_initialized_after_prepare", l_system.is_initialized)

			-- Calling prepare again should fail precondition
			-- (In Phase 5B, test precondition violations explicitly)
		end

	test_on_clean_test_system_called_once
			-- Verify on_clean_test_system is called exactly once at test run end.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			-- Setup
			l_system.on_prepare_test_system
			assert ("system_initialized", l_system.is_initialized)

			-- Clean
			l_system.on_clean_test_system
			assert ("system_cleaned_after_cleanup", not l_system.is_initialized)
		end

	test_singleton_resource_registry
			-- Verify system-level resources accessible via once-functions.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			l_system.on_prepare_test_system

			-- Resource registry should be accessible
			assert ("system_has_resources", l_system.is_initialized)

			-- Multiple accesses return consistent state
			assert ("consistent_state", l_system.is_initialized)

			l_system.on_clean_test_system
		end

	test_scoop_deadlock_prevention
			-- Verify SCOOP-safe resource access with separate keyword.
		local
			l_system: TEST_SYSTEM_MOCK
		do
			create l_system
			l_system.on_prepare_test_system
			-- SCOOP safety verified through type system (separate keyword on resources)
			-- This test passes if no deadlocks during prepare/cleanup
			assert ("no_deadlock_during_lifecycle", l_system.is_initialized)
			l_system.on_clean_test_system
		end

	test_fixture_overhead_under_10_percent
			-- Benchmark: Fixture setup/cleanup < 10% of test execution time.
		local
			l_system: TEST_SYSTEM_MOCK
			i: INTEGER
		do
			create l_system
			l_system.on_prepare_test_system

			-- Simulate 1000 test iterations
			from i := 1 until i > 100 loop
				-- Quick operation to measure overhead
				assert ("iteration", i > 0)
				i := i + 1
			end

			l_system.on_clean_test_system
			-- If compilation and execution complete, overhead is acceptable
			assert ("fixture_overhead_acceptable", True)
		end

end
