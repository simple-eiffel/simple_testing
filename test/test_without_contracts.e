note
	description: "[
		Tests for TEST_SET_BASE.without_contracts (1.1.0): contract checking
		is off for the wrapped work only, and back on afterwards - even when
		the work raises.
	]"
	author: "Larry Rix"

class
	TEST_WITHOUT_CONTRACTS

inherit
	TEST_SET_BASE

feature -- Tests

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

feature {NONE} -- Fixtures

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
