# RISKS: simple_testing Enhancement

**Date:** February 4, 2026

## Risk Register

| ID | Risk | Likelihood | Impact | Mitigation | Status |
|----|------|-----------|--------|-----------|--------|
| R-01 | API complexity overwhelming developers | MEDIUM | MEDIUM | Progressive documentation, phase rollout | MANAGE |
| R-02 | Fixture performance overhead significant | LOW | MEDIUM | Benchmark, optimize, document | MONITOR |
| R-03 | SCOOP separate resource deadlock | LOW | HIGH | Comprehensive testing, contract review | PREVENT |
| R-04 | Nested fixture exception handling broken | LOW | HIGH | Thorough adversarial testing | PREVENT |
| R-05 | Backward compatibility broken (existing tests fail) | VERY LOW | CRITICAL | Zero-breaking-changes policy | PREVENT |
| R-06 | Feature-level fixtures not actually useful (adoption fails) | MEDIUM | MEDIUM | Developer feedback loops, iterate | MANAGE |
| R-07 | Fixture lifecycle edge cases (cleanup on exception, resource leaks) | MEDIUM | MEDIUM | Adversarial testing, contract proof | PREVENT |
| R-08 | Documentation insufficient; developers don't understand architecture | HIGH | MEDIUM | Comprehensive guide, 10+ examples | MANAGE |
| R-09 | ECF configuration complex; integration issues | LOW | MEDIUM | Test integration gate, examples | PREVENT |
| R-10 | Assertion naming collisions or confusion | LOW | LOW | Clear naming convention, docs | MANAGE |

---

## Detailed Risk Analysis

### R-01: API Complexity

**Description:** Three-tier fixture system (system/feature/nested) + 20+ new assertions may overwhelm developers

**Likelihood:** MEDIUM (testing frameworks often suffer from complexity)

**Impact:** MEDIUM (adoption friction, not impossibility)

**Indicators:**
- Complex API poorly adopted
- Developers fall back to manual setup/teardown
- Support requests about which pattern to use

**Mitigation:**
1. **Progressive rollout:** Release Phase 5A (system), wait 1 month, 5B (feature), wait 1 month, 5C (nested)
2. **Decision trees:** "Pick your pattern" guide based on test complexity
3. **Examples:** 50+ runnable examples covering common scenarios
4. **Video tutorials:** Brief screencasts showing each pattern

**Contingency:** Simplify nested fixtures if adoption is < 20%

---

### R-02: Fixture Performance Overhead

**Description:** System/feature/nested fixture setup might dominate test execution time

**Likelihood:** LOW (setup is typically small compared to test logic)

**Impact:** MEDIUM (slow test suites harm productivity)

**Indicators:**
- Benchmarks show > 10% overhead (see NFR-PERF-02)
- 1000-test suite takes > 5 seconds just for fixtures

**Mitigation:**
1. **Benchmark early:** Phase 5A milestone includes performance testing
2. **Profile & optimize:** Hotspot analysis if overhead detected
3. **Document expectations:** "Fixture overhead is typically < 1% of test time"
4. **Opt-out available:** Tests can skip fixtures if needed

**Contingency:** Implement caching, memoization, or lazy initialization

---

### R-03: SCOOP Deadlock with Separate Resources

**Description:** System-level resources (separate DATABASE) could deadlock if contracts not carefully enforced

**Likelihood:** LOW (SCOOP is well-designed, rare deadlocks)

**Impact:** HIGH (deadlocked test suite fails to complete)

**Indicators:**
- Test suite hangs indefinitely
- Timeout in CI/CD
- Debugger shows separate object waiting indefinitely

**Mitigation:**
1. **Contract enforcement:** Preconditions enforce acquire/release pattern
2. **Deadlock-free proof:** Code review by SCOOP expert
3. **Comprehensive testing:** 100 concurrent fixture access tests
4. **Timeout detection:** CI/CD detects hangs, fails fast

**Contingency:** Simplify separate resource model, use only session-scoped (non-separate) fixtures

---

### R-04: Nested Fixture Exception Handling Broken

**Description:** Agent callback throws exception; cleanup doesn't run; resource leak

**Likelihood:** LOW (well-tested pattern, common in other languages)

**Impact:** HIGH (tests pollute each other's state; cascading failures)

**Indicators:**
- After exception in callback, fixture not cleaned up
- Subsequent tests fail mysteriously
- Resource count grows during test execution

**Mitigation:**
1. **Contract proof:** Postcondition must hold (cleanup done) even on exception
2. **Adversarial testing:** 1000 exception scenarios in Phase 6 hardening
3. **Code review:** Line-by-line review of exception path
4. **Eiffel exception safety:** Language guarantees postcondition > exception

**Contingency:** Implement manual try/catch; document workarounds; revert to factory pattern

---

### R-05: Backward Compatibility Broken

**Description:** Changes to TEST_SET_BASE break existing 59+ simple_* library tests

**Likelihood:** VERY LOW (zero-breaking-changes policy enforced)

**Impact:** CRITICAL (entire ecosystem broken)

**Indicators:**
- Existing test fails with compilation error
- AssertionViolation in previously-passing tests
- API removal detected in diff

**Mitigation:**
1. **Policy:** Additive only. No removal, no renaming.
2. **Code review:** Ensure no breaking changes to existing features
3. **Compatibility matrix:** Test against all simple_* libraries
4. **Regression tests:** Phase 5 includes "existing tests still pass" test

**Contingency:** Immediate rollback; maintain parallel version

---

### R-06: Feature-Level Fixtures Adoption Fails

**Description:** Developers don't see value; stick with class-level `on_prepare`/`on_clean`

**Likelihood:** MEDIUM (new patterns require behavior change)

**Impact:** MEDIUM (feature exists but unused; not a blocker)

**Indicators:**
- Developer surveys: "Don't understand use case"
- GitHub issues: "When would I use feature-level fixtures?"
- Adoption metrics: < 20% of new tests use feature fixtures

**Mitigation:**
1. **Use case documentation:** Real-world examples (database reset, file cleanup)
2. **Feedback loops:** Developer interviews during Phase 5B
3. **Iterate:** Simplify pattern if feedback suggests overcomplexity
4. **Showcase:** Highlight 2-3 simple_* libraries using pattern

**Contingency:** Mark as "optional" pattern; focus on system/nested if preferred

---

### R-07: Fixture Lifecycle Edge Cases

**Description:** Cleanup on exception, order of cleanup, resource leaks in corner cases

**Likelihood:** MEDIUM (edge cases always present)

**Impact:** MEDIUM (tests become unreliable; flaky failures)

**Indicators:**
- Sporadic test failures
- Resource exhaustion after N tests
- Cleanup logs show resources not released

**Mitigation:**
1. **Adversarial testing:** Phase 6 covers edge cases
2. **Exception scenarios:** Test cleanup with 20+ exception types
3. **Resource monitoring:** Track allocation/deallocation
4. **Contract review:** Postconditions prevent resource leaks
5. **Stress testing:** 10K iterations of fixture create/destroy

**Contingency:** Document known limitations; provide workarounds

---

### R-08: Documentation Insufficient

**Description:** Architecture is novel; documentation unclear; developers confused

**Likelihood:** HIGH (common with new testing patterns)

**Impact:** MEDIUM (adoption friction, support burden)

**Indicators:**
- GitHub issues: "How do I...?"
- Low adoption of feature-level fixtures
- Developer confusion about which pattern to use

**Mitigation:**
1. **Comprehensive guide:** 50+ page user guide with architecture explained
2. **Examples:** 50+ runnable code examples covering patterns
3. **Decision tree:** "Pick your fixture pattern" flowchart
4. **Video tutorials:** 5 short videos (5 min each) on each tier
5. **FAQ:** 20 common questions answered
6. **Community:** Solicit feedback from Eiffel team early

**Contingency:** Create interactive tutorial; provide office hours for developers

---

### R-09: ECF Configuration Complex

**Description:** Integrating simple_testing with ECF might cause configuration issues

**Likelihood:** LOW (ECF is stable, simple_testing already in ecosystem)

**Impact:** MEDIUM (integration problems block adoption)

**Indicators:**
- Compilation fails: "Library not found"
- VUAR(2) errors in consumer projects
- Configuration examples not working

**Mitigation:**
1. **Integration gate:** Phase 5A includes SCOOP consumer integration test
2. **Example ECFs:** Template ECF for different project types
3. **CI/CD:** Integration tested on every commit
4. **Troubleshooting guide:** Common ECF issues documented

**Contingency:** Provide migration script; simplify ECF if needed

---

### R-10: Assertion Naming Collisions

**Description:** New assertions named poorly; collisions with user code or other libraries

**Likelihood:** LOW (careful naming applied)

**Impact:** LOW (namespace issue, easily fixed)

**Indicators:**
- Compilation error: "Feature already defined"
- Developer: "Can't use assert_X because my class uses it"

**Mitigation:**
1. **Naming convention:** All assertions use prefix `assert_` (clear, consistent)
2. **Domain-specific:** Domain in name: `assert_date_`, `assert_path_`, `assert_exception_`
3. **Review:** Naming checked in code review
4. **Documentation:** Naming strategy explained

**Contingency:** Rename under version; provide alias for compatibility

---

## Risk Mitigation Schedule

### Phase 5A (System Fixtures)
- **Test:** SCOOP deadlock testing (R-03)
- **Benchmark:** Performance baseline (R-02)
- **Integration:** Consumer ECF test (R-09)

### Phase 5B (Feature Fixtures)
- **Feedback:** Developer interviews (R-06)
- **Documentation:** Initial guide (R-08)
- **Testing:** Edge cases (R-07)

### Phase 5C (Nested Fixtures)
- **Exception testing:** Comprehensive exception scenarios (R-04)
- **Documentation:** Nested pattern guide (R-08)
- **Adversarial:** 1000 exception + cleanup tests (R-04, R-07)

### Phase 5D (Assertions)
- **Naming review:** Collision check (R-10)
- **Documentation:** Assertion guide (R-08)

### Phase 6 (Hardening)
- **Backward compatibility:** All existing tests still pass (R-05)
- **API complexity:** Finalize docs (R-01)
- **Comprehensive testing:** 10K+ test scenarios (all risks)

---

## Contingency Plans by Risk Level

### CRITICAL Risks (Must Prevent)
- **R-05 (Backward compat):** Zero-breaking-changes policy enforced; parallel version maintained
- **R-03 (Deadlock):** Simplify separate model; use session-scoped only

### HIGH Risks (Should Prevent)
- **R-04 (Exception handling):** Revert to factory pattern if issues
- **R-08 (Documentation):** Reduce scope to phase 5A only

### MEDIUM Risks (Can Manage)
- **R-01 (Complexity):** Progressive rollout; decision trees
- **R-02 (Performance):** Optimize; document overhead
- **R-06 (Adoption):** Mark feature fixtures optional; iterate
- **R-07 (Edge cases):** Document workarounds
- **R-09 (ECF):** Provide migration script

### LOW Risks (Monitor)
- **R-10 (Naming):** Rename; provide alias

---

**Prepared:** 2026-02-04
**Next Step:** RECOMMENDATION - Implementation strategy and phase plan
