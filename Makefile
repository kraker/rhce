# Makefile for RHCE study repository
# Provides common development and maintenance tasks

.PHONY: help setup install-dev install-test clean lint test docs serve build pre-commit-install pre-commit-run

# Default target
help:
	@echo "RHCE Study Repository - Available Commands:"
	@echo ""
	@echo "Setup and Installation:"
	@echo "  setup           - Complete development environment setup"
	@echo "  install-dev     - Install development dependencies"
	@echo "  install-test    - Install testing dependencies"
	@echo "  pre-commit-install - Install pre-commit hooks"
	@echo ""
	@echo "Code Quality:"
	@echo "  lint            - Run all linting checks"
	@echo "  pre-commit-run  - Run pre-commit hooks on all files"
	@echo "  ansible-lint    - Run Ansible-specific linting"
	@echo "  yaml-lint       - Run YAML linting"
	@echo "  markdown-lint   - Run Markdown linting"
	@echo "  ruby-lint       - Run Ruby linting (Vagrantfile)"
	@echo ""
	@echo "Documentation:"
	@echo "  docs            - Build MkDocs documentation"
	@echo "  serve           - Start local documentation server"
	@echo ""
	@echo "Testing and Validation:"
	@echo "  test            - Run Ansible syntax checks"
	@echo "  validate        - Validate all playbooks and configurations"
	@echo ""
	@echo "Lab Environment:"
	@echo "  lab-up          - Start Vagrant lab environment"
	@echo "  lab-down        - Stop Vagrant lab environment"
	@echo "  lab-reset       - Reset Vagrant lab to clean state"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean           - Clean build artifacts and caches"
	@echo "  update-deps     - Update all dependencies"

# Setup and Installation
setup: install-dev pre-commit-install
	@echo "✅ Development environment setup complete!"

install-dev:
	@echo "📦 Installing development dependencies..."
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

install-test:
	@echo "📦 Installing testing dependencies..."
	pip install -r requirements-test.txt

pre-commit-install:
	@echo "🔧 Installing pre-commit hooks..."
	pre-commit install
	pre-commit install --hook-type commit-msg

# Code Quality
lint: ansible-lint yaml-lint markdown-lint ruby-lint
	@echo "✅ All linting checks passed!"

pre-commit-run:
	@echo "🔍 Running pre-commit hooks on all files..."
	pre-commit run --all-files

ansible-lint:
	@echo "🔍 Running Ansible linting..."
	ansible-lint

yaml-lint:
	@echo "🔍 Running YAML linting..."
	yamllint .

markdown-lint:
	@echo "🔍 Running Markdown linting..."
	markdownlint docs/ README.md CLAUDE.md COPYRIGHT_NOTICE.md

ruby-lint:
	@echo "🔍 Running Ruby linting..."
	@if command -v rubocop >/dev/null 2>&1; then \
		rubocop --config .rubocop.yml; \
	else \
		echo "⚠️  RuboCop not installed. Install with: gem install rubocop rubocop-performance rubocop-rspec"; \
		echo "   Or run: make pre-commit-run (which will install it automatically)"; \
	fi

# Documentation
docs:
	@echo "📚 Building documentation..."
	mkdocs build --clean

serve:
	@echo "🌐 Starting documentation server at http://127.0.0.1:8000"
	mkdocs serve

# Testing and Validation
test:
	@echo "🧪 Running Ansible syntax checks..."
	find . -name "*.yml" -o -name "*.yaml" | \
	grep -v site/ | grep -v sources/ | \
	while read playbook; do \
		echo "Checking syntax: $$playbook"; \
		ansible-playbook --syntax-check "$$playbook" || exit 1; \
	done

validate: lint test
	@echo "✅ All validation checks passed!"

# Lab Environment (Vagrant)
lab-up:
	@echo "🚀 Starting RHCE lab environment..."
	cd vagrant && ./lab-up.sh

lab-down:
	@echo "🛑 Stopping RHCE lab environment..."
	cd vagrant && ./lab-halt.sh

lab-reset:
	@echo "🔄 Resetting RHCE lab environment..."
	cd vagrant && ./lab-reset.sh

# Maintenance
clean:
	@echo "🧹 Cleaning build artifacts and caches..."
	rm -rf site/
	rm -rf .cache/
	rm -rf .pytest_cache/
	rm -rf htmlcov/
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +

update-deps:
	@echo "⬆️ Updating dependencies..."
	pip install --upgrade pip
	pip install --upgrade -r requirements.txt
	pip install --upgrade -r requirements-dev.txt
	pre-commit autoupdate