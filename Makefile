.PHONY: all clean test build install dev docs lint format help

# Colors for output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE   := $(shell tput -Txterm setaf 4)
RESET  := $(shell tput -Txterm sgr0)

# Default target
all: build test

# Help target
help:
	@echo "$(BLUE)Whisker Build System$(RESET)"
	@echo ""
	@echo "$(GREEN)Available targets:$(RESET)"
	@echo "  $(YELLOW)make all$(RESET)        - Build and test everything"
	@echo "  $(YELLOW)make build$(RESET)      - Build all components"
	@echo "  $(YELLOW)make test$(RESET)       - Run all tests"
	@echo "  $(YELLOW)make clean$(RESET)      - Clean build artifacts"
	@echo "  $(YELLOW)make install$(RESET)    - Install development dependencies"
	@echo "  $(YELLOW)make dev$(RESET)        - Start development environment"
	@echo "  $(YELLOW)make docs$(RESET)       - Generate documentation"
	@echo "  $(YELLOW)make lint$(RESET)       - Run linters"
	@echo "  $(YELLOW)make format$(RESET)     - Format code"
	@echo "  $(YELLOW)make release$(RESET)    - Create release package"
	@echo "  $(YELLOW)make benchmark$(RESET)  - Run performance benchmarks"
	@echo "  $(YELLOW)make docker-build$(RESET) - Build Docker images"
	@echo "  $(YELLOW)make docker-test$(RESET)  - Run tests in Docker"
	@echo ""

# Clean build artifacts
clean:
	@echo "$(BLUE)Cleaning build artifacts...$(RESET)"
	@./scripts/clean.sh
	@echo "$(GREEN)✓ Clean complete!$(RESET)"

# Run all tests
test:
	@echo "$(BLUE)Running tests...$(RESET)"
	@./build/scripts/run-tests.sh all
	@echo "$(GREEN)✓ Tests complete!$(RESET)"

# Run specific test suites
test-unit:
	@./build/scripts/run-tests.sh unit

test-integration:
	@./build/scripts/run-tests.sh integration

test-web:
	@./build/scripts/run-tests.sh web-editor
	@./build/scripts/run-tests.sh runtime

# Build all components
build:
	@echo "$(BLUE)Building all components...$(RESET)"
	@./build/scripts/build-all.sh
	@echo "$(GREEN)✓ Build complete!$(RESET)"

# Build specific components
build-core:
	@./build/scripts/build-core.sh

build-web:
	@./build/scripts/build-web-editor.sh
	@./build/scripts/build-runtime.sh

build-desktop:
	@./build/scripts/build-desktop.sh

# Install development dependencies
install:
	@echo "$(BLUE)Installing dependencies...$(RESET)"
	@./scripts/setup-dev.sh
	@echo "$(GREEN)✓ Installation complete!$(RESET)"

# Start development environment
dev:
	@echo "$(BLUE)Starting development environment...$(RESET)"
	@docker-compose -f build/docker/docker-compose.yml up

# Generate documentation
docs:
	@echo "$(BLUE)Generating documentation...$(RESET)"
	@lua build/tools/generate-docs.lua
	@echo "$(GREEN)✓ Documentation generated!$(RESET)"

# Serve documentation locally
docs-serve:
	@cd docs && mkdocs serve

# Run linters
lint:
	@echo "$(BLUE)Running linters...$(RESET)"
	@echo "Linting Lua code..."
	@luacheck src/ tests/ --config .luacheckrc || true
	@if [ -d "editor/web" ]; then \
		echo "Linting web editor..."; \
		cd editor/web && npm run lint || true; \
	fi
	@if [ -d "runtime/web" ]; then \
		echo "Linting web runtime..."; \
		cd runtime/web && npm run lint || true; \
	fi
	@echo "$(GREEN)✓ Linting complete!$(RESET)"

# Format code (if formatters are configured)
format:
	@echo "$(BLUE)Formatting code...$(RESET)"
	@if [ -d "editor/web" ]; then \
		cd editor/web && npm run format || true; \
	fi
	@if [ -d "runtime/web" ]; then \
		cd runtime/web && npm run format || true; \
	fi
	@echo "$(GREEN)✓ Formatting complete!$(RESET)"

# Create release package
release:
	@echo "$(BLUE)Creating release package...$(RESET)"
	@./build/scripts/package-release.sh $$(cat VERSION)
	@echo "$(GREEN)✓ Release package created!$(RESET)"

# Run performance benchmarks
benchmark:
	@echo "$(BLUE)Running performance benchmarks...$(RESET)"
	@cd tests/performance && lua run-benchmarks.lua
	@echo "$(GREEN)✓ Benchmarks complete!$(RESET)"

# Validate example stories
validate:
	@echo "$(BLUE)Validating stories...$(RESET)"
	@./build/scripts/validate-stories.sh
	@echo "$(GREEN)✓ Validation complete!$(RESET)"

# Docker commands
docker-build:
	@echo "$(BLUE)Building Docker images...$(RESET)"
	@docker build -f build/docker/Dockerfile.build -t whisker:build .
	@docker build -f build/docker/Dockerfile.test -t whisker:test .
	@echo "$(GREEN)✓ Docker images built!$(RESET)"

docker-test:
	@echo "$(BLUE)Running tests in Docker...$(RESET)"
	@docker run --rm -v $(PWD):/workspace whisker:test
	@echo "$(GREEN)✓ Docker tests complete!$(RESET)"

docker-clean:
	@echo "$(BLUE)Cleaning Docker resources...$(RESET)"
	@docker-compose -f build/docker/docker-compose.yml down -v
	@docker rmi whisker:build whisker:test 2>/dev/null || true
	@echo "$(GREEN)✓ Docker cleanup complete!$(RESET)"

# Watch for changes and rebuild (requires entr or similar)
watch:
	@echo "$(BLUE)Watching for changes...$(RESET)"
	@find src/ -name "*.lua" | entr -c make build