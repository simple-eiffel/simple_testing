# Intent Review Request: simple_testing Enhancement

**Project:** simple_testing (Multi-Level Fixtures + Rich Assertions)
**Phase:** 0 (Intent Capture)
**Date:** February 4, 2026

---

## Instructions for AI Reviewer

Review the intent document below and generate **probing questions** to clarify vague language, identify missing requirements, and surface implicit assumptions.

**Output format:** Provide 10-15 probing questions. For each:
1. Quote the vague or ambiguous phrase from the intent
2. Explain why it's unclear
3. Offer 2-3 concrete alternatives the author can choose from

**Examples of good probing questions:**
- "You say 'fresh state per feature' - does this mean database transactions roll back? Shared collections cleared? Both?"
- "The 'with_fixture' pattern uses agents - can developers nest these indefinitely, or are there limits?"
- "For adoption target of '30% use feature fixtures' - how will this be measured? GitHub code analysis? Survey?"

---

## Review Criteria

Look for:
1. **Vague language:** Words like "clean", "simple", "reliable", "efficient" without concrete definitions
2. **Missing edge cases:** Empty fixtures? Fixture initialization failure? Exception during cleanup?
3. **Untestable acceptance criteria:** Can acceptance criteria be objectively verified?
4. **Hidden assumptions:** What EQA knowledge is assumed? What Eiffel language features?
5. **Scope ambiguity:** What's NOT being done? Why? Could scope creep?
6. **Feasibility concerns:** Are 12-18 month timeline, FTE estimates, go/no-go gates realistic?
7. **Risk underestimation:** Are critical risks (SCOOP deadlock, exception safety) adequately addressed?

---

## Intent Document to Review

Below is the complete intent.md. Please review and provide probing questions.

```
# Intent: simple_testing Enhancement - Multi-Level Fixtures + Rich Assertions

**Phase:** 0 (Intent Capture)
**Date:** February 4, 2026
**Status:** Ready for AI Review

## What

Enhance simple_testing from Phase 4 (documentation) to Phase 5 (expansion) by adding:

1. **Test-System-Level Fixtures** (TEST_SYSTEM class)
   - Single setup/cleanup for entire test run
   - on_prepare_test_system / on_clean_test_system hooks
   - Resource registry (database, server, pools)
   - Singleton pattern with once-functions

2. **Test-Feature-Level Fixtures** (per-test isolation)
   - on_prepare_feature / on_clean_feature hooks
   - TEST_FIXTURE factory pattern
   - Reusable fixture composition
   - Fresh state per test feature

3. **Intra-Test-Feature Fixtures** (nested context)
   - with_fixture (agent callback) pattern
   - Exception-safe cleanup (guaranteed by postconditions)
   - Scoped resource management
   - Transaction/rollback examples

4. **Expanded Assertions** (20+ domain-specific)
   - Date/Time assertions
   - Path/File assertions
   - Exception assertions
   - Collection assertions
   - Complex type assertions

## Why

**Current Gap:** Eiffel developers identified that:
- Class-level fixtures (on_prepare/on_clean) are too coarse-grained
- Feature-level isolation requires manual setup/teardown boilerplate (70% reduction target)
- System-level resource management (databases, servers) requires manual lifecycle handling
- EQA_TEST_SET assertions are "minimalistic" (justification for TEST_SET_BASE creation)

**Business Case:**
- Reduces test code verbosity by 70% (feature-level fixtures)
- Improves test reliability (automatic isolation between features)
- Enables resource-heavy testing (system-level setup/cleanup)
- Leverages Eiffel's unique DBC + SCOOP capabilities (competitive advantage)

**Market Context:**
- xUnit (JUnit, NUnit) use three-tier fixture hierarchy (session, class, method)
- pytest uses five-tier scopes (session, module, class, function, parametrize)
- Eiffel currently has one tier (class-level) - gap exists

## Users

**Primary:** Eiffel developers using simple_testing + EQA_TEST_SET
- Writing unit tests for simple_* libraries
- Building test suites for production applications
- Maintaining complex test scenarios with resource setup

**Secondary:** Simple Eiffel ecosystem maintainers (59+ libraries)
- Need clean test isolation between features
- Need resource management at system level
- Need rich assertions for complex validations

**Experience Level:** Intermediate to advanced Eiffel developers
- Understand EQA_TEST_SET basics
- Familiar with TEST_SET_BASE (rich assertions)
- Know DBC contracts
- May be learning SCOOP concurrency

## Acceptance Criteria

### Phase 5A: System-Level Fixtures (3 months)
- [ ] TEST_SYSTEM class implemented with on_prepare_test_system/on_clean_test_system
- [ ] Singleton resource registry accessible to all test classes
- [ ] SCOOP deadlock testing: 100+ concurrent scenarios pass
- [ ] Performance benchmark: fixture overhead < 10% of test time
- [ ] Backward compatibility: all existing TEST_SET_BASE tests pass
- [ ] Documentation: user guide + 10 examples
- [ ] Integration gate: SCOOP consumer ECF compiles without VUAR(2)

### Phase 5B: Feature-Level Fixtures (2-3 months)
- [ ] on_prepare_feature / on_clean_feature hooks implemented
- [ ] TEST_FIXTURE factory pattern working
- [ ] Per-feature isolation verified: each test gets fresh state
- [ ] Developer feedback: 70%+ understand the pattern
- [ ] Adoption target: 30%+ of new tests use feature fixtures
- [ ] Documentation: decision tree + 20 examples
- [ ] No performance regression when hooks not used

### Phase 5C: Nested/Intra-Test Fixtures (2-3 months)
- [ ] with_fixture (agent callback) pattern working
- [ ] Exception-safe cleanup: 1000+ exception scenarios tested
- [ ] Nested composition: multiple with_fixture blocks nest correctly
- [ ] Resource cleanup order verified (LIFO)
- [ ] Documentation: transaction examples, error handling guide
- [ ] Zero resource leaks under stress testing

### Phase 5D: Expanded Assertions (6 months, parallel)
- [ ] 20+ domain-specific assertions implemented
- [ ] Each assertion has 5+ tests
- [ ] Naming collision check: zero conflicts
- [ ] Documentation: 2+ examples per assertion
- [ ] Phased rollout: feedback between assertion groups

### Phase 6: Production Hardening (4-6 weeks)
- [ ] Backward compatibility gate: 100% of existing tests pass
- [ ] SCOOP consumer integration gate: no VUAR(2) errors
- [ ] Code coverage: 95%+ of fixture code
- [ ] Adversarial testing: 1000+ test scenarios
- [ ] Documentation complete: user guide, API reference, FAQ

## Out of Scope

**Explicitly NOT included:**
- Mocking/stubbing framework (separate library: simple_mock)
- Code coverage analysis
- Test discovery/execution (EQA handles)
- Performance testing helpers (separate library)
- Parametrized test runners (EQA across loops sufficient)
- Continuous integration integration (CI tools handle)
- Test reporting (HTML, XML, JSON - separate library)
- Parallel test execution runner (EQA handles)

**Why out of scope:**
- Focus on fixture architecture first (highest ROI)
- Other features can be separate libraries (simple_mock, simple_report)
- EQA already handles discovery, execution, reporting

## Timeline Summary

```
Phase:   5A (System)  5B (Feature)  5C (Nested)  5D (Assertions)  6 (Hardening)
Duration:  3 months   2-3 months    2-3 months   6 months (||)     4-6 weeks
FTE:         1          1-2           1-2          0.5 (||)          1

Total Timeline: 12-18 months (accelerable to 10-12 with 2 FTE)
```

**Phases 5B, 5C can overlap 5D (parallel work)**

## Architecture Overview

### Three-Tier Fixture Model

```
TIER 1: System (once per test run)
  ┌─────────────────────────────────────┐
  │ TEST_SYSTEM.on_prepare_test_system  │  (database init, server start)
  │ TEST_SYSTEM.on_clean_test_system    │  (database close, server stop)
  └─────────────────────────────────────┘
            ↓
TIER 2: Class (per test class)
  ┌─────────────────────────────────────┐
  │ EQA_TEST_SET.on_prepare             │  (inherited from EQA)
  │ EQA_TEST_SET.on_clean               │  (inherited from EQA)
  └─────────────────────────────────────┘
            ↓
TIER 3: Feature (per test method)
  ┌─────────────────────────────────────┐
  │ TEST_SET_BASE.on_prepare_feature    │  (reset test data)
  │ TEST_SET_BASE.on_clean_feature      │  (cleanup test data)
  └─────────────────────────────────────┘
            ↓
TIER 4: Nested (scoped blocks)
  ┌─────────────────────────────────────┐
  │ with_fixture (agent do ... end)     │  (transaction begin/rollback)
  └─────────────────────────────────────┘
```

**Key Principle:** Inheritance + agents (Eiffel idioms), not decorators (Python idiom)

## MML Decision

**Does simple_testing need MML model queries?**

**Answer: YES - Optional (Phase 5B+)**

**Rationale:**

**Phase 4-5A (Current + System Fixtures):**
- No internal collections in TEST_SET_BASE or TEST_SYSTEM
- Assertions work on caller's data, not internal state
- MML NOT required

**Phase 5B+ (Feature-Level + Nested Fixtures):**
- TEST_FIXTURE composition may include collections (resource pool, test data)
- Frame conditions would help document what fixture lifecycle doesn't change
- MML OPTIONAL - can be added if developers request detailed fixture contracts

**Decision:** YES - Optional

**Implementation Strategy:**
- Phase 5A: No MML integration
- Phase 5B: If TEST_FIXTURE has internal collections, add model queries
- Phase 5C: MML used to document fixture scoping (what doesn't change in nested context)
- Developers can extend with MML if their fixtures need frame conditions

## Questions for Intent Review

1. **Vague Language Check:** Are terms like "feature-level", "system-level", "isolation" clearly defined?
2. **Edge Cases:** What happens if system fixture fails to initialize? Do tests still run? Get skipped?
3. **Concurrency:** How do SCOOP-separate resources interact with feature-level fixture isolation?
4. **MML Clarity:** "Optional" MML decision - is the trigger clear (when to add it)?
5. **Backward Compatibility:** Does "zero breaking changes" mean TEST_SET_BASE API frozen?
6. **Test Isolation:** Is "fresh state per feature" guaranteed? What about shared database?
7. **Exception Handling:** When callback throws in with_fixture, what exactly is guaranteed to happen?
8. **Documentation Scope:** "50+ examples" - what topics? What level of detail?
9. **Performance Metrics:** "< 10% overhead" - measured how? What test size?
10. **Adoption Tracking:** How will "30%+ use feature fixtures" be measured?
```

---

## What We're Looking For

Please identify:

1. **Vague or ambiguous phrases** that need clarification
2. **Missing edge case handling** (initialization failure, cleanup during exception, etc.)
3. **Untestable acceptance criteria** (how would "70%+ understand" be verified?)
4. **Implicit assumptions** (what EQA knowledge? What Eiffel features?)
5. **Scope creep risks** (could "documentation" expand beyond 50+ examples?)
6. **Feasibility concerns** (are the timelines and FTE estimates realistic?)
7. **Hidden dependencies** (what does "SCOOP deadlock testing" require?)

---

## Format Your Response

Please provide:
- 10-15 numbered probing questions
- For each: quote from intent, why it's vague, 2-3 concrete alternatives
- Summary: top 3 concerns
- Confidence level in the intent (0-100%)

---

**Thank you for the careful review!**
