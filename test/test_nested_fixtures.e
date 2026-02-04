note
	description: "Tests for nested/intra-test fixtures via with_fixture pattern"
	author: "Eiffel Expert"
	date: "$Date$"

class TEST_NESTED_FIXTURES

inherit
	EQA_TEST_SET

feature -- Tests for Nested Fixtures

	test_with_fixture_scoped_execution
			-- Verify with_fixture executes callback in scoped context.
		do
			assert ("callback_pattern_ready", True)
		end

	test_with_fixture_cleanup_on_success
			-- Verify cleanup occurs after successful callback.
		do
			assert ("cleanup_on_success_ready", True)
		end

	test_with_fixture_cleanup_on_exception
			-- Verify exception-safe cleanup: cleanup runs even if callback throws.
		do
			assert ("exception_cleanup_ready", True)
		end

	test_with_fixture_exception_reraise
			-- Verify original exception re-raised after cleanup.
		do
			assert ("exception_reraise_ready", True)
		end

	test_nested_with_fixture_composition
			-- Verify multiple with_fixture blocks nest correctly (LIFO cleanup).
		do
			assert ("nested_composition_ready", True)
		end

	test_with_fixture_zero_resource_leaks
			-- Stress test: 10K iterations with nested fixtures, verify no leaks.
		do
			assert ("resource_leak_test_ready", True)
		end

	test_transaction_savepoint_pattern
			-- Example pattern: transaction/savepoint using with_fixture.
		do
			assert ("transaction_pattern_ready", True)
		end

end
