# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context Loading

**IMPORTANT**: When starting work on this project, Claude Code must read these files first to understand the current state and guidelines:

## User Context

**GitHub Username**: @kraker (not stovepipe)
**Repository**: <https://github.com/kraker/rhce>
**GitHub Pages Site**: <https://kraker.github.io/rhce/>

CRITICAL: Always use @kraker as the GitHub username in all URLs, repository references, and documentation.

1. **CLAUDE.md** (this file) - Project overview, repository structure, and coding guidelines
2. **README.md** - Public project description, quick start guide, and study workflow
3. **COPYRIGHT_NOTICE.md** - Detailed copyright information for all materials in the repository

These files contain essential context for maintaining consistency with established patterns and avoiding copyright violations.

## Project Overview

This is a Red Hat Certified Engineer (RHCE) certification study repository focused on Ansible automation. It contains practical playbook examples, study modules, reference materials, and memorization aids for RHCE exam preparation. This is NOT a software development project - it's a learning resource for Ansible automation and configuration management.

## Repository Structure

- `docs/` - Core study materials (MkDocs documentation source, tracked in git)
  - `index.md` - Main site homepage with navigation and overview
  - `rhce_synthesis/` - **Comprehensive knowledge base with 8 detailed modules** covering all RHCE topics
    - `00_exam_overview.md` - RHCE exam strategy and format guide
    - `01_ansible_basics.md` - Ansible fundamentals and setup
    - `02_playbooks_tasks.md` through `08_advanced_features.md` - Complete topic coverage
    - `index.md` - Master navigation and progress tracking
    - `_template.md` - Consistent module structure template
  - `exam_quick_reference.md` - Quick reference guide for exam day with essential Ansible syntax
  - `ansible_module_reference.md` - Key Ansible modules organized for systematic study
  - `command_reference.md` - Commands organized by functional area
  - `rhce_glossary.md` - Comprehensive glossary of RHCE/Ansible terms
- `anki/` - Anki flashcard deck (tracked in git)
  - `rhce_deck.csv` - Comprehensive flashcards covering all RHCE exam objectives
- `ansible/` - Practice environment and examples
  - `practice/` - Sample playbooks and automation exercises
- `mkdocs.yml` - MkDocs configuration file for documentation site
- `requirements.txt` - Python dependencies for MkDocs
- `.github/workflows/deploy.yml` - GitHub Actions workflow for automatic deployment to GitHub Pages
- `sources/` - External resources (not tracked in git, contains copyrighted materials)
  - Study books converted from EPUB to markdown, official documentation, practice guides

## Lab Environment Requirements

**Ansible Lab Setup**: The study environment requires:

- RHEL 9 control node with Ansible installed
- 2-3 RHEL 9 managed nodes for automation targets
- SSH key-based authentication configured
- Network connectivity between all nodes
- Prerequisites: Basic Linux knowledge, RHCSA certification

**Control Node Configuration**:

- Ansible core installed via dnf
- Required collections installed (ansible.posix, community.general)
- SSH client configured for passwordless authentication

**Managed Node Configuration**:

- Python 3 installed for Ansible modules
- SSH server running and accessible
- User accounts for automation practice

## Common Study Tasks

### Working with Study Materials

- **Visit Documentation Site**: Browse <https://kraker.github.io/rhce/> for organized study materials
- **Start with RHCE Synthesis**: Begin with comprehensive modules in `docs/rhce_synthesis/` for complete topic coverage
- **Use Anki flashcards** for spaced repetition and Ansible command memorization
- **Reference guides** in `docs/` directory for quick lookup during study
- **Practice with Lab Environment** using real RHEL 9 systems
- **Focus on hands-on** playbook development and automation scenarios

### Anki Flashcard Usage

The `anki/rhce_deck.csv` file contains essential Ansible concepts organized by tags:

- `ansible_basics` - Installation, configuration, inventory management
- `playbooks` - YAML syntax, task structure, playbook execution
- `variables` - Variable types, precedence, facts, templating
- `task_control` - Conditionals, loops, error handling, delegation
- `templates` - Jinja2 templating, filters, control structures
- `roles` - Role development, organization, dependencies
- `vault` - Ansible Vault, encryption, secure automation
- `modules` - Key modules for system configuration and management

## Key RHCE Command Categories

### Essential Ansible Operations

```bash
# Inventory and connectivity
ansible all -i inventory.ini -m ping
ansible-inventory --list --yaml
ansible-config list

# Playbook operations
ansible-playbook site.yml --check
ansible-playbook site.yml --syntax-check
ansible-playbook site.yml -v
ansible-playbook site.yml --ask-vault-pass
```

### Module Usage and Documentation

```bash
# Module documentation
ansible-doc yum
ansible-doc template
ansible-doc user

# Ad-hoc commands for testing
ansible webservers -m service -a "name=httpd state=started"
ansible all -m setup
ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

### Role Management

```bash
# Role operations
ansible-galaxy init my_role
ansible-galaxy install geerlingguy.apache
tree roles/my_role/

# Testing roles
ansible-playbook test.yml --tags "role_test"
```

### Vault Operations

```bash
# Vault management
ansible-vault create secrets.yml
ansible-vault edit secrets.yml
ansible-vault rekey secrets.yml
ansible-vault view secrets.yml

# Using vault in playbooks
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --vault-password-file .vault_pass
```

## Copyright Management Guidelines

**CRITICAL**: Claude Code must update `COPYRIGHT_NOTICE.md` whenever adding copyrighted content to the repository.

### When Adding New Copyrighted Materials

1. **Read COPYRIGHT_NOTICE.md first** to understand current copyright inventory
2. **Add new materials to `sources/` directory** (gitignored)
3. **Update COPYRIGHT_NOTICE.md** with:
   - Full title and author/publisher information
   - File path within `sources/` directory
   - License information (if known)
   - Source of the material
4. **Verify .gitignore excludes the new content**
5. **Never commit copyrighted content to git repository**

### Content Classification

- **Original Work**: Content created for this repository → `docs/` directory (tracked)
- **Copyrighted Materials**: Books, PDFs, documentation from external sources → `sources/` directory (not tracked)
- **Derived Content**: Analysis or summaries of copyrighted works → `sources/` directory (not tracked)

## Notes for Claude Code

- This repository focuses on RHCE exam preparation with emphasis on Ansible automation
- **Documentation Site**: The repository is published as a MkDocs site at <https://kraker.github.io/rhce/>
- When helping with study materials, emphasize practical playbook development and testing
- The study materials in `docs/` are original work and tracked in git
- External resources in `sources/` contain copyrighted materials and are not tracked
- Use hands-on lab practice with real RHEL 9 systems for effective learning
- Commands in the Anki flashcards represent real RHCE exam tasks and should be practiced in lab environments
- **MkDocs Development**: Use `mkdocs serve` for local development, `mkdocs build` for static generation
- **Markdownlint Configuration**: Uses `.markdownlintignore` to exclude files (CLAUDE.md, node_modules/, sources/, site/). See [markdownlint-cli documentation](https://github.com/igorshubovych/markdownlint-cli#ignoring-files) for ignore file patterns.
- **Always read CLAUDE.md, README.md, and COPYRIGHT_NOTICE.md before making changes**

## Development Principles

- **Minimal Dependencies**: Only include dependencies actually used in configuration files. Before adding any dependency to requirements.txt, verify it's referenced in mkdocs.yml or other config files. Remove unused dependencies to keep the project lean and maintainable.
- **Node.js Dependencies**: Use idiomatic npm workflow - run `npm install package-name --save-dev` to automatically create/update package.json rather than manually creating the file. This ensures proper dependency management and follows Node.js best practices.
- **Documentation Maintenance**: When making significant changes (features, reorganizations, refactors), always update project documentation (README.md, CLAUDE.md, and relevant docs/) to reflect the current state. Keep documentation in sync with actual project structure and capabilities. The main README.md should focus on project overview and development setup - detailed study content belongs in docs/ and specialized documentation (like vagrant/README.md) should remain focused on their specific domains.
- **Gitignore Management**: When adding new dependencies or tooling, always update .gitignore to exclude generated files, build artifacts, and dependency directories (e.g., node_modules/, *pycache*/, .env files). Review .gitignore patterns whenever introducing new technology stacks.

## Git Commit Style Guide

### Atomic Commit Principles

Following [Aleksandr Hovhannisyan's atomic git commits](https://www.aleksandrhovhannisyan.com/blog/atomic-git-commits/):

**Core Rule**: Each commit should represent "a single, complete unit of work" that can be independently reviewed and reverted.

### Commit Message Format

**Simple Changes** (content fixes, small updates):

```bash
git commit -m "Fix YAML syntax in template examples"
git commit -m "Update Anki flashcard for vault command syntax"
git commit -m "Add missing ansible-doc references"
```

**Feature Commits** (new capabilities, significant changes):

```bash
git commit -m "Add comprehensive role development section"
git commit -m "Implement advanced Jinja2 templating examples"
```

**Milestone/Release Commits** (major completions):

```bash
# Use detailed heredoc format for comprehensive changelog
git commit -m "$(cat <<'EOF'
Complete Ansible Vault module with comprehensive security practices

- Add advanced vault integration examples to Module 07
- Include step-by-step workflow for secure automation patterns
- Add 8 new vault-focused flashcards covering encryption scenarios
- Update quick reference with vault command variations
- Add practice playbooks demonstrating vault integration

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Guidelines

- **Present tense verbs**: "Fix", "Add", "Update", "Remove", "Implement"
- **Component focus**: Mention what study material/module is changed
- **Atomic scope**: One logical change per commit
- **No fear of many commits**: Better to have 5 focused commits than 1 mixed commit
- **Commit early and often**: Make commits as soon as a logical unit is complete

### Examples by Type

- **Content fixes**: `Fix variable precedence examples in Module 03`
- **Study material updates**: `Add comprehensive error handling patterns to playbook module`
- **Reference enhancements**: `Implement module cross-references in quick reference`
- **Documentation**: `Update README with current lab requirements`
- **Resource cleanup**: `Remove outdated automation examples in favor of RHEL 9 patterns`
- **Ansible practice**: `Add Jinja2 template examples to Module 05`
- **Lab environment**: `Fix SSH key distribution in Vagrant provisioning`
- **Flashcard updates**: `Add vault command variations to Anki deck`
- **Playbook examples**: `Implement multi-tier application deployment scenario`

## Study Workflow Recommendations

1. **Visit Documentation Site**: Browse <https://kraker.github.io/rhce/> for organized study materials
2. **Begin with RHCE Synthesis**: Start with `docs/rhce_synthesis/` for comprehensive topic coverage
3. **Use Anki deck** (`anki/rhce_deck.csv`) for Ansible command memorization and concept reinforcement
4. **Practice with Lab Environment** using real RHEL 9 systems and practical automation scenarios
5. **Verify all playbooks** with testing and validation commands
6. **Focus on practical application** rather than theoretical knowledge

## Essential Exam Preparation Commands

```bash
# Documentation and help (available during exam)
ansible-doc module_name
ansible-config list
ansible-inventory --list

# Testing and validation (critical for exam success)
ansible-playbook playbook.yml --check
ansible-playbook playbook.yml --syntax-check
ansible all -m setup --limit hostname

# Debugging (essential for troubleshooting)
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml --step
ansible-playbook playbook.yml --start-at-task "task name"

# Vault operations (security requirement)
ansible-vault create secrets.yml
ansible-vault edit secrets.yml
ansible-playbook playbook.yml --ask-vault-pass
```

## Dependency Management Guidelines

**Python Dependencies**: Always use the python virtual environment and manage project dependencies with the requirements.txt

**Ansible Dependencies**: Follow Jeff Geerling's best practices for project-local collections and roles:
- Ansible configuration files are located in the `vagrant/` directory for lab environment isolation
- Use `vagrant/requirements.yml` to specify Ansible collection and role dependencies
- Configure `vagrant/ansible.cfg` to use project-local paths (`collections_paths = collections`, `roles_path = roles`)
- Install dependencies with `cd vagrant && ansible-galaxy install -r requirements.yml`
- Collections are installed to `vagrant/collections/` and excluded from git via .gitignore
- Never install collections globally - keep them project-local for consistency and isolation
- This ensures reproducible builds, faster dependency scanning, and team consistency
- Reference: https://www.jeffgeerling.com/blog/2020/ansible-best-practices-using-project-local-collections-and-roles
