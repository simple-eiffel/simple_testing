# simple_testing

[Documentation](https://simple-eiffel.github.io/simple_testing/) •
[GitHub](https://github.com/simple-eiffel/simple_testing) •
[Issues](https://github.com/simple-eiffel/simple_testing/issues)

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Eiffel 25.02](https://img.shields.io/badge/Eiffel-25.02-purple.svg)
![DBC: Contracts](https://img.shields.io/badge/DBC-Contracts-green.svg)

Design-by-Contract test framework with advanced fixtures and assertions.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- 73+ tests passing, 100% pass rate
- System-level, feature-level, and nested fixtures
- Mathematical Model Library (MML) integration for formal verification
- Design by Contract throughout

## Quick Start

```eiffel
class MY_TEST_SET
inherit TEST_SET_BASE
feature
    test_something
        local
            l_fixture: TEST_FIXTURE_MOCK
        do
            create l_fixture
            l_fixture.on_create
            assert ("is_valid", l_fixture.is_valid)
            l_fixture.on_destroy
        end
end
```

For complete documentation, see [our docs site](https://simple-eiffel.github.io/simple_testing/).

## Features

- System-level fixtures (once per test run)
- Feature-level fixtures (once per test feature)
- Nested fixtures with exception-safe cleanup
- 40+ assertion methods
- Mathematical Model Library integration
- SCOOP compatible (concurrency-ready)

For details, see the [User Guide](https://simple-eiffel.github.io/simple_testing/user-guide.html).

## Installation

```bash
# Add to your ECF:
<library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
```

## License

MIT License - See LICENSE file

## Support

- **Docs:** https://simple-eiffel.github.io/simple_testing/
- **GitHub:** https://github.com/simple-eiffel/simple_testing
- **Issues:** https://github.com/simple-eiffel/simple_testing/issues
