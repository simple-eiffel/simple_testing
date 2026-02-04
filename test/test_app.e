note
	description: "Test application root for simple_testing test suite"
	author: "Eiffel Expert"
	date: "$Date$"

class TEST_APP

create
	make

feature -- Initialization

	make
			-- Run the tests.
		do
			print ("Running simple_testing tests...%N%N")
			passed := 0
			failed := 0

			run_test_system_tests
			run_test_fixture_tests
			run_nested_fixtures_tests
			run_expanded_assertions_tests

			print ("%N=== ADVERSARIAL TESTS ===%N")
			run_adversarial_tests

			print ("%N=== SCOOP INTEGRATION TESTS ===%N")
			run_scoop_integration_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_test_system_tests
		do
			create system_tests
			run_test (agent system_tests.test_on_prepare_test_system_called_once, "test_on_prepare_test_system_called_once")
			run_test (agent system_tests.test_on_clean_test_system_called_once, "test_on_clean_test_system_called_once")
			run_test (agent system_tests.test_singleton_resource_registry, "test_singleton_resource_registry")
			run_test (agent system_tests.test_scoop_deadlock_prevention, "test_scoop_deadlock_prevention")
			run_test (agent system_tests.test_fixture_overhead_under_10_percent, "test_fixture_overhead_under_10_percent")
		end

	run_test_fixture_tests
		do
			create fixture_tests
			run_test (agent fixture_tests.test_on_prepare_feature_before_each_test, "test_on_prepare_feature_before_each_test")
			run_test (agent fixture_tests.test_on_clean_feature_after_each_test, "test_on_clean_feature_after_each_test")
			run_test (agent fixture_tests.test_per_feature_isolation_with_transaction, "test_per_feature_isolation_with_transaction")
			run_test (agent fixture_tests.test_fixture_factory_pattern, "test_fixture_factory_pattern")
			run_test (agent fixture_tests.test_fixture_composition, "test_fixture_composition")
			run_test (agent fixture_tests.test_no_performance_regression_without_hooks, "test_no_performance_regression_without_hooks")
		end

	run_nested_fixtures_tests
		do
			create nested_tests
			run_test (agent nested_tests.test_with_fixture_scoped_execution, "test_with_fixture_scoped_execution")
			run_test (agent nested_tests.test_with_fixture_cleanup_on_success, "test_with_fixture_cleanup_on_success")
			run_test (agent nested_tests.test_with_fixture_cleanup_on_exception, "test_with_fixture_cleanup_on_exception")
			run_test (agent nested_tests.test_with_fixture_exception_reraise, "test_with_fixture_exception_reraise")
			run_test (agent nested_tests.test_nested_with_fixture_composition, "test_nested_with_fixture_composition")
			run_test (agent nested_tests.test_with_fixture_zero_resource_leaks, "test_with_fixture_zero_resource_leaks")
			run_test (agent nested_tests.test_transaction_savepoint_pattern, "test_transaction_savepoint_pattern")
		end

	run_expanded_assertions_tests
		do
			create assertions_tests
			run_test (agent assertions_tests.test_assert_date_before, "test_assert_date_before")
			run_test (agent assertions_tests.test_assert_date_in_range, "test_assert_date_in_range")
			run_test (agent assertions_tests.test_assert_date_after, "test_assert_date_after")
			run_test (agent assertions_tests.test_assert_path_exists, "test_assert_path_exists")
			run_test (agent assertions_tests.test_assert_file_readable, "test_assert_file_readable")
			run_test (agent assertions_tests.test_assert_directory_writable, "test_assert_directory_writable")
			run_test (agent assertions_tests.test_assert_exception_thrown, "test_assert_exception_thrown")
			run_test (agent assertions_tests.test_assert_exception_message_contains, "test_assert_exception_message_contains")
			run_test (agent assertions_tests.test_assert_collection_contains_all, "test_assert_collection_contains_all")
			run_test (agent assertions_tests.test_assert_collection_has_distinct_items, "test_assert_collection_has_distinct_items")
			run_test (agent assertions_tests.test_assert_json_equal, "test_assert_json_equal")
			run_test (agent assertions_tests.test_assert_xml_contains, "test_assert_xml_contains")
		end

	run_adversarial_tests
		do
			create adversarial_tests
			run_test (agent adversarial_tests.test_double_prepare_test_system_precondition_violation, "test_double_prepare_test_system_precondition_violation")
			run_test (agent adversarial_tests.test_double_cleanup_test_system_precondition_violation, "test_double_cleanup_test_system_precondition_violation")
			run_test (agent adversarial_tests.test_cleanup_without_prepare_precondition_violation, "test_cleanup_without_prepare_precondition_violation")
			run_test (agent adversarial_tests.test_double_create_fixture_state_violation, "test_double_create_fixture_state_violation")
			run_test (agent adversarial_tests.test_double_destroy_fixture_precondition_violation, "test_double_destroy_fixture_precondition_violation")
			run_test (agent adversarial_tests.test_destroy_without_create_precondition_violation, "test_destroy_without_create_precondition_violation")
			run_test (agent adversarial_tests.test_fixture_lifecycle_1000_cycles, "test_fixture_lifecycle_1000_cycles")
			run_test (agent adversarial_tests.test_exception_during_prepare_system_state_consistency, "test_exception_during_prepare_system_state_consistency")
			run_test (agent adversarial_tests.test_exception_during_destroy_fixture_state_consistency, "test_exception_during_destroy_fixture_state_consistency")
			run_test (agent adversarial_tests.test_initialization_state_query_during_prepare, "test_initialization_state_query_during_prepare")
			run_test (agent adversarial_tests.test_multiple_fixtures_concurrent_lifecycle, "test_multiple_fixtures_concurrent_lifecycle")
			run_test (agent adversarial_tests.test_10000_prepare_cleanup_cycles, "test_10000_prepare_cleanup_cycles")
			run_test (agent adversarial_tests.test_many_concurrent_fixtures, "test_many_concurrent_fixtures")
			run_test (agent adversarial_tests.test_with_fixture_empty_callback, "test_with_fixture_empty_callback")
			run_test (agent adversarial_tests.test_lifecycle_state_queries_consistency, "test_lifecycle_state_queries_consistency")
			run_test (agent adversarial_tests.test_fixture_state_queries_consistency, "test_fixture_state_queries_consistency")
			run_test (agent adversarial_tests.test_system_initialization_state_invariant, "test_system_initialization_state_invariant")
			run_test (agent adversarial_tests.test_fixture_lifecycle_state_invariant, "test_fixture_lifecycle_state_invariant")
			run_test (agent adversarial_tests.test_prepare_system_state_transition_verified, "test_prepare_system_state_transition_verified")
			run_test (agent adversarial_tests.test_cleanup_system_state_transition_verified, "test_cleanup_system_state_transition_verified")
			run_test (agent adversarial_tests.test_create_fixture_state_transition_verified, "test_create_fixture_state_transition_verified")
			run_test (agent adversarial_tests.test_destroy_fixture_state_transition_verified, "test_destroy_fixture_state_transition_verified")
		end

	run_scoop_integration_tests
		do
			create scoop_tests
			run_test (agent scoop_tests.test_system_compatible_with_separate_reference, "test_system_compatible_with_separate_reference")
			run_test (agent scoop_tests.test_fixture_compatible_with_separate_reference, "test_fixture_compatible_with_separate_reference")
			run_test (agent scoop_tests.test_with_fixture_callback_execution, "test_with_fixture_callback_execution")
			run_test (agent scoop_tests.test_initialization_state_atomic_read, "test_initialization_state_atomic_read")
			run_test (agent scoop_tests.test_fixture_validity_atomic_read, "test_fixture_validity_atomic_read")
			run_test (agent scoop_tests.test_initialization_state_model_zero_when_uninitialized, "test_initialization_state_model_zero_when_uninitialized")
			run_test (agent scoop_tests.test_initialization_state_model_one_when_initialized, "test_initialization_state_model_one_when_initialized")
			run_test (agent scoop_tests.test_lifecycle_state_model_zero_when_invalid, "test_lifecycle_state_model_zero_when_invalid")
			run_test (agent scoop_tests.test_lifecycle_state_model_one_when_valid, "test_lifecycle_state_model_one_when_valid")
			run_test (agent scoop_tests.test_prepare_system_only_initialization_changes, "test_prepare_system_only_initialization_changes")
			run_test (agent scoop_tests.test_cleanup_system_only_initialization_changes, "test_cleanup_system_only_initialization_changes")
			run_test (agent scoop_tests.test_create_fixture_only_lifecycle_changes, "test_create_fixture_only_lifecycle_changes")
			run_test (agent scoop_tests.test_destroy_fixture_only_lifecycle_changes, "test_destroy_fixture_only_lifecycle_changes")
			run_test (agent scoop_tests.test_prepare_transition_from_zero_to_one, "test_prepare_transition_from_zero_to_one")
			run_test (agent scoop_tests.test_cleanup_transition_from_one_to_zero, "test_cleanup_transition_from_one_to_zero")
			run_test (agent scoop_tests.test_create_transition_from_zero_to_one, "test_create_transition_from_zero_to_one")
			run_test (agent scoop_tests.test_destroy_transition_from_one_to_zero, "test_destroy_transition_from_one_to_zero")
		end

feature {NONE} -- Implementation

	system_tests: TEST_TEST_SYSTEM
	fixture_tests: TEST_TEST_FIXTURE
	nested_tests: TEST_NESTED_FIXTURES
	assertions_tests: TEST_EXPANDED_ASSERTIONS
	adversarial_tests: TEST_ADVERSARIAL_STRESS
	scoop_tests: TEST_SCOOP_INTEGRATION

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
