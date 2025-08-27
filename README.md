# RHCE Certification Study Repository

A comprehensive study repository for Red Hat Certified Engineer (RHCE) exam preparation, focusing on Ansible automation, configuration management, and system orchestration.

## 📚 Documentation

**📖 Main Study Resource**: Visit the **[Documentation Site](https://kraker.github.io/rhce/)** for complete RHCE study materials including:

- 8 comprehensive study modules covering all exam objectives
- Quick reference guides and command cheat sheets  
- Glossary and terminology reference
- Practice exercises and examples

The documentation site is built with MkDocs and provides a mobile-friendly, searchable interface for all study materials.

## 🗂️ Repository Structure

- **`docs/`** - MkDocs source for the documentation site
- **`anki/`** - Anki flashcard deck for memorization practice
- **`vagrant/`** - Automated RHEL 9 lab environment (see [Lab Setup](vagrant/README.md))
- **`ansible/practice/`** - Practice playbooks and automation exercises
- **`sources/`** - External study materials (not tracked in git)

## 🔧 Development Setup

For contributors who want to build the documentation locally or contribute to the repository:

### Documentation Development

```bash
# Python dependencies (MkDocs, Ansible, linting tools)
pip install -r requirements.txt

# Node.js dependencies (markdownlint)
npm install

# Pre-commit hooks for code quality
pre-commit install

# Serve documentation locally
mkdocs serve
```

### Code Quality

The repository uses automated linting and formatting:

- **markdownlint** for documentation consistency
- **yamllint** for YAML formatting
- **ansible-lint** for playbook quality
- **pre-commit hooks** for automated checks

## 🏗️ Lab Environment  

For hands-on RHCE practice, this repository includes a complete Vagrant-based lab environment with 5 RHEL 9 VMs (1 control node + 4 managed nodes).

**Quick Start:**

```bash
cd vagrant/
cp .rhel-credentials.template .rhel-credentials
# Edit with your Red Hat Developer credentials
./lab.sh up
```

For complete lab setup instructions, system requirements, and troubleshooting, see the **[Lab Environment Documentation](vagrant/README.md)**.

## 📄 License & Attribution

This repository contains original study materials created for RHCE exam preparation. External resources are properly attributed and stored separately. See `COPYRIGHT_NOTICE.md` for detailed information.

---

**Ready to start your RHCE journey?** Visit the **[Documentation Site](https://kraker.github.io/rhce/)** to begin with the exam overview and study plan!

🚀 **Goal**: Master Ansible automation and earn your RHCE certification!
