# 7S-05-SECURITY: simple_testing

**BACKWASH** | Date: 2026-01-23

## Security Considerations

### Test-Only Code
- TEST_SET_BASE and TEST_SET_BRIDGE are for test targets only
- Should not be included in production builds
- ECF configuration separates test and production targets

### Internal Feature Access
- TEST_SET_BRIDGE enables access to {NONE} features
- Only affects classes exported to TEST_SET_BRIDGE
- Requires explicit export declaration in tested class

### No Runtime Impact
- Test assertions only execute during test runs
- No production code paths affected
- Assertion postconditions are test-time contracts

## Risk Assessment

| Risk | Severity | Status |
|------|----------|--------|
| Production inclusion | Low | ECF separation |
| Internal access abuse | Low | Explicit export required |
| Test-time information leak | Low | Test environment only |

## Recommendations

1. Keep test targets separate in ECF
2. Only export to TEST_SET_BRIDGE what tests need
3. Review TEST_SET_BRIDGE exports during code review
