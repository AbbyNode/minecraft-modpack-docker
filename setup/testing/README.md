# Testing Submodule

Comprehensive test suite for all features in the Minecraft Modpack Docker project.

## Quick Start

```bash
cd testing
chmod +x scripts/*.sh
./scripts/run-all-tests.sh
```

## Test Coverage

This test suite validates:
- ✅ Setup service initialization
- ✅ Minecraft modpack server
- ✅ Borgmatic backup configuration and scripts
- ✅ MCASelector chunk cleanup functionality
- ✅ Unmined map generation
- ✅ Ofelia job scheduling
- ✅ Full stack integration

## Test Suites

| Test Suite | Description |
|------------|-------------|
| `test-setup-service.sh` | Tests environment initialization |
| `test-minecraft-modpack.sh` | Tests Minecraft server setup |
| `test-borgmatic.sh` | Tests backup service |
| `test-mcaselector.sh` | Tests chunk cleanup service |
| `test-unmined.sh` | Tests map generation service |
| `test-ofelia.sh` | Tests job scheduler configuration |
| `test-integration.sh` | Tests full stack integration |

## Documentation

See [docs/README.md](docs/README.md) for detailed testing documentation.

## Requirements

- Bash 4.0+
- Docker (for integration tests)

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed
