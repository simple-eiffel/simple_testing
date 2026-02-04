note
	description: "Holder for with_fixture testing support"
	author: "Eiffel Expert"
	date: "$Date$"

class FIXTURE_HOLDER

inherit
	TEST_SET_BASE_EXTENDED
		redefine
			with_fixture
		end

feature -- Usage

	with_fixture (callback: PROCEDURE)
			-- Execute callback in fixture context
		do
			Precursor (callback)
		end

end
