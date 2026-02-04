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
			print ("Phase 1: Contract skeletons created successfully%N")
			print ("Phase 1: All tests in skeletal form, ready for implementation%N%N")
		end

end
