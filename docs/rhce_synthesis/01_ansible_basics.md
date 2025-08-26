# Module 01: Ansible Basics

## 🎯 Learning Objectives

By the end of this module, you will:
- Understand Ansible architecture and core concepts
- Install and configure Ansible on the control node
- Create and manage inventory files effectively
- Execute ad-hoc commands for system management
- Configure SSH authentication and privilege escalation
- Understand Ansible's connection methods and security model

## 📋 Why Ansible for Red Hat Automation

### Ansible Philosophy

**Agentless Architecture**: No software installation required on managed nodes
**Idempotent Operations**: Safe to run multiple times, only makes necessary changes
**Declarative Syntax**: Describe desired state, not step-by-step procedures
**Human Readable**: YAML syntax that's easy to read and maintain

### Key Benefits for System Administrators

- **Consistency**: Eliminate configuration drift across systems
- **Scalability**: Manage hundreds of systems as easily as one
- **Auditability**: Track all changes through version control
- **Reliability**: Built-in error handling and rollback capabilities

---

## 🏗️ Ansible Architecture

### Control Node Requirements

**Supported Operating Systems**:
- RHEL 8/9 (exam environment)
- CentOS Stream 8/9
- Fedora (recent versions)
- Ubuntu LTS versions

**Python Requirements**:
- Python 3.8 or newer
- pip for module installation

**Software Requirements**:
- SSH client
- ansible-core package

### Managed Node Requirements

**Minimal Requirements**:
- SSH server running
- Python 3.6 or newer
- User account with appropriate privileges

**No Agent Required**: Ansible connects via SSH and executes tasks remotely

### Communication Flow

```
┌─────────────────┐    SSH     ┌─────────────────┐
│   Control Node  │─────────→  │  Managed Node   │
│   (Ansible)     │            │   (Target)      │
└─────────────────┘            └─────────────────┘
       │                              │
       ├── Playbooks                  ├── Python modules
       ├── Inventory                  ├── Fact gathering
       ├── Configuration              └── Task execution
       └── Modules
```

---

## 🔧 Installation and Configuration

### Installing Ansible on RHEL 9

```bash
# Enable required repositories
sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms

# Install ansible-core
sudo dnf install ansible-core

# Verify installation
ansible --version
ansible-config --version

# Install additional collections
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

### Alternative Installation Methods

```bash
# Install via pip (if needed)
pip3 install ansible-core

# Install from source (development)
git clone https://github.com/ansible/ansible.git
cd ansible
source ./hacking/env-setup
```

### Ansible Configuration File

**Configuration Hierarchy** (highest to lowest precedence):
1. `ANSIBLE_CONFIG` environment variable
2. `ansible.cfg` in current directory
3. `~/.ansible.cfg` in user home directory
4. `/etc/ansible/ansible.cfg` system-wide

**Essential Configuration** (`ansible.cfg`):

```ini
[defaults]
# Inventory file location
inventory = inventory.ini

# Default user for connections
remote_user = ansible

# Disable host key checking for lab environments
host_key_checking = False

# Enable privilege escalation by default
become = True
become_method = sudo

# Role and collection paths
roles_path = ./roles
collections_paths = ./collections

# Connection settings
timeout = 30
forks = 5

# Logging
log_path = ./ansible.log

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
control_path_dir = /tmp/.ansible-cp
```

### Validating Configuration

```bash
# List all configuration settings
ansible-config list

# View current configuration values
ansible-config view

# Dump all configuration (active settings)
ansible-config dump
```

---

## 📋 Inventory Management

### Static Inventory Formats

**INI Format** (`inventory.ini`):

```ini
# Individual hosts
web01.example.com
web02.example.com ansible_host=192.168.1.10

# Groups
[webservers]
web01.example.com
web02.example.com

[databases]
db01.example.com
db02.example.com ansible_host=192.168.1.20

# Group of groups
[production:children]
webservers
databases

# Group variables
[webservers:vars]
http_port=80
max_clients=200

[databases:vars]
mysql_port=3306
mysql_datadir=/var/lib/mysql

# Global variables
[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

**YAML Format** (`inventory.yml`):

```yaml
all:
  children:
    production:
      children:
        webservers:
          hosts:
            web01.example.com:
            web02.example.com:
              ansible_host: 192.168.1.10
          vars:
            http_port: 80
            max_clients: 200
        databases:
          hosts:
            db01.example.com:
            db02.example.com:
              ansible_host: 192.168.1.20
          vars:
            mysql_port: 3306
            mysql_datadir: /var/lib/mysql
  vars:
    ansible_user: ansible
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Host Patterns

**Basic Patterns**:
```bash
# All hosts
ansible all -m ping

# Single host
ansible web01.example.com -m ping

# Group
ansible webservers -m ping

# Multiple groups
ansible webservers:databases -m ping

# Exclusions
ansible webservers:!web01.example.com -m ping

# Intersections
ansible webservers:&production -m ping

# Regular expressions
ansible ~web\d+ -m ping
```

### Inventory Variables

**Host Variables** (`host_vars/hostname.yml`):
```yaml
# host_vars/web01.example.com.yml
---
max_clients: 150
custom_config: true
ssl_enabled: yes
```

**Group Variables** (`group_vars/groupname.yml`):
```yaml
# group_vars/webservers.yml
---
http_port: 80
document_root: /var/www/html
package_name: httpd

# group_vars/production.yml
---
environment: production
backup_enabled: true
monitoring_enabled: true
```

### Inventory Validation

```bash
# List all hosts
ansible-inventory --list

# List hosts in YAML format
ansible-inventory --list --yaml

# Show specific host details
ansible-inventory --host web01.example.com

# Graphical representation
ansible-inventory --graph

# Validate inventory syntax
ansible-inventory --list > /dev/null
```

---

## 🔑 SSH Configuration and Authentication

### SSH Key Generation and Distribution

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

# Copy public key to managed nodes
ssh-copy-id ansible@web01.example.com
ssh-copy-id ansible@web02.example.com
ssh-copy-id ansible@db01.example.com

# Alternative: Manual key copying
cat ~/.ssh/id_rsa.pub | ssh ansible@web01.example.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### SSH Client Configuration

**SSH Config** (`~/.ssh/config`):
```
Host web01.example.com
    User ansible
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no

Host 192.168.1.*
    User ansible
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

### Testing Connectivity

```bash
# Test SSH connectivity manually
ssh ansible@web01.example.com "echo 'SSH connection successful'"

# Test Ansible connectivity
ansible all -m ping

# Test with specific user
ansible all -m ping -u ansible

# Test with different SSH key
ansible all -m ping --private-key ~/.ssh/alternate_key
```

### Privilege Escalation Configuration

**Sudo Configuration** (on managed nodes):
```bash
# Add ansible user to sudoers
echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible

# Validate sudoers configuration
sudo visudo -c
```

**Ansible Configuration**:
```bash
# Test privilege escalation
ansible all -m shell -a "whoami" --become

# Test without password prompt
ansible all -m shell -a "whoami" --become --ask-become-pass
```

---

## ⚡ Ad-hoc Commands

### Command Structure

**Basic Syntax**:
```bash
ansible <pattern> -m <module> -a "<module_arguments>" [options]
```

### Essential Ad-hoc Command Patterns

**System Information**:
```bash
# Basic connectivity test
ansible all -m ping

# Gather system facts
ansible all -m setup

# Get specific facts
ansible all -m setup -a "filter=ansible_distribution*"

# Check uptime
ansible all -m command -a "uptime"

# Check disk space
ansible all -m shell -a "df -h"

# View memory usage
ansible all -m shell -a "free -m"
```

**Package Management**:
```bash
# Install packages
ansible all -m dnf -a "name=httpd state=present" --become

# Install multiple packages
ansible all -m dnf -a "name=['httpd','mysql','php'] state=present" --become

# Update all packages
ansible all -m dnf -a "name='*' state=latest" --become

# Remove packages
ansible all -m dnf -a "name=httpd state=absent" --become
```

**Service Management**:
```bash
# Start services
ansible all -m systemd -a "name=httpd state=started" --become

# Enable and start services
ansible all -m systemd -a "name=httpd state=started enabled=yes" --become

# Restart services
ansible all -m systemd -a "name=httpd state=restarted" --become

# Check service status
ansible all -m systemd -a "name=httpd" --become
```

**File Operations**:
```bash
# Copy files to managed nodes
ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts" --become

# Create directories
ansible all -m file -a "path=/tmp/testdir state=directory mode=0755" --become

# Change file permissions
ansible all -m file -a "path=/tmp/testfile mode=0644 owner=root group=root" --become

# Create symbolic links
ansible all -m file -a "src=/tmp/source dest=/tmp/link state=link" --become

# Remove files
ansible all -m file -a "path=/tmp/testfile state=absent" --become
```

**User Management**:
```bash
# Create users
ansible all -m user -a "name=testuser groups=wheel shell=/bin/bash" --become

# Set user passwords (with encrypted password)
ansible all -m user -a "name=testuser password=$6$rounds=..." --become

# Remove users
ansible all -m user -a "name=testuser state=absent remove=yes" --become
```

### Command Options

**Common Options**:
```bash
--become (-b)           # Enable privilege escalation
--become-user USER      # Escalate to specific user
--become-method METHOD  # Escalation method (sudo, su, etc.)
--ask-become-pass (-K)  # Prompt for escalation password
--check (-C)            # Dry run mode
--diff (-D)             # Show file changes
--limit SUBSET          # Limit to subset of hosts
--user (-u) USER        # Connect as specific user
--private-key FILE      # Use specific SSH private key
--ask-pass (-k)         # Prompt for SSH password
--inventory (-i) FILE   # Use specific inventory
--extra-vars (-e) VARS  # Set additional variables
--verbose (-v)          # Increase verbosity
```

**Examples with Options**:
```bash
# Dry run with diff output
ansible webservers -m copy -a "src=index.html dest=/var/www/html/" --check --diff --become

# Limit to specific hosts
ansible all -m shell -a "hostname" --limit "web01.example.com,web02.example.com"

# Use different user and key
ansible all -m ping -u root --private-key ~/.ssh/root_key

# Extra verbosity for debugging
ansible all -m setup --limit web01.example.com -vvv
```

---

## 🔍 Understanding Ansible Modules

### Module Categories

**Core System Modules**:
- `ansible.builtin.command` - Execute commands
- `ansible.builtin.shell` - Execute shell commands
- `ansible.builtin.script` - Execute scripts
- `ansible.builtin.raw` - Execute raw SSH commands

**Package Management**:
- `ansible.builtin.dnf` - DNF/YUM package manager
- `ansible.builtin.package` - Generic package manager
- `ansible.builtin.rpm_key` - RPM key management

**Service Management**:
- `ansible.builtin.systemd` - Systemd service management
- `ansible.builtin.service` - Generic service management

**File Operations**:
- `ansible.builtin.copy` - Copy files
- `ansible.builtin.file` - File/directory management
- `ansible.builtin.template` - Jinja2 templating
- `ansible.builtin.lineinfile` - Line-in-file editing
- `ansible.builtin.replace` - File content replacement

### Module Documentation

```bash
# List all available modules
ansible-doc -l

# Get module documentation
ansible-doc dnf
ansible-doc systemd
ansible-doc copy

# Get module syntax only
ansible-doc -s dnf

# Search modules
ansible-doc -l | grep firewall

# Get module examples
ansible-doc dnf | grep -A 20 EXAMPLES
```

### Command vs Shell vs Raw Modules

**command module** (default, secure):
```bash
# Cannot use pipes, redirects, or shell variables
ansible all -m command -a "ls -l /tmp"
```

**shell module** (allows shell features):
```bash
# Can use pipes, redirects, and shell variables
ansible all -m shell -a "ps aux | grep httpd"
ansible all -m shell -a "echo $HOME"
```

**raw module** (minimal processing):
```bash
# Bypasses module system entirely
ansible all -m raw -a "uptime"
```

---

## 🧪 Practical Lab Exercises

### Exercise 1: Control Node Setup

1. **Install Ansible on control node**
2. **Create basic ansible.cfg configuration**
3. **Test installation with version commands**

### Exercise 2: SSH Authentication Setup

1. **Generate SSH key pair**
2. **Distribute keys to managed nodes**
3. **Configure SSH client for automation**
4. **Test password-less authentication**

### Exercise 3: Inventory Creation

1. **Create INI format inventory with groups**
2. **Create YAML format inventory**
3. **Add host and group variables**
4. **Validate inventory structure**

### Exercise 4: Ad-hoc Command Practice

1. **Test connectivity with ping module**
2. **Gather facts from all nodes**
3. **Install and manage packages**
4. **Control services across nodes**
5. **Perform file operations**

### Exercise 5: Module Exploration

1. **Use ansible-doc to explore modules**
2. **Test different command modules**
3. **Practice with various module options**
4. **Compare module behaviors**

---

## 🎯 Key Takeaways

### Architecture Understanding
- **Agentless**: No software required on managed nodes
- **SSH-based**: Secure communication using existing SSH infrastructure
- **Python execution**: Modules run Python code on managed nodes
- **Idempotent**: Safe to run repeatedly

### Configuration Mastery
- **ansible.cfg precedence**: Know where Ansible looks for configuration
- **Essential settings**: remote_user, host_key_checking, become settings
- **Inventory formats**: Both INI and YAML, choose based on complexity
- **Variable organization**: Use host_vars and group_vars directories

### Ad-hoc Command Proficiency
- **Module selection**: Choose appropriate modules for tasks
- **Option usage**: Master common options like --become, --check, --limit
- **Pattern matching**: Use flexible host patterns for targeting
- **Documentation**: Use ansible-doc for quick reference

### Best Practices
- **Start simple**: Master basic concepts before advanced features
- **Test first**: Use ping and check mode to validate before execution
- **Document decisions**: Use clear naming and organization
- **Security focus**: Proper SSH key management and privilege escalation

---

## 🔗 Next Steps

You now have the foundation for Ansible automation. Next, you'll learn to:

1. **[Module 02: Playbooks & Tasks](02_playbooks_tasks.md)** - Structure automation with playbooks
2. **Create repeatable automation** with YAML playbooks
3. **Organize complex tasks** with proper structure and error handling
4. **Scale beyond ad-hoc commands** to comprehensive automation workflows

The fundamentals you've learned here will support everything else you do with Ansible!

---

**Next Module**: [Module 02: Playbooks & Tasks](02_playbooks_tasks.md) →