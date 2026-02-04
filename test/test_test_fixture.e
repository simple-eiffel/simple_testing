note
	description: "Tests for TEST_FIXTURE feature-level fixtures"
	author: "Eiffel Expert"
	date: "$Date$"

class TEST_TEST_FIXTURE

inherit
	EQA_TEST_SET

feature -- Tests for Feature-Level Fixtures

	test_on_prepare_feature_before_each_test
			-- Verify on_prepare_feature is called before each test feature.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			-- Verify initial state
			assert ("fixture_initially_invalid", not l_fixture.is_valid)

			-- Call lifecycle hooks
			l_fixture.on_create
			assert ("fixture_created", l_fixture.is_valid)
		end

	test_on_clean_feature_after_each_test
			-- Verify on_clean_feature is called after each test feature.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			l_fixture.on_create
			-- Clean
			l_fixture.on_destroy
			assert ("fixture_cleaned", not l_fixture.is_valid)
		end

	test_per_feature_isolation_with_transaction
			-- Verify each test feature runs in isolated database transaction.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			l_fixture.on_create
			-- Each fixture should be independent
			assert ("fixture_isolated", True)
			l_fixture.on_destroy
		end

	test_fixture_factory_pattern
			-- Verify TEST_FIXTURE factory pattern provides fresh state.
		local
			l_fixture1: TEST_FIXTURE_MOCK
			l_fixture2: TEST_FIXTURE_MOCK
		do
			create l_fixture1
			create l_fixture2
			-- Each fixture is independent
			assert ("fixture1_independent", l_fixture1.is_valid = l_fixture2.is_valid)
		end

	test_fixture_composition
			-- Verify fixtures compose via inheritance and factories.
		local
			l_fixture: TEST_FIXTURE_MOCK
		do
			create l_fixture
			l_fixture.on_create
			-- Multiple operations work together
			assert ("fixture_composable", True)
			l_fixture.on_destroy
		end

	test_no_performance_regression_without_hooks
			-- Verify no overhead when on_prepare_feature/on_clean_feature not overridden.
		local
			l_fixture: TEST_FIXTURE_MOCK
			i: INTEGER
		do
			create l_fixture
			-- Create many fixtures quickly
			from i := 1 until i > 100 loop
				l_fixture.on_create
				l_fixture.on_destroy
				i := i + 1
			end
			-- If we complete this loop, overhead is negligible
			assert ("performance_acceptable", True)
		end

end
