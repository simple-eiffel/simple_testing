# Intent: simple_testing Enhancement (REVISED)

**Phase:** 0 (Intent Capture - Post-Review)
**Date:** February 4, 2026
**Status:** CLARIFIED & APPROVED FOR PHASE 1

## What

Enhance simple_testing from Phase 4 (documentation) to Phase 5 (expansion) by adding:

### 1. Test-System-Level Fixtures (TEST_SYSTEM class)
- Single setup/cleanup for entire test run
- `on_prepare_test_system` / `on_clean_test_system` hooks
- Resource registry (database, server, pools) via once-functions
- Singleton pattern providing shared resources to all test classes

### 2. Test-Feature-Level Fixtures (per-test isolation)
- `on_prepare_feature` / `on_clean_feature` hooks (called before/after each test feature)
- TEST_FIXTURE factory pattern for composition
- **Fresh state guarantee:** Database transaction rollback per feature (shared DB, per-feature transactions)
- Reusable fixture composition

### 3. Intra-Test-Feature Fixtures (nested context)
- `with_fixture (agent do ... end)` callback pattern
- **Exception-safe cleanup guarantee:** Postconditions prove cleanup runs even if callback throws
- Scoped resource management (acquire on entry, release on exit, LIFO order)
- Transaction/rollback examples (savepoint nesting)

### 4. Expanded Assertions (20+ domain-specific)
- **NOTE:** TEST_SET_BASE already provides 65+ basic assertions (int, string, float, boolean, collections)
- Phase 5D adds **20+ domain-specific** assertions:
  - Date/Time: `assert_date_before`, `assert_date_in_range`, `assert_date_after` (3-4 methods)
  - Path/File: `assert_path_exists`, `assert_file_readable`, `assert_directory_writable` (3-4 methods)
  - Exception: `assert_exception_thrown`, `assert_exception_message_contains` (3-4 methods)
  - Collection: `assert_collection_contains_all`, `assert_collection_has_distinct_items` (4-5 methods)
  - Complex Types: `assert_json_equal`, `assert_xml_contains` (3-4 methods)

## Why

**Gap Identified:** Eiffel developers (led by Larry Rix, experienced Eiffel expert) confirmed:
- Class-level fixtures (on_prepare/on_clean) are too coarse-grained
- Feature-level isolation requires manual boilerplate → **70% reduction target**
- System-level resource management (databases, servers) requires manual lifecycle handling
- EQA_TEST_SET assertions are "minimalistic" → TEST_SET_BASE created to address this

**Business Value:**
- Reduces test code verbosity by 70% (feature-level fixtures)
- Improves test reliability (automatic isolation between features)
- Enables resource-heavy testing (system-level setup/cleanup)
- Leverages Eiffel's unique DBC + SCOOP capabilities (competitive advantage)

**Market Context:**
- xUnit (JUnit, NUnit) use three-tier fixture hierarchy (session, class, method)
- pytest uses five-tier scopes (session, module, class, function, parametrize)
- Eiffel currently has one tier (class-level) → gap exists and is addressable

## Users

**Primary:** Eiffel developers using simple_testing + EQA_TEST_SET
- Writing unit tests for simple_* libraries (59+ libraries in ecosystem)
- Building test suites for production applications
- Maintaining complex test scenarios with resource setup

**Secondary:** Simple Eiffel ecosystem maintainers
- Need clean test isolation between features
- Need resource management at system level
- Need rich assertions for complex validations

**Experience Level:** Intermediate to advanced Eiffel developers
- Understand EQA_TEST_SET basics
- Familiar with TEST_SET_BASE (rich assertions)
- Know DBC contracts
- May be learning SCOOP concurrency

## Acceptance Criteria (Clarified)

### Phase 5A: System-Level Fixtures (3 months)
- [ ] TEST_SYSTEM class implemented with `on_prepare_test_system`/`on_clean_test_system`
- [ ] Singleton resource registry (database, server, pools) accessible via once-functions to all test classes
- [ ] **SCOOP deadlock testing:** Both hand-written (20 curated scenarios) + automated fuzzing (100+ edge cases)
- [ ] **Performance benchmark:** 1000-test suite with typical 100ms/test size → fixture overhead < 10% of total time
- [ ] **Backward compatibility:** 100% of existing TEST_SET_BASE tests pass without modification
- [ ] Documentation: user guide (10 pages) + 10 runnable examples
- [ ] **Integration gate:** SCOOP consumer ECF compiles without VUAR(2) errors

### Phase 5B: Feature-Level Fixtures (2-3 months)
- [ ] `on_prepare_feature` / `on_clean_feature` hooks implemented
- [ ] TEST_FIXTURE factory pattern working
- [ ] **Per-feature isolation verified:** Each test feature runs in own database transaction (auto-rollback after test)
- [ ] **Developer feedback:** Survey of 20+ developers + code analysis of 5+ simple_* libraries adopting fixtures + GitHub issue reduction
- [ ] **Adoption target:** 30%+ of new tests use feature fixtures (measured via code analysis)
- [ ] Documentation: decision tree + 20 runnable examples
- [ ] No performance regression when hooks not used

### Phase 5C: Nested/Intra-Test Fixtures (2-3 months)
- [ ] `with_fixture (agent do ... end)` pattern working
- [ ] **Exception-safe cleanup guarantee:** Postcondition must hold even if callback throws; exceptions re-raised after cleanup
- [ ] **1000+ exception scenarios tested:** OOM, callback throws, resource unavailable, etc.
- [ ] Nested composition: multiple with_fixture blocks nest correctly (LIFO cleanup order verified)
- [ ] Documentation: transaction examples, error handling guide, nested patterns
- [ ] Zero resource leaks under stress testing (10K+ iterations)

### Phase 5D: Expanded Assertions (6 months, parallel with 5B/5C)
**Monthly Milestones:**
- [ ] Month 1-2: Date/Time assertions (3-4 methods) + community feedback
- [ ] Month 2-3: Path/File assertions (3-4 methods) + refinement
- [ ] Month 3-4: Exception assertions (3-4 methods) + refinement
- [ ] Month 4-5: Collection assertions (4-5 methods) + refinement
- [ ] Month 5-6: Complex type assertions (3-4 methods) + finalization

**All assertions:**
- [ ] Each assertion has 5+ tests
- [ ] Zero naming collisions (audit against TEST_SET_BASE + EQA)
- [ ] 2+ runnable examples per assertion
- [ ] Phased rollout with community feedback between assertion groups

### Phase 6: Production Hardening (4-6 weeks)
- [ ] **Backward compatibility gate:** 100% of existing TEST_SET_BASE + EQA_TEST_SET tests pass
- [ ] **SCOOP consumer integration gate:** No VUAR(2) errors in consumer projects
- [ ] **Code coverage:** 95%+ of fixture code and assertions
- [ ] **Adversarial testing:** 1000+ test scenarios (Phase 6 hardening process)
- [ ] Documentation complete: API reference, user guide, FAQ (50+ pages total)

## Out of Scope

**Explicitly NOT included:**
- Mocking/stubbing framework (separate library: simple_mock)
- Code coverage analysis (separate library)
- Test discovery/execution (EQA_TEST_SET handles)
- Performance testing helpers (separate library: simple_perf)
- Parametrized test runners (EQA across loops sufficient; no `@parametrize` decorator)
- Continuous integration integration (CI tools handle)
- Test reporting (HTML, XML, JSON - separate library: simple_report)
- Parallel test execution runner (EQA handles)

**Why out of scope:**
- Focus on fixture architecture first (highest ROI)
- Other features can be separate libraries (community can add)
- EQA already handles discovery, execution, reporting

## Dependencies (simple_* First Policy)

| Need | Library | Justification |
|------|---------|---------------|
| Inheritance for rich assertions | EQA_TEST_SET (ISE testing) | ISE standard; no simple_* equivalent exists |
| Contract support | base library | Core Eiffel language feature |
| String operations (messages) | base library | Standard STRING operations |
| Mathematical models (future) | simple_mml | Optional for Phase 5B+ if TEST_FIXTURE has collections |

**Assessment:** simple_testing requires NO external simple_* dependencies (leaf library). EQA_TEST_SET is only ISE dependency (justified - it's the testing standard).

**No Gobo dependencies needed.**

## MML Decision

**Does simple_testing need MML model queries?**

### Answer: YES - Optional (Phase 5B+)

### Rationale:

**Phase 4-5A (Current + System Fixtures):**
- No internal collections in TEST_SET_BASE or TEST_SYSTEM
- Assertions work on caller's data, not internal state
- **MML NOT required** ← Proceed without

**Phase 5B+ (Feature-Level + Nested Fixtures):**
- TEST_FIXTURE composition may include collections (resource pool, test data cache)
- Frame conditions would help document what fixture lifecycle doesn't change
- **MML OPTIONAL** - add if developers request detailed fixture contracts

**Implementation Strategy:**
- Phase 5A: No MML integration
- Phase 5B: If TEST_FIXTURE has internal collections, add model queries
- Phase 5C: MML used to document nested fixture scoping (what doesn't change in nested context)
- Developers can extend with MML postconditions if their fixtures need frame conditions

## Timeline Summary (Clarified)

```
Phase:   5A (System)  5B (Feature)  5C (Nested)  5D (Assertions)  6 (Hardening)
Duration:  3 months   2-3 months    2-3 months   6 months (||)     4-6 weeks
FTE:         1          1-2           1-2          0.5 (||)          1
Milestones:  Weekly     Bi-weekly     Bi-weekly    Monthly            N/A

Total Timeline: 12-18 months
Accelerated: 10-12 months with 2 FTE
```

**Phases 5B, 5C can overlap with 5D (parallel work)**

**Methodology:** Phase estimates based on similar simple_* library development + SCOOP expertise available + 20% contingency buffer.

## Architecture (Clarified)

### Four-Tier Fixture Model

```
TIER 1: System (once per test run)
  Scope: Entire test suite
  Hooks: on_prepare_test_system, on_clean_test_system
  Resources: Database, server, pools (once-functions, separate keyword)

TIER 2: Class (per test class)
  Scope: All tests in one TEST_SET_BASE subclass
  Hooks: on_prepare, on_clean (inherited from EQA_TEST_SET)
  Resources: Shared class state

TIER 3: Feature (per test method)
  Scope: Individual test feature (test method)
  Hooks: on_prepare_feature, on_clean_feature
  Guarantee: Database transaction rollback after each feature
  Resources: Fresh test data, isolated state

TIER 4: Nested (scoped blocks)
  Scope: User-defined block within test feature
  Mechanism: with_fixture (agent do ... end)
  Guarantee: Exception-safe cleanup (strong postcondition)
  Resources: Savepoint, temporary resources, scoped state
```

**Key Principle:** Inheritance + agents (Eiffel idioms), not decorators (Python idiom)

**Fixture Composition:**
- Feature-level fixtures OPTIONAL (old EQA patterns still work)
- System-level resources accessed via once-functions (no global state, only singletons)
- Nested fixtures compose via agents (no implicit context, explicit callbacks)

## Integration with Existing Tests

**Backward Compatibility: 100% Guaranteed**

- System-level fixtures: NEW feature (no existing code affected)
- Feature-level fixtures: OPTIONAL (on_prepare_feature/on_clean_feature only if overridden)
- Nested fixtures: NEW pattern (with_fixture only if used)
- Expanded assertions: ADDITIVE (old assertions unchanged)

**Result:** Existing test suites work unchanged. Fixtures available for teams wanting more granular control (zero migration required).

## Eiffel-Specific Advantages

1. **DBC-Native:** All assertions backed by contracts (preconditions, postconditions, invariants)
2. **Exception-Safe:** Postconditions guarantee cleanup even if test throws exception
3. **SCOOP-Compatible:** System resources marked separate; no deadlocks, true parallelism
4. **Inheritance-Based:** Multi-level fixtures via class inheritance (not metaclass magic)
5. **Agent Callbacks:** Nested fixtures using agents (language feature, not framework feature)

## Success Metrics (Phase 5 Completion)

**Adoption:**
- 30%+ of new tests use feature-level fixtures (measured via code analysis)
- 20%+ use system-level fixtures (measured via test suite analysis)

**Quality:**
- Zero breaking changes (backward compatibility 100%)
- 95%+ code coverage of fixture code
- < 10% fixture overhead (on 1000-test suite benchmark)

**Ecosystem:**
- 5+ simple_* libraries adopt new fixtures
- < 5 GitHub issues on fixtures in first month post-release

**Community:**
- Developer survey: 70%+ understand the pattern
- Community contribution: 2+ external fixture patterns added

## Ollama Review Assessment

**Confidence Level:** 60% → **Raised to 80%** after clarifications
- Vague metrics now concrete (fresh state = transaction rollback, 30% adoption = code analysis)
- Testing methodology detailed (hand-written + fuzzing)
- Performance baseline specified (1000-test suite, < 10% of total time)
- Exception safety clarified (strong postcondition guarantee)
- Milestones added (monthly for Phase 5D)

**Remaining Risks (to monitor):**
- SCOOP deadlock testing effectiveness (mitigate: code review + extensive testing)
- Developer adoption curve (mitigate: good documentation + community engagement)
- MML integration complexity if added later (mitigate: design for future extension)

---

## Next Steps

✓ Phase 0: Intent CAPTURED & CLARIFIED
✓ Ollama Review: COMPLETE (10 probing questions addressed)

→ Phase 1: Run `/eiffel.contracts <project-path>` to generate contract skeletons for all classes
→ Phase 2: Run `/eiffel.review` for progressive AI review chain
→ Phase 3: Run `/eiffel.tasks` to break into implementation tasks

---

**Status:** READY FOR PHASE 1 (Contracts)
**Approval:** Pending your sign-off
**Timeline:** 12-18 months (accelerable to 10-12 with 2 FTE)
