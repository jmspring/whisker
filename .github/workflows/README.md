# Whisker CI/CD Workflows

This directory contains GitHub Actions workflows for automated testing and quality checks.

## Workflows

### Test Suite (`test.yml`)

Runs automatically on:
- Push to `main` or `feature/*` branches
- Pull requests to `main`

**Jobs:**

1. **Lua Backend Tests**
   - Runs all Lua tests using `tests/test_all.lua`
   - Tests: Engine, Renderer, Validator, Profiler, Debugger, Twine Import
   - Uploads test results as artifacts

2. **JavaScript Editor Tests**
   - Runs Jest test suite for web editor
   - Includes coverage reporting
   - Tests: Twine Parser, Twine Importer, Integration tests
   - Uploads coverage reports as artifacts

3. **Code Quality Checks**
   - Runs luacheck for Lua code linting
   - Configured via `.luacheckrc`
   - Continues on warnings (does not fail build)

## Test Coverage Goals

- **Lua Backend**: 80%+ coverage
- **JavaScript Editor**: 90%+ coverage

## Local Testing

Before pushing, run tests locally:

```bash
# Lua tests
lua tests/test_all.lua

# JavaScript tests
npm test

# JavaScript tests with coverage
npm run test:coverage

# Lua linting
luacheck src/ tests/
```

## Viewing Results

- **Actions Tab**: See workflow runs and status
- **Pull Requests**: Automatic status checks
- **Artifacts**: Download test results and coverage reports from completed runs
