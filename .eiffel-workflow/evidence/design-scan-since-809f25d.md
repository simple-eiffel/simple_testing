# Design scan (diff mode), simple_testing since 809f25d (main 7df5f24)

Read-only. Nothing compiled or run. Subject: src/test_set_base.e, `without_contracts` (698-719).

Counts: HIGH 0, MEDIUM 2, LOW 3.

## What it does

`l_was := {ISE_RUNTIME}.check_assert (False)`, `a_work.call (Void)`, `l_off := check_assert (l_was)`; the rescue restores `l_was`, and a procedure's rescue with no `retry` re-raises, so the exception continues.

## SCOOP: per processor or global?

In the 25.02 runtime headers the assertion flag is `in_assertion`, defined as `(eif_globals->in_assertion_cx)` (include/eif_globals.h:88, 223): a field of the per-thread globals, and a SCOOP processor is its own thread, so a flag of that kind is per processor. `ISE_RUNTIME.check_assert` is `built_in static` (ELKS ise_runtime.e:35), so I could not read which flag it flips: the match is inferred, not verified.
If it is per thread, the call turns contracts off only on the calling processor. A timed step that makes separate calls runs their work on other processors with contracts ON (pre/postconditions, wait conditions), and the measurement pays for them.
MEDIUM until a test settles it: a separate call to a feature with a false precondition inside `without_contracts`. State the answer in the feature comment.

## Nested calls

Correct. The inner call saves `l_was = False` (already off) and restores False; the outer then restores True. Last in, first out; no counter needed.

## Exceptions

The rescue restores the saved state and re-raises. Points:
- LOW, 714-717: `l_was` defaults to False. If anything raised before the first assignment, the rescue would call `check_assert (False)` and leave contracts OFF for the rest of the run, the silent failure this routine exists to prevent. It cannot happen today (only `check_assert` precedes it), but `l_was := True` first costs nothing.
- The runtime already restores the flag in any routine with a rescue (eif_macros.h:1008 RTED saves it, 1062 RTER restores it), so the rescue is belt and braces. Correct either way.
- While contracts are off, a precondition violation in the timed code is not an exception: the callee runs with a false precondition (crash or wrong answer instead of a named contract). That is the intent for timing; say so in the comment.

## Other behavior

- MEDIUM: there is no way to ask whether contracts are on. SW_VIRTUAL_GRID_ASSAULT had its own `contracts_checked` (a probing rescue) and deleted it, so a test cannot assert or report that a step really ran contract-free. A `contracts_checked: BOOLEAN` query beside `without_contracts` would give every client one honest answer (and a postcondition-free way to test the routine).
- Only contracts compiled in can be switched off. In a build without assertions the call is a no-op; fine.
- `check` instructions are assertions too: not checked inside the block (consistent with the finalized-check note).
- LOW: `a_work` is typed `PROCEDURE`; an agent with open arguments breaks `call`'s operand precondition, evaluated while checking is already off. Keep arguments closed, or type it with an explicit empty TUPLE.

## Placement: TEST_SET_BASE or a separate class?

Separate. TEST_SET_BASE is the assertion, collection and diff class every test set inherits (700+ lines). Timing and runtime-flag control is another role, it adds an ISE_RUNTIME dependency to every test, and it is the case the multiple-inheritance policy asks for: a small effective mixin `TEST_TIMING` (`without_contracts`, `contracts_checked`, plus the `timed` / `time_it` / `last_ms` / `median` helpers that simple_widgets' SW_VIRTUAL_GRID_ASSAULT, lines 176-195, now carries privately) inherited side by side by the tests that time. Migration cost: `without_contracts` shipped in 1.1.0 and simple_widgets uses it, so keep TEST_SET_BASE inheriting TEST_TIMING (the name keeps working) and drop nothing. Nothing moves without Larry's word.

## Tests

- LOW: nothing in simple_testing exercises `without_contracts`. Three small tests (nested, exception path restores, the separate-call question above) would settle the SCOOP point and the restore rule.
