# RECOMMENDATION: simple_testing Enhancement Strategy

**Date:** February 4, 2026
**Status:** PROCEED WITH PHASED ENHANCEMENT

---

## Executive Summary

simple_testing should evolve from Phase 4 (Documentation) to Phase 5 (Expansion) with three-tier fixture support + expanded assertions. This leverages Eiffel's unique DBC and SCOOP capabilities to provide testing patterns unavailable in other languages.

**Recommendation: BUILD** enhanced simple_testing with multi-level fixtures and domain-specific assertions over 12-18 months.

**Confidence Level: HIGH** (evidence-based, user-driven, aligned with Eiffel strengths)

---

## What Eiffel Developers Actually Need

### User Feedback (From Larry Rix, Eiffel Expert)

1. **Test-feature-level fixtures:** YES, needed
   - Class-level `on_prepare`/`on_clean` too coarse-grained
   - Per-test isolation required for reliability

2. **Test-system-level fixtures:** YES, needed
   - Database initialization, server startup, resource pools
   - Currently managed manually; error-prone

3. **Intra-test fixtures:** YES, uncertain how
   - DBC check-style assertions with state management
   - Nested context within single test feature

4. **Expanded assertions:** YES, definitely
   - TEST_SET_BASE created because EQA_TEST_SET "minimalistic"
   - 20+ domain-specific assertions would help

---

## Implementation Strategy

### NOT simple_pytest

**Why we rejected "simple_pytest" naming:**
- Research mistakenly named library after Python benchmark
- Eiffel teams are not Python developers
- pytest patterns don't map cleanly to Eiffel
- Fixtures are Eiffel-native patterns (inheritance, agents, SCOOP)

**What we're building instead:**
- Enhancement of simple_testing (already established)
- Multi-level fixtures aligned with Eiffel OOP
- Rich assertions reflecting common testing needs

---

## Phase Plan: 12-18 Months

### Phase 5A: Test-System-Level Fixtures (3 months)
**Deliverables:**
- TEST_SYSTEM abstract class with on_prepare_test_system/on_clean_test_system
- Singleton resource registry (database, server, pools)
- Integration with TEST_APP
- Documentation + examples
- SCOOP deadlock testing
- Performance benchmark

**Effort:** 1 FTE

**Go/No-Go Criteria:**
- Benchmark: Fixture overhead < 10%
- SCOOP: Zero deadlocks in 100 concurrent scenarios
- Backward compat: All existing tests pass

### Phase 5B: Test-Feature-Level Fixtures (2-3 months)
**Deliverables:**
- on_prepare_feature / on_clean_feature hooks
- TEST_FIXTURE factory pattern
- Feature-level fixture composition
- Documentation + 20 examples
- Developer feedback loops
- Adoption metrics

**Effort:** 1-2 FTE

**Go/No-Go Criteria:**
- Developer feedback: 70%+ understand pattern
- Adoption: 30%+ new tests use feature fixtures
- Performance: No overhead when not used

### Phase 5C: Intra-Test-Feature Fixtures (2-3 months)
**Deliverables:**
- with_fixture (agent callback) pattern
- Nested fixture composition
- Exception-safe cleanup proofs
- Transaction + savepoint examples
- Adversarial exception testing (1000 scenarios)
- Documentation

**Effort:** 1-2 FTE

**Go/No-Go Criteria:**
- Adversarial testing: 1000 exception scenarios pass
- Cleanup: Zero resource leaks under stress
- Contract proof: Postconditions verified

### Phase 5D: Expanded Assertions (Phase across 6 months, parallel to 5C)
**Deliverables:**
- Domain-specific assertions (20+ methods)
  - Date/Time (3-4 methods)
  - Path/File (3-4 methods)
  - Exception (3-4 methods)
  - Collection (4-5 methods)
  - Complex types (3-4 methods)
- Documentation + examples
- Naming convention enforcement

**Effort:** 0.5 FTE (lower priority, parallel to other phases)

**Go/No-Go Criteria:**
- Each assertion has 5+ tests
- Naming collisions: Zero
- Documentation: 2+ examples per assertion

### Phase 6: Production Hardening (4-6 weeks)
**Deliverables:**
- Backward compatibility gate: All existing tests pass
- SCOOP consumer integration gate: No VUAR(2) errors
- Comprehensive adversarial testing (Phase 6 hardening)
- Final documentation
- Release candidate

**Effort:** 1 FTE

**Go/No-Go Criteria:**
- All tests pass: 100%
- No breaking changes
- 95%+ code coverage
- Zero production issues in pre-release

---

## Timeline Summary

```
Month:    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18
Phase:  [5A ................] [5B ..................] [5C ................] [5D ....................] [6 .....]

5A:      System fixtures, SCOOP deadlock testing, performance baseline
5B:      Feature fixtures, developer feedback, adoption metrics
5C:      Nested fixtures, exception safety, adversarial testing
5D:      Assertions (parallel), naming, documentation
6:       Hardening, backward compat gate, release prep

Critical Path: 5A → 5B → 5C (dependent)
Parallel: 5D (independent)
Gate: Phase 6 (final checks)
```

**Accelerated Option:** With 2 FTE, compress to 10-12 months

---

## Success Criteria

### Adoption (What matters most)
- **30%+ of new tests** use feature-level fixtures
- **20%+ of tests** use system-level fixtures
- **Adoption feedback:** Developers say "this helped"

### Quality (Technical)
- **Zero breaking changes** (backward compatibility 100%)
- **Zero deadlocks** in SCOOP scenarios
- **95%+ test coverage**
- **Performance:** Fixture overhead < 10%

### Documentation (Enablement)
- **User guide:** 50+ pages with architecture explained
- **Examples:** 50+ runnable code examples
- **Video tutorials:** 5 short videos
- **FAQ:** 20 common questions answered

### Ecosystem (Integration)
- **Simple Eiffel libraries:** 5+ adopt new fixtures
- **Community feedback:** Addressed in release notes
- **Support:** < 5 GitHub issues related to fixtures in first month

---

## Resource Requirements

### Team Composition
- **1 Eiffel Expert** (you) for architecture/code review
- **1-2 Developers** for implementation (FTE 5-8 months)
- **1 Tech Writer** for documentation (0.5 FTE, throughout)
- **QA/Testing:** Inherited from simple_testing testing process

### Budget (Rough Estimate)
- Development: 5-8 months × $10K/month = $50-80K
- Documentation: 3-4 months × $5K/month = $15-20K
- **Total:** $65-100K

---

## Key Risks & Mitigations

| Risk | Mitigation | Owner |
|------|-----------|-------|
| API complexity | Progressive rollout, decision trees, examples | Tech Writer |
| Feature adoption < 30% | Developer feedback loops, iterate | Arch Lead |
| Deadlock in SCOOP | Comprehensive testing, contract proof | Eiffel Expert |
| Backward compat broken | Zero-breaking-changes policy, regression tests | QA |
| Documentation insufficient | Early feedback, 50+ examples, videos | Tech Writer |

---

## Comparison: What This Enables

### Before (Current)
```eiffel
class MY_TEST_SET
    inherit TEST_SET_BASE
    feature
        on_prepare do
            -- Setup entire class
            database.initialize
            server.start
        end

        on_clean do
            -- Cleanup entire class
            database.close
            server.stop
        end

        test_feature_1 do
            assert_positive ("...", value)
            -- Manual reset before next test
        end

        test_feature_2 do
            assert_positive ("...", value)
        end
end
```

### After (Proposed)
```eiffel
class MY_TEST_SET
    inherit TEST_SET_BASE
    -- System-level resources inherited:
    --   system_database: separate DATABASE once ...
    --   resource_pool: separate RESOURCE_POOL once ...

    feature
        on_prepare_feature do
            -- Per-feature setup (automatic before each test)
            test_data.setup (system_database)
        end

        on_clean_feature do
            -- Per-feature cleanup (automatic after each test)
            test_data.cleanup (system_database)
        end

        test_feature_1 do
            local ctx: TEST_FIXTURE do
                ctx := create_test_fixture
                assert_date_before ("deadline", ctx.deadline, today)
                assert_collection_contains_all ("items", ctx.items, expected)

                -- Nested fixture
                with_database_transaction (agent
                    do
                        database.insert_test_row (1)
                        assert_positive ("inserted", database.count)
                    end)
            end
        end

        test_feature_2 do
            -- Automatic feature-level setup/cleanup
            assert_path_exists ("test file", ctx.temp_dir / "data.txt")
        end
end
```

**Key improvements:**
- System initialization once, not per-test-class
- Per-feature isolation automatic
- Nested transactions safe (auto-rollback)
- Rich assertions reduce boilerplate
- Fixtures are Eiffel-native (inheritance, agents)

---

## Next Steps

1. **Immediate (Week 1):**
   - Approve Phase 5A scope
   - Assign implementation lead
   - Create GitHub issues for Phase 5A

2. **Month 1 (Phase 5A):**
   - Implement TEST_SYSTEM with on_prepare_test_system/on_clean_test_system
   - Deadlock testing (100 concurrent scenarios)
   - Performance baseline

3. **Month 2 (Phase 5A Review):**
   - Code review by Eiffel expert
   - Go/No-Go decision on proceeding to 5B
   - Documentation begins

4. **Month 4 (Phase 5B Start):**
   - Feature-level fixtures (on_prepare_feature/on_clean_feature)
   - Developer feedback loops
   - Initial adoption metrics

---

## Appendix: Why Not Other Approaches?

### Alternative 1: Do Nothing (Status Quo)
- **Pro:** No risk, no effort
- **Con:** Developers continue manual setup/teardown boilerplate; fixtures missing at feature/system level
- **Rejected:** Doesn't address known gaps

### Alternative 2: Wrap pytest via simple_python
- **Pro:** Leverage existing pytest features
- **Con:** Python dependency; pytest doesn't map to Eiffel; simple_python is HTTP bridge, not test framework
- **Rejected:** Language mismatch; over-engineering

### Alternative 3: Minimal Enhancement (Assertions Only)
- **Pro:** Lower risk, simpler scope
- **Con:** Doesn't address fixtures (main gap); incomplete solution
- **Rejected:** Doesn't address main user need

### Selected: Full Three-Tier Fixtures
- **Pro:** Addresses all user needs; leverages Eiffel strengths (DBC, SCOOP)
- **Con:** Higher complexity, more effort
- **Selected:** Evidence-based; user-driven; aligns with Eiffel vision

---

## Final Recommendation

**BUILD** enhanced simple_testing with:
1. **Test-system-level fixtures** (Phase 5A)
2. **Test-feature-level fixtures** (Phase 5B)
3. **Intra-test fixtures** (Phase 5C)
4. **Expanded assertions** (Phase 5D, parallel)
5. **Production hardening** (Phase 6)

**Timeline:** 12-18 months (accelerable to 10-12 with 2 FTE)

**Confidence:** HIGH - user-driven, evidence-based, aligned with Eiffel's unique capabilities

**Next Action:** Approve Phase 5A; assign implementation lead

---

**Prepared by:** Research Team
**Date:** 2026-02-04
**Status:** READY FOR APPROVAL
**Next Phase:** Phase 0-Intent (Detailed intent review with stakeholders)
