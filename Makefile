# Simplified Makefile for RHCE study repository
# Focus on essential tasks for studying and lab work

.PHONY: help setup lint docs serve lab-up lab-down clean

# Default target
help:
	@echo "RHCE Study Repository - Essential Commands:"
	@echo ""
	@echo "Setup:"
	@echo "  setup     - Install linting tools and pre-commit hooks"
	@echo ""
	@echo "Quality:"
	@echo "  lint      - Run Ansible and YAML linting"
	@echo ""
	@echo "Documentation:"
	@echo "  docs      - Build documentation site"
	@echo "  serve     - Start local documentation server"
	@echo ""
	@echo "Lab Environment:"
	@echo "  lab-up    - Start Vagrant lab environment"
	@echo "  lab-down  - Stop Vagrant lab environment"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean     - Clean build artifacts and caches"

# Setup
setup:
	@echo "🔧 Setting up RHCE study environment..."
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install -r requirements-lint.txt
	pre-commit install
	@echo "✅ Setup complete! Use 'make help' to see available commands."

# Linting
lint:
	@echo "🔍 Running linting checks..."
	@echo "Running ansible-lint..."
	@ansible-lint --version >/dev/null 2>&1 || (echo "❌ ansible-lint not installed. Run 'make setup' first." && exit 1)
	ansible-lint
	@echo "Running yamllint..."
	@yamllint --version >/dev/null 2>&1 || (echo "❌ yamllint not installed. Run 'make setup' first." && exit 1)
	yamllint .
	@echo "✅ All linting checks passed!"

# Documentation
docs:
	@echo "📚 Building documentation..."
	mkdocs build --clean

serve:
	@echo "🌐 Starting documentation server at http://127.0.0.1:8000"
	mkdocs serve

# Lab Environment
lab-up:
	@echo "🚀 Starting RHCE lab environment..."
	cd vagrant && ./lab-up.sh

lab-down:
	@echo "🛑 Stopping RHCE lab environment..."
	cd vagrant && ./lab-halt.sh

# Maintenance
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf site/
	rm -rf .cache/
	find . -name "*.retry" -delete