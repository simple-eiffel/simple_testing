# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added (1.1.0 — TIMING WITHOUT CONTRACTS)

- `TEST_SET_BASE.without_contracts (work)` runs `work` with contract
  checking off (`{ISE_RUNTIME}.check_assert`), then turns checking back on
  as it was, even when `work` raises. It is for timing tests: a frame
  budget is the shipping build's, and with checking on every call also
  evaluates its contracts. Wrap only the measured work. Larry, 2026-10-25:
  "Timing needs trump contracts." First user: simple_widgets' GW-29 grid
  test. There, a 100,000-row grid's wheel frame went from 14.8 milliseconds
  with contracts on to 3.7 inside the wrapper, and the lean build takes 1.5.
- Tests: `test_without_contracts_switches_checking_off_and_back` and
  `test_without_contracts_restores_after_an_exception`.
- The test target builds again. Its cluster pointed at a `test` folder that
  does not exist (the tests are in `testing`), and it now repeats the
  assertion option, because a target that extends another otherwise runs
  its own clusters without contracts. 18 pass.


### Changed
- Add SCOOP concurrency capability
- Add simple_testing library with enhanced assertions
- first commit

## [1.0.0] - 2025-12-08

### Added
- Initial release
- Core functionality implemented
- Test suite with comprehensive coverage
- Documentation and examples

[Unreleased]: https://github.com/simple-eiffel/simple_testing/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/simple-eiffel/simple_testing/releases/tag/v1.0.0
