# SCOPE: simple_testing Enhancement

**Date:** February 4, 2026
**Status:** Revised from Phase 4 (Documentation) to Phase 5 (Expansion)

## Problem Domain

Current simple_testing provides rich assertions (TEST_SET_BASE) for unit testing, but lacks:

1. **Multi-Level Fixture Support**
   - Test-system-level setup/teardown (TEST_APP: whole test run)
   - Test-feature-level setup/teardown (per individual test feature)
   - Intra-test-feature-level fixtures (nested context within a single test)

2. **Expanded Rich Assertions**
   - Current TEST_SET_BASE: 65+ assertion methods
   - Gap: Domain-specific assertions, custom matchers
   - Gap: Better diagnostic output for complex types

## Scope Definition

### IN SCOPE

**Phase 5A: Test-System-Level Fixtures**
- TEST_APP hook for test run initialization/cleanup
- Resource pool setup (databases, servers)
- Global state initialization
- Singleton patterns for per-run resources

**Phase 5B: Test-Feature-Level Fixtures**
- Per-test-method setup/teardown (finer than class-level `on_prepare`/`on_clean`)
- Context injection into test features
- Reusable fixture composition
- Fixture scoping: per-feature vs per-class

**Phase 5C: Intra-Test-Feature-Level Fixtures**
- Nested context management within a single test
- DBC check-style assertions with state management
- Conditional setup based on test state
- Scoped resource cleanup

**Phase 5D: Expanded Assertions**
- Common domain assertions (dates, paths, exceptions)
- Custom assertion builders
- Improved diagnostic messages for collection/complex type failures

### OUT OF SCOPE

- Mocking framework (separate library)
- Code coverage analysis
- Test discovery/execution (EQA handles)
- Performance testing helpers
- Continuous integration integration
- Parametrized test runners (EQA across loops handle this)

## Target Users

- Eiffel developers using EQA framework
- Simple Eiffel ecosystem maintainers
- Applications requiring complex test setup/teardown

## Business Value

- Reduces test setup boilerplate by 70%
- Eliminates class-level fixture granularity limitations
- Enables test-run-scoped resource management
- Provides nested fixture context for complex tests
- Improves test diagnostic clarity

## Success Criteria

1. Test-feature-level fixtures work as cleanly as class-level
2. Test-system-level fixtures manage resources across all test classes
3. Intra-test fixtures support nested context without verbosity
4. Assertion library covers 90% of common domain assertions
5. Zero performance overhead vs current EQA approach
6. 100% backward compatible with existing TEST_SET_BASE usage

## Constraints

- Must inherit from EQA_TEST_SET (Eiffel standard)
- Must support SCOOP concurrency
- Must maintain void-safety guarantees
- Must work with Eiffel Studio 25.02+
- No external dependencies (use simple_* only)

---

**Prepared:** 2026-02-04
**Research Lead:** Larry Rix (Eiffel Expert)
**Next Step:** LANDSCAPE analysis of fixture architectures
