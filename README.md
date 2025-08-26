# RHCE Certification Study Repository

A comprehensive study repository for Red Hat Certified Engineer (RHCE) exam preparation, focusing on Ansible automation, configuration management, and system orchestration.

## Repository Contents

### 📚 Study Materials

#### 🌐 Online Documentation Site
- **GitHub Pages**: https://kraker.github.io/rhce/ (live documentation site)
- Built with MkDocs using the readthedocs theme
- Mobile-friendly and searchable interface

#### 📁 Local Files
- **`docs/`** - All study materials (MkDocs source)
  - `rhce_synthesis/` - 8 comprehensive study modules covering all RHCE exam objectives
  - `exam_quick_reference.md` - Essential Ansible commands and syntax for exam day
  - `ansible_module_reference.md` - Key modules with practical examples
  - `command_reference.md` - Commands organized by functional area
  - `rhce_glossary.md` - Comprehensive Ansible and automation terminology
- **`anki/rhce_deck.csv`** - Comprehensive flashcards for Anki import (Ansible-focused)

### 🏗️ Lab Environment
- **`vagrant/`** - Automated RHEL 9 lab with 5 VMs (1 control + 4 managed nodes)
  - `Vagrantfile` - Complete multi-VM configuration
  - `lab-up.sh` - Automated lab startup script
  - `playbook.yml` - Comprehensive provisioning automation
- **`ansible/practice/`** - Practice playbooks and automation exercises
- Supports complete RHCE practice with pre-configured Ansible environment
- Includes SSH key distribution, inventory setup, and service configuration

### 📖 External Resources (`sources/` directory, not tracked)
- Study book materials from leading RHCE authors (EPUBs converted to markdown)
- Official Red Hat documentation extracts
- Practice guides and reference materials

## Quick Start

### Using the Study Materials
1. **Visit the Documentation Site**: Browse https://kraker.github.io/rhce/ for organized study materials
2. **Start with Module 00**: Begin with [Exam Overview](docs/rhce_synthesis/00_exam_overview.md) to understand the exam format
3. **Follow the Study Path**: Work through the 8 comprehensive modules systematically
4. **Use Quick References**: Leverage the exam-focused reference materials

### Using the Anki Flashcards
1. Import `anki/rhce_deck.csv` into Anki
2. The deck focuses on Ansible concepts, modules, and automation patterns:
   - `ansible_basics`, `playbooks`, `variables`
   - `templates`, `roles`, `vault`
   - `modules`, `troubleshooting`, `exam_scenarios`

### Lab Environment Setup

#### Option 1: Automated Vagrant Lab (Recommended)
```bash
cd vagrant/
cp .rhel-credentials.template .rhel-credentials
# Edit .rhel-credentials with your Red Hat Developer account
./lab-up.sh  # Creates 5 VMs with complete Ansible setup
```

This creates:
- **control** (192.168.4.200) - Ansible control node with 2GB RAM
- **ansible1-4** (192.168.4.201-204) - Managed nodes with 1GB RAM each
- Pre-configured SSH keys, inventory, and host groups
- Automatic Red Hat subscription registration

#### Option 2: Manual Lab Setup
1. **Control Node**: RHEL 9 system with Ansible installed
2. **Managed Nodes**: 2-3 RHEL 9 systems for automation targets
3. **SSH Configuration**: Key-based authentication between nodes
4. **Network Access**: All systems can communicate via SSH

**Prerequisites**: 
- Vagrant + VirtualBox (for automated lab) OR RHEL 9 systems (manual)
- Red Hat Developer account (free at developers.redhat.com)
- SSH access and basic Linux administration knowledge
- RHCSA certification (required for RHCE exam)

#### Development Environment (Optional)
For playbook development and testing outside the lab:
```bash
pip install -r requirements.txt  # Installs Ansible, linting, and testing tools
```

## Study Workflow

### Phase 1: Foundation (Weeks 1-2)
- **Environment Setup**: Configure control and managed nodes
- **Basic Concepts**: Complete Modules 00-01 (Exam Overview, Ansible Basics)
- **Simple Automation**: Practice ad-hoc commands and basic playbooks
- **Daily Practice**: 1-2 hours of hands-on work

### Phase 2: Core Skills (Weeks 3-4)
- **Playbook Mastery**: Complete Modules 02-04 (Playbooks, Variables, Task Control)
- **Complex Logic**: Build playbooks with conditionals, loops, and error handling
- **Configuration Management**: Practice system configuration scenarios
- **Daily Practice**: 1-2 hours focused on playbook development

### Phase 3: Advanced Topics (Weeks 5-6)
- **Templates and Roles**: Complete Modules 05-06 (Templates, Roles)
- **Security**: Master Module 07 (Ansible Vault)
- **Advanced Features**: Complete Module 08 (Advanced Features)
- **Integration**: Build complete automation solutions
- **Daily Practice**: 1-2 hours on complex scenarios

### Phase 4: Exam Preparation (Week 7)
- **Intensive Practice**: Mock exam scenarios under time pressure
- **Quick Reference Review**: Master essential commands and syntax
- **Troubleshooting**: Focus on debugging and error resolution
- **Final Preparation**: Timed practice sessions
- **Daily Practice**: 2-3 hours of exam simulation

## Key RHCE Skills Areas

### Essential Ansible Automation
```bash
# Inventory and connection management
ansible all -i inventory.ini -m ping
ansible-inventory --list --yaml

# Playbook execution and testing
ansible-playbook site.yml --check
ansible-playbook site.yml --syntax-check
ansible-playbook site.yml -v
```

### Configuration Management
```yaml
# Template deployment example
- name: Deploy configuration file
  template:
    src: config.j2
    dest: /etc/myapp/config.conf
    backup: yes
  notify: restart service
```

### Role Development
```bash
# Role creation and structure
ansible-galaxy init my_role
tree roles/my_role/

# Role usage in playbooks
- hosts: webservers
  roles:
    - common
    - webserver
```

### Security with Ansible Vault
```bash
# Vault operations
ansible-vault create secrets.yml
ansible-vault edit secrets.yml
ansible-playbook site.yml --ask-vault-pass
```

## Repository Structure

```
rhce/
├── docs/                           # MkDocs documentation source
│   ├── index.md                    # Main site homepage
│   ├── rhce_synthesis/             # 8 comprehensive study modules
│   │   ├── 00_exam_overview.md     # Exam format and strategy
│   │   ├── 01_ansible_basics.md    # Foundation concepts
│   │   ├── 02_playbooks_tasks.md   # Playbook development
│   │   ├── 03_variables_facts.md   # Variables and system facts
│   │   ├── 04_task_control.md      # Conditionals and loops
│   │   ├── 05_templates.md         # Jinja2 templating
│   │   ├── 06_roles.md             # Role development
│   │   ├── 07_ansible_vault.md     # Security and secrets
│   │   ├── 08_advanced_features.md # Advanced automation
│   │   └── index.md                # Module overview and navigation
│   ├── exam_quick_reference.md     # Essential commands for exam day
│   ├── ansible_module_reference.md # Key modules with examples
│   ├── command_reference.md        # Commands by functional area
│   └── rhce_glossary.md           # Comprehensive terminology
├── anki/                          # Anki flashcard deck
│   └── rhce_deck.csv             # Ansible-focused flashcards
├── ansible/                       # Practice environment
│   └── practice/                 # Sample playbooks and exercises
├── vagrant/                       # Automated lab environment
│   ├── Vagrantfile               # 5-VM configuration
│   ├── playbook.yml              # Provisioning automation
│   ├── lab-up.sh                 # Lab startup script
│   ├── inventory                 # Static inventory for provisioning
│   ├── ansible.cfg               # Ansible configuration
│   └── files/                    # Supporting files (MOTD, etc.)
├── sources/                       # External study materials (gitignored)
│   ├── ansible_for_devops_jeff_geerling.md
│   ├── rhce_ex294_sander_van_vugt.md
│   ├── rhcsa_rhce_michael_jang.md
│   └── rhce_ansible_study_guide.txt
├── mkdocs.yml                    # Documentation site configuration
├── requirements.txt              # Python dependencies
├── README.md                     # This file
├── CLAUDE.md                     # AI assistant guidance
└── COPYRIGHT_NOTICE.md           # Copyright information
```

## Official RHCE Exam Objectives Coverage

This study guide comprehensively covers all **official Red Hat RHCE EX294 exam objectives**:

### Prerequisites
✅ **Be able to perform all tasks expected of a Red Hat Certified System Administrator**
- Understand and use essential tools, operate running systems, configure local storage
- Create and configure file systems, deploy and maintain systems
- Manage users and groups, manage security

### Core Ansible Competencies
✅ **Understand core components of Ansible**
- Inventories, modules, variables, facts, loops, conditional tasks, plays
- Handling task failure, playbooks, configuration files, roles
- Use provided documentation to look up specific information about Ansible modules and commands

✅ **Use roles and Ansible Content Collections**
- Create and work with roles, install roles and use them in playbooks
- Install Content Collections and use them in playbooks
- Obtain a set of related roles, supplementary modules, and other content from content collections

### Environment Configuration
✅ **Install and configure an Ansible control node**
- Install required packages, create a static host inventory file
- Create a configuration file, create and use static inventories to define groups of hosts

✅ **Configure Ansible managed nodes**
- Create and distribute SSH keys to managed nodes
- Configure privilege escalation on managed nodes, deploy files to managed nodes
- Be able to analyze simple shell scripts and convert them to playbooks

### Automation Content Navigator
✅ **Run playbooks with Automation content navigator**
- Know how to run playbooks with Automation content navigator
- Use Automation content navigator to find new modules in available Ansible Content Collections
- Use Automation content navigator to create inventories and configure the Ansible environment

### Playbook Development
✅ **Create Ansible plays and playbooks**
- Know how to work with commonly used Ansible modules
- Use variables to retrieve the results of running a command, use conditionals to control play execution
- Configure error handling, create playbooks to configure systems to a specified state

### RHCSA Task Automation
✅ **Automate standard RHCSA tasks using Ansible modules that work with:**
- Software packages and repositories, services, firewall rules
- File systems, storage devices, file content, archiving
- Task scheduling, security, users and groups

### Content Management
✅ **Manage content**
- Create and use templates to create customized configuration files  

## Contributing and Maintenance

This repository is maintained for personal RHCE study. Key principles:

- **Focus on Exam Relevance**: All content aligned with RHCE exam objectives
- **Hands-On Emphasis**: Every concept includes practical examples
- **Regular Updates**: Content updated for current Red Hat versions
- **Quality Assurance**: All playbooks and examples tested in lab environments

## Copyright and Attribution

This repository contains original study materials created for RHCE exam preparation. External resources from study books and Red Hat documentation are properly attributed and stored separately. See `COPYRIGHT_NOTICE.md` for detailed information.

---

**Ready to start your RHCE journey?** Visit the **[Documentation Site](https://kraker.github.io/rhce/)** or begin with **[Module 00: Exam Overview](docs/rhce_synthesis/00_exam_overview.md)**!

🚀 **Goal**: Master Ansible automation and earn your RHCE certification!
