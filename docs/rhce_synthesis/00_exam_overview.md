# Module 00: RHCE Exam Overview

## 🎯 Learning Objectives

By the end of this module, you will understand:

- The RHCE exam format and structure
- Required lab environment setup
- Effective study strategies and timeline
- Key success factors for exam day
- Common pitfalls and how to avoid them

## 📋 Exam Details

### RHCE EX294 Exam Specifications

**Exam Code**: EX294 - Red Hat Certified Engineer (RHCE)  
**Duration**: 4 hours  
**Format**: Performance-based, hands-on lab exam  
**Passing Score**: 210/300 (70%)  
**Prerequisites**: RHCSA certification required  

### Exam Environment

- **Control Node**: RHEL 9 system with Ansible pre-installed
- **Managed Nodes**: Multiple RHEL 9 systems for automation targets  
- **Network Access**: Systems can communicate via SSH
- **Documentation**: Access to man pages and `ansible-doc`
- **No Internet**: No access to external documentation or resources

### Key Constraints

⏰ **Time Pressure**: 4 hours for multiple complex tasks  
🚫 **No Internet**: Only local documentation available  
🔒 **No Preparation**: Cannot modify environment before exam starts  
📝 **Performance-Based**: Must demonstrate working solutions, not just knowledge  

## 🎯 Official RHCE Exam Objectives

The RHCE EX294 exam tests your ability to perform these **official Red Hat objectives**:

### Prerequisites

**Be able to perform all tasks expected of a Red Hat Certified System Administrator**

- Understand and use essential tools
- Operate running systems
- Configure local storage
- Create and configure file systems
- Deploy, configure, and maintain systems
- Manage users and groups
- Manage security

### 1. Understand core components of Ansible

- **Inventories** - Static and dynamic host management
- **Modules** - Using built-in and collection modules effectively
- **Variables** - Variable types, scoping, and precedence
- **Facts** - System information gathering and utilization
- **Loops** - Iterating over data structures
- **Conditional tasks** - When clauses and control flow
- **Plays** - Task organization and execution
- **Handling task failure** - Error handling and recovery
- **Playbooks** - Multi-play automation workflows
- **Configuration files** - ansible.cfg setup and management
- **Roles** - Reusable automation components
- **Use provided documentation** - ansible-doc command proficiency

### 2. Use roles and Ansible Content Collections

- **Create and work with roles** - Role structure and development
- **Install roles and use them in playbooks** - ansible-galaxy integration
- **Install Content Collections** - Modern Ansible content management
- **Use Content Collections in playbooks** - FQCN and collection integration
- **Obtain content from collections** - Related roles, modules, and supplementary content

### 3. Install and configure an Ansible control node

- **Install required packages** - Ansible installation and dependencies
- **Create a static host inventory file** - INI and YAML inventory formats
- **Create a configuration file** - ansible.cfg customization
- **Create and use static inventories** - Host groups and group variables

### 4. Configure Ansible managed nodes

- **Create and distribute SSH keys** - Passwordless authentication setup
- **Configure privilege escalation** - sudo/become configuration
- **Deploy files to managed nodes** - File transfer and management
- **Analyze shell scripts and convert to playbooks** - Legacy automation migration

### 5. Run playbooks with Automation content navigator

- **Run playbooks with navigator** - Modern Ansible execution interface
- **Find new modules in Content Collections** - Module discovery and usage
- **Create inventories with navigator** - Dynamic inventory management
- **Configure Ansible environment** - Environment setup and management

### 6. Create Ansible plays and playbooks

- **Work with commonly used modules** - Core module proficiency
- **Use variables for command results** - Register and variable manipulation
- **Use conditionals for execution control** - When statements and logic
- **Configure error handling** - Failed_when, ignore_errors, and handlers
- **Create playbooks for system state** - Desired state configuration

### 7. Automate standard RHCSA tasks using Ansible modules

- **Software packages and repositories** - dnf/yum, repository management
- **Services** - systemd service control and configuration
- **Firewall rules** - firewalld automation
- **File systems** - Filesystem creation and mounting
- **Storage devices** - Disk and volume management
- **File content** - File creation, modification, and management
- **Archiving** - Backup and archive operations
- **Task scheduling** - Cron job automation
- **Security** - SELinux, file permissions, and access controls
- **Users and groups** - Account management automation

### 8. Manage content

- **Create and use templates** - Jinja2 templating for configuration files
- **Template customization** - Variable substitution and logic

## 🛠️ Lab Environment Setup

### Minimum Requirements

**Control Node (ansible-controller)**:

- RHEL 9 with Ansible installed
- SSH client configured
- At least 2GB RAM, 20GB disk

**Managed Nodes (2-3 systems)**:

- RHEL 9 systems
- SSH server running
- Python 3 installed
- At least 1GB RAM, 10GB disk each

### Network Configuration

```bash
# Example network layout
Control Node:    192.168.1.10  (ansible-controller)
Managed Node 1:  192.168.1.11  (node1)
Managed Node 2:  192.168.1.12  (node2)
Managed Node 3:  192.168.1.13  (node3)
```

### SSH Key Setup

```bash
# Generate SSH key on control node
ssh-keygen -t rsa -b 2048

# Copy to all managed nodes
ssh-copy-id user@node1
ssh-copy-id user@node2
ssh-copy-id user@node3

# Test connectivity
ansible all -m ping
```

### Essential Ansible Installation

```bash
# Install Ansible on RHEL 9
sudo dnf install ansible-core

# Verify installation
ansible --version

# Install additional collections
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

## 📅 7-Week Study Plan

### Week 1: Foundation

**Goals**: Environment setup and basic concepts

- Set up lab environment with control and managed nodes
- Complete Module 01: Ansible Basics
- Practice ad-hoc commands and simple playbooks
- **Daily Practice**: 1-2 hours

### Week 2: Core Playbooks

**Goals**: Master playbook fundamentals  

- Complete Module 02: Playbooks & Tasks
- Build multi-task playbooks with error handling
- Practice with 20+ common modules
- **Daily Practice**: 1-2 hours

### Week 3: Variables and Control

**Goals**: Dynamic playbooks and logic

- Complete Module 03: Variables & Facts
- Complete Module 04: Task Control  
- Build complex conditional playbooks
- **Daily Practice**: 1-2 hours

### Week 4: Templates and Configuration

**Goals**: Configuration management mastery

- Complete Module 05: Templates
- Practice Jinja2 templating extensively
- Build complete configuration management playbooks
- **Daily Practice**: 1-2 hours

### Week 5: Roles and Organization

**Goals**: Code reusability and structure

- Complete Module 06: Roles
- Create custom roles for common tasks
- Practice role dependencies and organization
- **Daily Practice**: 1-2 hours

### Week 6: Security and Advanced Features

**Goals**: Security and troubleshooting

- Complete Module 07: Ansible Vault
- Complete Module 08: Advanced Features
- Practice vault integration and debugging
- **Daily Practice**: 1-2 hours

### Week 7: Exam Preparation

**Goals**: Exam readiness and confidence

- Daily practice with timed exercises
- Review all quick reference materials
- Mock exam scenarios under time pressure
- **Daily Practice**: 2-3 hours

## 🎯 Key Success Factors

### 1. Hands-On Practice First

❌ **Wrong Approach**: Reading documentation without practicing  
✅ **Right Approach**: Implement every example in your lab immediately

### 2. Master the Documentation

- Learn to use `ansible-doc module_name` efficiently
- Practice finding syntax without internet access
- Memorize locations of key information

### 3. Build Muscle Memory

- Practice common patterns until they're automatic
- Create personal cheat sheets for frequent tasks
- Type examples rather than copy-pasting

### 4. Time Management Skills

- Practice common tasks under time pressure
- Learn to prioritize high-value tasks first
- Develop troubleshooting workflows

### 5. Error Handling Expertise

- Master debugging failed playbooks quickly
- Learn common error patterns and solutions
- Practice systematic troubleshooting approaches

## ⚠️ Common Pitfalls to Avoid

### Time Management Mistakes

- Spending too much time on low-point tasks
- Not leaving time for testing and validation
- Getting stuck on debugging instead of moving forward

### Technical Mistakes

- YAML syntax errors (indentation, quotes)
- Incorrect variable precedence assumptions
- Not testing playbooks before considering them complete
- Forgetting to handle error conditions

### Exam Day Mistakes

- Not reading instructions carefully
- Making assumptions about the environment
- Not using available documentation effectively
- Panicking when encountering unexpected issues

## 🧠 Mental Preparation

### Build Confidence Through Practice

1. **Start Simple**: Master basic tasks before complex ones
2. **Practice Under Pressure**: Set timers for your practice sessions
3. **Learn from Failures**: Every error teaches you something valuable
4. **Build a Toolkit**: Develop go-to patterns for common scenarios

### Exam Day Mindset

- **Stay Calm**: Breathe and think through problems systematically
- **Read Carefully**: Understand exactly what's being asked
- **Test Everything**: Verify your solutions work completely
- **Move Forward**: Don't get stuck on any single problem

## 📖 Essential Commands to Memorize

```bash
# Documentation and help
ansible-doc module_name
ansible-config list
ansible-inventory --list

# Testing and validation  
ansible-playbook playbook.yml --check
ansible-playbook playbook.yml --syntax-check
ansible all -m setup

# Debugging
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml --step

# Vault operations
ansible-vault create secrets.yml
ansible-vault edit secrets.yml
ansible-playbook playbook.yml --ask-vault-pass
```

## 🔗 Next Steps

Now that you understand the exam format and requirements:

1. **Set up your lab environment** following the specifications above
2. **Create a study schedule** based on the 7-week plan
3. **Start with [Module 01: Ansible Basics](01_ansible_basics.md)** to build your foundation
4. **Practice daily** - consistency is key to success

Remember: The RHCE exam tests your ability to **do** Ansible automation, not just understand it. Focus on hands-on practice from day one!

---

**Next Module**: [Module 01: Ansible Basics](01_ansible_basics.md) →
