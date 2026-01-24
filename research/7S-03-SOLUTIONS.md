# 7S-03-SOLUTIONS: simple_testing


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Alternative Solutions Considered

### 1. Plain EQA_TEST_SET
- **Pros**: Standard, no dependencies
- **Cons**: Verbose, limited assertions, poor failure messages
- **Decision**: Too basic for productive testing

### 2. Custom assertion library (standalone)
- **Pros**: Full control
- **Cons**: Integration effort, separate dependency
- **Decision**: Better to extend EQA

### 3. EQA_COMMONLY_USED_ASSERTIONS
- **Pros**: Official, some additional assertions
- **Cons**: Still limited, messages not detailed
- **Decision**: Good base to extend

### 4. TEST_SET_BASE extension (Chosen)
- **Pros**: Inherits EQA, adds rich assertions, ecosystem standard
- **Cons**: Ecosystem-specific dependency
- **Decision**: Perfect balance of features and simplicity

## Chosen Approach

**Deferred class extending EQA_TEST_SET and EQA_COMMONLY_USED_ASSERTIONS**

- Inherits all EQA infrastructure
- Overrides basic assertions with detailed messages
- Adds comprehensive assertion methods
- TEST_SET_BRIDGE enables internal access

## Design Decisions

1. **Deferred class**: Forces tests to inherit, enabling setup inheritance
2. **Message formatting**: Consistent, detailed failure messages
3. **Postconditions**: Document what each assertion verifies
4. **Numeric precision**: Epsilon-based real comparison
