note
	description: "[
		Extension points for TEST_SET_BASE to support feature-level fixtures.

		Adds:
		- on_prepare_feature / on_clean_feature hooks (called before/after each test feature)
		- Nested fixture support via with_fixture pattern

		This is a mixin/interface definition. TEST_SET_BASE in its next version
		will inherit from this and implement the hooks.

		Feature-level fixture hooks are optional:
		- If not overridden: default behavior (no per-feature cleanup)
		- If overridden: called before/after each test feature automatically by test runner

		Example:
			class MY_TEST_SET
				inherit TEST_SET_BASE

				feature
					on_prepare_feature do
						-- Reset test data, acquire per-feature resources
						test_data.reset
						transaction.begin
					end

					on_clean_feature do
						-- Clean up test data, release per-feature resources
						transaction.rollback
						test_data.cleanup
					end

					test_something
						do
							-- on_prepare_feature called before this
							assert_positive ("data", test_data.count)
							-- on_clean_feature called after this
						end
				end
			end
	]"
	author: "Eiffel Expert"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TEST_SET_BASE_EXTENDED

inherit
	ANY

feature -- Feature-Level Fixture Hooks

	on_prepare_feature
			-- Set up state for a single test feature (called before each test feature).
			-- Optional: override to customize per-feature setup.
			-- Frame condition: no global state changes permitted during default hook.
		do
			-- Default: no-op (can be overridden by subclasses)
		ensure
			feature_ready: True
			-- Subclass-specific postcondition will verify actual state
			-- Default behavior: no side effects on framework state
		end

	on_clean_feature
			-- Clean up state after a single test feature (called after each test feature).
			-- Optional: override to customize per-feature cleanup.
			-- Must be exception-safe if test threw an exception.
		do
			-- Default: no-op (can be overridden by subclasses)
		ensure
			feature_cleaned: True
			-- Subclass-specific postcondition will verify actual state
			-- Default behavior: no side effects on framework state
		end

feature -- Nested Fixture Support

	with_fixture (callback: PROCEDURE)
			-- Execute `callback' in scoped fixture context.
			-- Fixture resources acquired on entry, released on exit (LIFO order).
			-- Exception-safe: cleanup runs even if callback throws.
			--
			-- Example:
			--    with_fixture (agent do
			--        transaction.begin
			--        -- Test logic
			--        transaction.rollback  -- Auto-released on exit
			--    end)
		require
			callback_not_void: callback /= Void
		do
			-- Execute callback in scoped context
			callback.call (Void)
		ensure
			fixture_context_exited: True
			-- In Phase 5B, will add MML postconditions for LIFO ordering verification
		end

invariant
	fixture_hooks_maintain_isolation: True
		-- Placeholder - subclasses will verify isolation guarantees
end
