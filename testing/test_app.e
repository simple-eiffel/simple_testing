note
	description: "Test application for SIMPLE_TESTING"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_TESTING tests...%N%N")
			passed := 0
			failed := 0

			run_lib_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
		do
			create lib_tests
			-- Boolean assertions
			run_test (agent lib_tests.test_assert_true, "test_assert_true")
			run_test (agent lib_tests.test_assert_false, "test_assert_false")
			run_test (agent lib_tests.test_refute, "test_refute")
			-- Object assertions
			run_test (agent lib_tests.test_assert_attached, "test_assert_attached")
			run_test (agent lib_tests.test_assert_void, "test_assert_void")
			-- Integer assertions
			run_test (agent lib_tests.test_assert_integers_equal, "test_assert_integers_equal")
			run_test (agent lib_tests.test_assert_positive, "test_assert_positive")
			run_test (agent lib_tests.test_assert_negative, "test_assert_negative")
			run_test (agent lib_tests.test_assert_zero, "test_assert_zero")
			run_test (agent lib_tests.test_assert_in_range, "test_assert_in_range")
			-- String assertions
			run_test (agent lib_tests.test_assert_strings_equal, "test_assert_strings_equal")
			run_test (agent lib_tests.test_assert_string_contains, "test_assert_string_contains")
			run_test (agent lib_tests.test_assert_string_empty, "test_assert_string_empty")
			run_test (agent lib_tests.test_assert_string_not_empty, "test_assert_string_not_empty")
			-- Equality assertions
			run_test (agent lib_tests.test_assert_equal, "test_assert_equal")
			run_test (agent lib_tests.test_assert_not_equal, "test_assert_not_equal")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS

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
