# DECISIONS: simple_testing Enhancement Architecture

**Date:** February 4, 2026

## Key Architectural Decisions

### Decision D-01: Three-Tier Fixture Hierarchy

**Decision:** Implement fixtures at three scopes (system, feature, nested) rather than single unified level

**Rationale:**
- **System-level (TEST_APP):** Resource-intensive setup (database, server) should be once-per-run
- **Feature-level (per-test):** Isolation guarantees require per-feature cleanup
- **Nested (intra-feature):** Complex tests need transaction/rollback patterns
- **Precedent:** pytest uses session/module/class/function/parametrize hierarchy
- **Eiffel fit:** Maps cleanly to EQA_TEST_SET class structure + feature functions + agents

**Alternative Considered:**
- Single fixture level (class-only, status quo): Too coarse-grained, forces manual cleanup
- Flat fixture system: No hierarchical cleanup, resource leaks likely
- Decorator pattern: Eiffel lacks decorators; notes are awkward

**Selected:** Three-tier hierarchy (D-01 = YES)

---

### Decision D-02: Feature-Level Fixtures as Hooks vs Factory Pattern

**Decision:** Implement both:
1. Hook pattern: `on_prepare_feature` / `on_clean_feature` (override-able, runs automatically)
2. Factory pattern: `create_test_fixture` (explicit, parameter-injected)

**Rationale:**
- **Hook pattern (implicit):**
  - Clean for developers: auto-execution, no boilerplate
  - Familiar from `on_prepare`/`on_clean`
  - Good for standard per-feature setup (reset database, clear collections)

- **Factory pattern (explicit):**
  - Flexible: fixture lifecycle controlled by test author
  - Composable: multiple fixtures in single test feature
  - Explicit is better than implicit (Zen of Python, applicable here)

- **Both needed:**
  - Simple tests use hooks (implicit)
  - Complex tests use factory (explicit)
  - No friction either way

**Alternative Considered:**
- Hook only: Lacks flexibility for complex tests
- Factory only: Forces boilerplate for simple tests
- Decorator pattern: Eiffel limitation

**Selected:** Both patterns (D-02 = YES)

---

### Decision D-03: Nested Fixtures via Agents vs Scope Manager Objects

**Decision:** Use agents + DBC style callbacks: `with_fixture (agent do ... end)`

**Rationale:**
- **Agent pattern (selected):**
  - Matches Eiffel idioms (agents are standard)
  - DBC check-style familiar to Eiffel developers
  - Exception-safe: callback cleanup guaranteed
  - Syntax: `with_database_transaction (agent do ... end)`
  - Scoped automatically (agent lifetime = block lifetime)

- **Scope manager alternative:**
  - Create/destroy pattern: `begin; ...; end`
  - More complex, less safe
  - Requires manual exception handling
  - Non-Eiffel idiom

**Precedent:** DBC `check` assertions are statement-level; nested fixtures extend this

**Selected:** Agents with callback pattern (D-03 = YES)

---

### Decision D-04: System-Level Fixtures in TEST_SYSTEM vs TEST_APP

**Decision:** Create new TEST_SYSTEM abstract class; TEST_APP inherits from it

**Rationale:**
- **Separation of concerns:**
  - TEST_SYSTEM: Abstract fixture infrastructure
  - TEST_APP: Concrete application setup (what you inherit)
  - Clear inheritance hierarchy

- **Extensibility:**
  - Multiple TEST_APP subclasses can inherit from same TEST_SYSTEM
  - Fixture code not mixed with test runner code

- **Discoverability:**
  - TEST_SYSTEM clearly signals "system-level fixtures"
  - TEST_APP is test runner (existing concept)

**Alternative Considered:**
- All in TEST_APP: Mixes concerns
- Global singleton functions: Not OOP, hard to extend

**Selected:** New TEST_SYSTEM class (D-04 = YES)

---

### Decision D-05: Fixture Resource Registry Pattern

**Decision:** System-level resources accessed via once-functions (singletons)

**Rationale:**
- **Once functions:**
  - Guarantee single instance per test run
  - Thread-safe (Eiffel once guarantees)
  - SCOOP-compatible via separate keyword

- **Example:**
  ```eiffel
  feature
      system_database: DATABASE
          once
              Result := database_factory.create
              Result.initialize
          end
  ```

- **Thread-safety:**
  - Make DATABASE separate for SCOOP
  - Synchronize via contracts (preconditions/postconditions)
  - Caller responsible for locking

**Alternative Considered:**
- Global variables: Not safe, not Eiffel
- Dependency injection: Too complex for system-level
- Service locator: Once-functions IS a service locator

**Selected:** Once-functions with separate keyword (D-05 = YES)

---

### Decision D-06: Fixture Composition vs Single Monolithic Fixture

**Decision:** Separate concerns into focused fixture classes

**Rationale:**
- **Composition:**
  ```eiffel
  fixture: TEST_FIXTURE
      db: DATABASE
      server: TEST_SERVER
      resources: RESOURCE_POOL
  ```
  - Each concern independent
  - Can enable/disable features
  - Easier to test fixture code itself

- **Monolithic alternative:**
  - All setup in one object
  - Tightly coupled concerns
  - Hard to reuse in different contexts

- **Eiffel fit:**
  - Object composition natural in Eiffel
  - Inheritance already used for TEST_SET_BASE

**Selected:** Fixture composition (D-06 = YES)

---

### Decision D-07: Exception Handling in Fixture Cleanup

**Decision:** Cleanup proceeds even if callback throws; exception re-raised after

**Rationale:**
- **Guarantee cleanup:**
  ```eiffel
  with_database_transaction (agent
      do
          database.begin_transaction
          callback.call  -- May throw
          database.rollback  -- ALWAYS RUNS
      end)
  ```

- **DBC-style postconditions:**
  - Ensure cleanup even on failure
  - Matches exception safety guarantees

- **Resource correctness:**
  - No resource leaks on test failure
  - No cascading failures from dirty state

**Alternative Considered:**
- Let exception prevent cleanup: Resource leaks
- Swallow exceptions: Test failure hidden

**Selected:** Exception-safe cleanup with re-raise (D-07 = YES)

---

### Decision D-08: Assertion Expansion Strategy

**Decision:** Add 20+ domain-specific assertions incrementally across Phases 5D

**Rationale:**
- **Phased approach:**
  - Phase 5D-i: Date/Time assertions (2-3 methods)
  - Phase 5D-ii: Path/File assertions (2-3 methods)
  - Phase 5D-iii: Exception assertions (2-3 methods)
  - Phase 5D-iv: Collection assertions (3-4 methods)
  - Phase 5D-v: Complex type assertions (3-4 methods)

- **Why phased:**
  - Avoid bloat, focus on high-value assertions
  - Community feedback between phases
  - Easier to maintain/document in chunks

- **Naming:**
  - Consistent: `assert_<type>_<condition>`
  - Examples:
    - `assert_date_before`, `assert_date_after`, `assert_date_in_range`
    - `assert_path_exists`, `assert_file_readable`, `assert_directory_writable`
    - `assert_exception_thrown`, `assert_exception_message_contains`
    - `assert_collection_contains_all`, `assert_collection_has_duplicates`

**Alternative Considered:**
- One big update: Risk of oversizing
- Monolithic assertion builder: Complexity, learning curve
- Python-style fluent assertions: Not natural in Eiffel

**Selected:** Phased domain-specific expansion (D-08 = YES)

---

### Decision D-09: Backward Compatibility vs Redesign

**Decision:** Preserve TEST_SET_BASE unchanged; build fixtures on top

**Rationale:**
- **Existing usage:** 59+ simple_* libraries use TEST_SET_BASE
- **Zero breaking changes:** New features are purely additive
- **Migration path:** Existing tests work; new features opt-in
- **Risk:** Redesign could break 1000s of tests across ecosystem

**Alternative Considered:**
- Major redesign: Risks compatibility
- Deprecate TEST_SET_BASE: Forces ecosystem migration

**Selected:** Additive-only (D-09 = YES)

---

### Decision D-10: SCOOP Concurrency Safety

**Decision:** System resources (database, pool) are separate; contracts enforce synchronization

**Rationale:**
- **Resource declaration:**
  ```eiffel
  system_database: separate DATABASE
      once ... end
  ```

- **Caller synchronization:**
  - Preconditions ensure proper locking
  - Postconditions guarantee state after release
  - Caller responsible for acquire/release pattern

- **Benefit:**
  - True parallelism (multiple processors)
  - No race conditions (separate guarantee)
  - Deadlock-free (contracts guide safe usage)

**Alternative Considered:**
- Shared (non-separate): Sequential, slower
- Mutex-based: Not Eiffel paradigm
- No concurrency: Single-threaded only

**Selected:** SCOOP separate with contract enforcement (D-10 = YES)

---

## Decision Impact Summary

| Decision | Impact | Risk | Timeline |
|----------|--------|------|----------|
| D-01: Three tiers | +High flexibility, +Clear model | Medium complexity | Phase 5A-5C |
| D-02: Hooks + Factory | +Both patterns available | Slight API bloat | Phase 5B |
| D-03: Agents | +Eiffel idiom, +Exception-safe | None | Phase 5C |
| D-04: TEST_SYSTEM | +Clean architecture | Low | Phase 5A |
| D-05: Once-functions | +Thread-safe, +Simple | None | Phase 5A |
| D-06: Composition | +Flexible, +Testable | Low | Phase 5A-5C |
| D-07: Exception safety | +Cleanup guaranteed | None | Phase 5C |
| D-08: Phased assertions | +Manageable scope | -Slower rollout | Phase 5D (multi-month) |
| D-09: Backward compat | +Zero breaking changes | -Old APIs coexist | Ongoing |
| D-10: SCOOP separate | +True parallelism | Medium learning curve | Phase 5A+ |

---

**Prepared:** 2026-02-04
**Next Step:** INNOVATIONS - novel approaches unique to Eiffel
