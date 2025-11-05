# Testing Documentation

This testing submodule provides comprehensive tests for all features in the Minecraft Modpack Docker project.

## Overview

The test suite validates:
- **Setup Service** - Environment initialization and directory structure
- **Minecraft Modpack** - Server setup and configuration
- **Borgmatic** - Backup service configuration and scripts
- **MCASelector** - Chunk cleanup functionality
- **Unmined** - Map generation service
- **Ofelia** - Job scheduling configuration
- **Integration** - Full stack integration and dependencies

## Running Tests

### Run All Tests

```bash
cd testing
chmod +x scripts/*.sh
./scripts/run-all-tests.sh
```

### Run Individual Test Suites

```bash
# Test setup service
./scripts/test-setup-service.sh

# Test minecraft modpack service
./scripts/test-minecraft-modpack.sh

# Test borgmatic backup service
./scripts/test-borgmatic.sh

# Test mcaselector chunk cleanup
./scripts/test-mcaselector.sh

# Test unmined map generation
./scripts/test-unmined.sh

# Test ofelia job scheduler
./scripts/test-ofelia.sh

# Test full integration
./scripts/test-integration.sh
```

## Test Structure

```
testing/
├── scripts/           # Test scripts
│   ├── run-all-tests.sh           # Main test runner
│   ├── test-setup-service.sh      # Setup service tests
│   ├── test-minecraft-modpack.sh  # Minecraft service tests
│   ├── test-borgmatic.sh          # Borgmatic tests
│   ├── test-mcaselector.sh        # MCASelector tests
│   ├── test-unmined.sh            # Unmined tests
│   ├── test-ofelia.sh             # Ofelia tests
│   └── test-integration.sh        # Integration tests
├── lib/               # Test utilities
│   ├── test-framework.sh          # Test assertion framework
│   └── docker-utils.sh            # Docker testing utilities
└── docs/              # Documentation
    └── README.md                   # This file
```

## Test Framework

The test framework (`lib/test-framework.sh`) provides:

### Assertion Functions

- `assert_equals expected actual [name]` - Assert two values are equal
- `assert_true condition [name]` - Assert a condition is true
- `assert_file_exists filepath [name]` - Assert a file exists
- `assert_dir_exists dirpath [name]` - Assert a directory exists
- `assert_contains haystack needle [name]` - Assert string contains substring

### Test Organization

- `test_suite "Suite Name"` - Declare a new test suite
- `print_summary` - Print test results summary

### Example Test

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/../lib/test-framework.sh"

test_suite "My Feature"

test_my_feature() {
    assert_file_exists "/path/to/file" "File exists"
    assert_equals "expected" "actual" "Values match"
}

test_my_feature
print_summary
```

## What Each Test Suite Validates

### test-setup-service.sh
- init.sh script exists and is executable
- Script creates required directories (data/setup-scripts, config, etc.)
- Script handles .env file creation
- Templates exist (.env.example, ofelia-config.ini)
- Template content includes required variables and job definitions
- Dockerfile uses correct base image and copies all files

### test-minecraft-modpack.sh
- Wrapper script exists and is executable
- Wrapper validates MODPACK_URL and sets GENERIC_PACK for itzg base image
- Dockerfile extends itzg/minecraft-server
- Docker compose service configured with correct volumes and ports
- Environment variables properly configured
- Interactive console enabled (stdin/tty)

### test-borgmatic.sh
- Backup and entrypoint scripts exist and are executable
- Scripts call borgmatic with correct parameters
- Configuration template includes all required sections
- Backup sources include world, config, mods, logs
- Retention policy configured (daily, weekly, monthly)
- Compression enabled
- Repository initialization handled in entrypoint
- Docker volumes mounted correctly

### test-mcaselector.sh
- Delete-chunks script exists and is executable
- Script reads configuration from YAML
- Script handles LastUpdated and InhabitedTime filters
- Script calls MCASelector.jar with correct parameters
- Configuration template has multiple deletion rules
- Dockerfile downloads latest MCASelector from GitHub
- World directory mounted correctly

### test-unmined.sh
- Map generation script exists and is executable
- Script calls unmined-cli with web render command
- Script validates world directory exists
- Dockerfile uses .NET runtime Alpine image
- Downloads Alpine-compatible unmined-cli binary
- Nginx configured to serve generated maps
- Cloudflared configured for tunnel hosting

### test-ofelia.sh
- Entrypoint script creates config symlink
- Configuration template defines all jobs
- Cron schedules properly formatted (5 fields)
- No-overlap setting prevents concurrent runs
- Container and command references are correct
- Docker socket mounted for job execution
- Service depends on all scheduled containers

### test-integration.sh
- All services defined in docker-compose.yml
- Build compose file properly configured
- Shared scripts volume populated by setup, used by minecraft
- Data directory structure matches initialization
- Service dependencies properly configured
- Environment file used by appropriate services
- Documentation complete and covers all components
- All Dockerfiles present for custom images

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run tests
  run: |
    cd testing
    chmod +x scripts/*.sh
    ./scripts/run-all-tests.sh
```

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Adding New Tests

To add new tests:

1. Create a new test script in `testing/scripts/`
2. Source the test framework: `source "$(dirname "$0")/../lib/test-framework.sh"`
3. Define test suites with `test_suite "Name"`
4. Write test functions using assertion helpers
5. Call `print_summary` at the end
6. Add the script to `run-all-tests.sh`

## Troubleshooting

### Tests fail with "command not found"
Ensure scripts are executable: `chmod +x testing/scripts/*.sh`

### Can't source test framework
Run tests from the `testing/` directory or use absolute paths.

### Docker-related tests fail
Some tests may require Docker to be running. Ensure Docker daemon is accessible.
