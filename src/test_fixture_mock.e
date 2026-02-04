note
	description: "Mock TEST_FIXTURE implementation for testing"
	author: "Eiffel Expert"
	date: "$Date$"

class TEST_FIXTURE_MOCK

inherit
	TEST_FIXTURE
		redefine
			on_create,
			on_destroy,
			is_valid
		end

feature -- Lifecycle

	on_create
			-- Initialize fixture state.
		do
			valid_flag := True
		end

	on_destroy
			-- Clean up fixture state.
		do
			valid_flag := False
		end

feature -- Query

	is_valid: BOOLEAN
			-- Is fixture in valid state?
		do
			Result := valid_flag
		end

feature {NONE} -- Implementation

	valid_flag: BOOLEAN
			-- Internal validity flag

end
