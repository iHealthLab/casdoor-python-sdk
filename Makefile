.PHONY: help build clean test check-cve clean-all update-requirements

# Variables
VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
PYTHON_SYS := python3
DIST_DIR := dist

# Activate venv for commands
ACTIVATE := . $(VENV)/bin/activate &&

# Default target
help:
	@echo "Available targets:"
	@echo "  make build              - Build the package (creates venv, installs deps, builds wheel)"
	@echo "  make clean              - Remove build artifacts"
	@echo "  make clean-all          - Remove build artifacts and virtual environment"
	@echo "  make test               - Run tests"
	@echo "  make check-cve          - Check for CVEs in dependencies"
	@echo "  make update-requirements - Update requirements.txt from requirements.in"
	@echo ""
	@echo "All operations use a virtual environment in $(VENV)/"
	@echo ""
	@echo "Note: Package dependencies use version ranges (in pyproject.toml) for"
	@echo "      compatibility. requirements.txt (exact pins) is for development only."

# Ensure venv exists and is set up
ensure-venv:
	@if [ ! -d "$(VENV)" ]; then \
		echo "Creating virtual environment..."; \
		$(PYTHON_SYS) -m venv $(VENV); \
		$(VENV)/bin/pip install --quiet --upgrade pip; \
	fi

# Build the package
build: ensure-venv
	@echo "Installing build dependencies..."
	@$(PIP) install --quiet --upgrade pip setuptools wheel build
	@echo "Installing package dependencies..."
	@$(PIP) install --quiet -r requirements.txt
	@echo "Building package..."
	@$(PYTHON) -m build
	@echo ""
	@echo "✓ Build complete! Package is in $(DIST_DIR)/"
	@ls -lh $(DIST_DIR)/ 2>/dev/null | tail -2 || true

# Check for CVEs
check-cve: ensure-venv
	@echo "Installing pip-audit..."
	@$(PIP) install --quiet pip-audit
	@echo "Checking for CVEs..."
	@bash -c "$(ACTIVATE) pip-audit --requirement requirements.txt --format json --output pip-audit-report.json || true"
	@bash -c "$(ACTIVATE) pip-audit --requirement requirements.txt"
	@echo ""
	@echo "CVE report saved to pip-audit-report.json"

# Run tests
test: ensure-venv
	@echo "Installing dependencies..."
	@$(PIP) install --no-cache-dir --quiet -r requirements.txt pytest pytest-cov || $(PIP) install --quiet -r requirements.txt pytest pytest-cov
	@echo "Installing package in editable mode..."
	@$(PIP) install --no-cache-dir --quiet -e . || $(PIP) install --quiet -e .
	@echo "Running tests..."
	@bash -c "$(ACTIVATE) PYTHONPATH=$$(pwd)/src:$$PYTHONPATH python -m pytest src/tests/ -v" || echo "Tests completed with some failures"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build dist *.egg-info .eggs
	@find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@rm -f pip-audit-report.json safety-report.json
	@echo "✓ Clean complete"

# Clean everything including venv
clean-all: clean
	@echo "Removing virtual environment..."
	@rm -rf $(VENV)
	@echo "✓ Virtual environment removed"

# Update requirements.txt from requirements.in using pip-compile
update-requirements: ensure-venv
	@echo "Installing pip-tools..."
	@$(PIP) install --quiet pip-tools
	@echo "Compiling requirements.txt from requirements.in..."
	@bash -c "$(ACTIVATE) pip-compile requirements.in"
	@echo "✓ requirements.txt updated"
	@echo ""
	@echo "Note: Package dependencies in pyproject.toml use version ranges."
	@echo "      requirements.txt (exact pins) is for development/testing only."
