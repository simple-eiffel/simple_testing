note
	description: "Mock TEST_SYSTEM implementation for testing"
	author: "Eiffel Expert"
	date: "$Date$"

class TEST_SYSTEM_MOCK

inherit
	TEST_SYSTEM
		redefine
			on_prepare_test_system,
			on_clean_test_system
		end

feature -- Status

	is_initialized: BOOLEAN
			-- Is the test system initialized?
		do
			Result := initialized_flag
		end

feature -- Lifecycle

	on_prepare_test_system
			-- Initialize system-level resources.
		do
			initialized_flag := True
		end

	on_clean_test_system
			-- Clean up system-level resources.
		do
			initialized_flag := False
		end

feature {NONE} -- Implementation

	initialized_flag: BOOLEAN
			-- Internal flag to track initialization state
end
