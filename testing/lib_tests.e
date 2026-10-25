note
	description: "Tests for SIMPLE_TESTING"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: Boolean Assertions

	test_assert_true
			-- Test assert_true works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_true"
		do
			assert_true ("true is true", True)
		end

	test_assert_false
			-- Test assert_false works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_false"
		do
			assert_false ("false is false", False)
		end

	test_refute
			-- Test refute works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.refute"
		do
			refute ("not true", False)
		end

feature -- Test: Object Assertions

	test_assert_attached
			-- Test assert_attached works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_attached"
		local
			s: STRING
		do
			s := "hello"
			assert_attached ("string attached", s)
		end

	test_assert_void
			-- Test assert_void works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_void"
		local
			s: detachable STRING
		do
			s := Void
			assert_void ("string void", s)
		end

feature -- Test: Integer Assertions

	test_assert_integers_equal
			-- Test assert_integers_equal works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_integers_equal"
		do
			assert_integers_equal ("1 equals 1", 1, 1)
			assert_integers_equal ("42 equals 42", 42, 42)
		end

	test_assert_positive
			-- Test assert_positive works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_positive"
		do
			assert_positive ("1 is positive", 1)
			assert_positive ("100 is positive", 100)
		end

	test_assert_negative
			-- Test assert_negative works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_negative"
		do
			assert_negative ("-1 is negative", -1)
			assert_negative ("-100 is negative", -100)
		end

	test_assert_zero
			-- Test assert_zero works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_zero"
		do
			assert_zero ("0 is zero", 0)
		end

	test_assert_in_range
			-- Test assert_in_range works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_in_range"
		do
			assert_in_range ("5 in 1-10", 5, 1, 10)
			assert_in_range ("1 in 1-10", 1, 1, 10)
			assert_in_range ("10 in 1-10", 10, 1, 10)
		end

feature -- Test: String Assertions

	test_assert_strings_equal
			-- Test assert_strings_equal works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_strings_equal"
		do
			assert_strings_equal ("hello", "hello", "hello")
		end

	test_assert_string_contains
			-- Test assert_string_contains works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_string_contains"
		do
			assert_string_contains ("has world", "hello world", "world")
		end

	test_assert_string_empty
			-- Test assert_string_empty works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_string_empty"
		do
			assert_string_empty ("empty string", "")
		end

	test_assert_string_not_empty
			-- Test assert_string_not_empty works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_string_not_empty"
		do
			assert_string_not_empty ("non-empty", "hello")
		end

feature -- Test: Equality Assertions

	test_assert_equal
			-- Test assert_equal works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_equal"
		do
			assert_equal ("strings equal", "test", "test")
		end

	test_assert_not_equal
			-- Test assert_not_equal works correctly.
		note
			testing: "covers/{TEST_SET_BASE}.assert_not_equal"
		do
			assert_not_equal ("strings differ", "test", "other")
		end


feature -- Test: Timing without contracts

	test_without_contracts_switches_checking_off_and_back
			-- Inside `without_contracts' a broken precondition does not
			-- raise; before and after, it does.
		note
			testing: "covers/{TEST_SET_BASE}.without_contracts"
		do
			assert_true ("checked before", precondition_raises)
			without_contracts (agent note_inside)
			assert_false ("not checked inside", raised_inside)
			assert_true ("checked again after", precondition_raises)
		end

	test_without_contracts_restores_after_an_exception
			-- Work that raises inside `without_contracts' still leaves
			-- checking on afterwards.
		note
			testing: "covers/{TEST_SET_BASE}.without_contracts"
		local
			l_tried: BOOLEAN
		do
			if not l_tried then
				without_contracts (agent raise_on_purpose)
			end
			assert_true ("checked again after the exception", precondition_raises)
		rescue
			l_tried := True
			retry
		end

feature {NONE} -- Timing fixtures

	raised_inside: BOOLEAN

	note_inside
		do
			raised_inside := precondition_raises
		end

	raise_on_purpose
		do
			(create {DEVELOPER_EXCEPTION}).raise
		end

	precondition_raises: BOOLEAN
			-- Does breaking `needs_positive''s precondition raise right now?
		local
			l_tried: BOOLEAN
		do
			if not l_tried then
				needs_positive (0)
			else
				Result := True
			end
		rescue
			l_tried := True
			retry
		end

	needs_positive (a_n: INTEGER)
		require
			positive: a_n > 0
		do
		end

end
