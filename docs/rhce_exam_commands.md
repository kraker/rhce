# RHCE Exam Day Commands

## 🎯 Essential Commands for EX294 Success

*Only the commands you'll actually type during the 4-hour exam*

### Critical Note

This is your exam day cheat sheet. Every command here is essential for RHCE exam success. These are the commands you'll type in the terminal - NOT the module parameters you'll write in playbooks.

---

## ⚡ Exam Workflow Commands

### Phase 1: Initial Verification (5 minutes)

```bash
# Test Ansible installation and connectivity
ansible --version                        # Verify Ansible is working
ansible-navigator --version              # Verify navigator is available
ansible all -m ping                      # Test connectivity to all hosts
ansible-inventory --list                 # View inventory structure
ansible-inventory --graph               # View inventory hierarchy
ansible-galaxy collection list          # Check available collections
```

### Phase 2: Documentation Lookup (Throughout Exam)

```bash
# Quick module reference (your primary resource)
ansible-doc -l | grep keyword           # Find modules quickly
ansible-doc -s module_name               # Get module syntax (fastest)
ansible-doc module_name                  # Full module documentation
ansible-doc module_name | grep -A 10 "EXAMPLES:"  # Get examples

# FQCN documentation
ansible-doc ansible.builtin.dnf
ansible-doc community.general.firewalld
ansible-doc ansible.posix.mount

# Plugin documentation
ansible-doc -t lookup file
ansible-doc -t filter default
ansible-doc -t test defined

# Navigator documentation
ansible-navigator doc module_name        # Interactive docs
ansible-navigator doc -l | grep keyword  # Search in navigator
ansible-navigator collections            # Browse collections
```

### Phase 3: Playbook Development & Testing (Main Phase)

```bash
# Syntax validation (ALWAYS do this first)
ansible-navigator run playbook.yml --syntax-check
ansible-navigator run playbook.yml --syntax-check --mode stdout

# Dry run validation (ALWAYS do before executing)
ansible-navigator run playbook.yml --check
ansible-navigator run playbook.yml --check --diff
ansible-navigator run playbook.yml --check --diff --mode stdout

# Playbook execution
ansible-navigator run playbook.yml                    # Interactive mode
ansible-navigator run playbook.yml --mode stdout      # Command-line output
ansible-navigator run playbook.yml --mode stdout -v   # With verbosity

# Target control
ansible-navigator run playbook.yml --limit webservers
ansible-navigator run playbook.yml --limit "web*"
ansible-navigator run playbook.yml --limit node1,node2

# Variable passing
ansible-navigator run playbook.yml -e "var=value"
ansible-navigator run playbook.yml -e "env=production debug=false"
ansible-navigator run playbook.yml -e "@vars.yml"

# Tag control
ansible-navigator run playbook.yml --tags "web,db"
ansible-navigator run playbook.yml --skip-tags "debug"
ansible-navigator run playbook.yml --list-tags

# Task control
ansible-navigator run playbook.yml --start-at-task "Install packages"
ansible-navigator run playbook.yml --step
ansible-navigator run playbook.yml --list-tasks

# Debugging levels
ansible-navigator run playbook.yml --mode stdout -v    # Basic
ansible-navigator run playbook.yml --mode stdout -vv   # More info
ansible-navigator run playbook.yml --mode stdout -vvv  # Full debug
```

### Phase 4: Ansible Vault Operations

```bash
# Create encrypted files
ansible-vault create secrets.yml
ansible-vault create group_vars/all/vault.yml

# Edit encrypted files
ansible-vault edit secrets.yml
ansible-vault edit group_vars/production/vault.yml

# View encrypted content
ansible-vault view secrets.yml

# Encrypt existing files
ansible-vault encrypt vars.yml
ansible-vault encrypt host_vars/*/vault.yml

# String encryption (for inline secrets)
ansible-vault encrypt_string 'secret_password' --name 'db_password'
echo 'secret_value' | ansible-vault encrypt_string --stdin-name 'var_name'

# Change passwords
ansible-vault rekey secrets.yml

# Playbook integration
ansible-navigator run site.yml --ask-vault-pass
ansible-navigator run site.yml --vault-password-file .vault_pass

# Set up vault password file
echo 'vault_password' > .vault_pass
chmod 600 .vault_pass
```

### Phase 5: Role & Collection Management

```bash
# Create roles
ansible-galaxy init role_name
ansible-galaxy init --init-path=./roles web_server

# Install collections
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install -r requirements.yml

# Install roles
ansible-galaxy role install geerlingguy.apache
ansible-galaxy role install -r requirements.yml

# Check installations
ansible-galaxy collection list
ansible-galaxy role list
```

### Phase 6: Final Validation (Last 15 minutes)

```bash
# Test connectivity
ansible all -m ping

# Verify services (common exam validation)
ansible webservers -m systemd -a "name=httpd" --become
ansible all -m uri -a "url=http://{{ ansible_default_ipv4.address }}"

# Check file existence
ansible all -m stat -a "path=/etc/httpd/conf/httpd.conf"

# Verify mounts
ansible all -m setup -a "filter=ansible_mounts"

# Quick fact checks
ansible all -m setup -a "filter=ansible_service_mgr"
ansible all -m setup -a "filter=ansible_distribution"
```

---

## 🔧 Configuration Commands

### Basic ansible.cfg Setup

```bash
# Check current configuration
ansible-config dump | grep -E '(INVENTORY|HOST_KEY|REMOTE_USER)'
ansible-config view

# Common configuration validation
ansible-config list | grep -i vault
ansible-config dump --only-changed
```

### Inventory Validation

```bash
# Inventory structure
ansible-inventory --list
ansible-inventory --list --yaml
ansible-inventory --graph
ansible-inventory --host hostname

# Host and group listing  
ansible all --list-hosts
ansible webservers --list-hosts
ansible 'web*' --list-hosts
```

---

## 🚀 Time-Saving Command Combinations

### Quick Validation Sequence

```bash
# Use for every playbook (copy-paste ready)
ansible-navigator run site.yml --syntax-check && \
ansible-navigator run site.yml --check && \
ansible-navigator run site.yml --mode stdout
```

### Emergency Troubleshooting

```bash
# When things go wrong
ansible all -m ping -vvv
ansible-config dump | grep -E '(INVENTORY|HOST_KEY)'
ansible-inventory --list
```

### Fast Documentation Lookup

```bash
# Speed up module discovery
alias adoc='ansible-doc'
alias adocs='ansible-doc -s'
adocs dnf    # Quick syntax
adoc user | grep -A 10 EXAMPLES:  # Quick examples
```

---

## 🎯 Exam Success Patterns

### The "Big 5" Exam Commands

**Master these - you'll use them constantly:**

1. **`ansible all -m ping`** - Always start here
2. **`ansible-navigator run playbook.yml --syntax-check`** - Before every execution  
3. **`ansible-navigator run playbook.yml --check --diff`** - Verify changes
4. **`ansible-navigator run playbook.yml --mode stdout -v`** - Execute with logging
5. **`ansible-doc -s module_name`** - Quick syntax lookup

### Command Frequency During Exam

- **Documentation commands**: 50-100 times
- **Syntax check**: 20-30 times  
- **Playbook execution**: 15-25 times
- **Vault operations**: 5-10 times
- **Inventory commands**: 5-10 times

### Critical Success Factors

1. **Speed with ansible-doc** - Practice until automatic
2. **Always validate first** - Syntax check, then dry run
3. **Use verbosity for debugging** - Start with -v, increase as needed
4. **Know your FQCN** - ansible.builtin.*, community.general.*
5. **Vault everything sensitive** - No plain text passwords/keys

---

## ⚠️ What NOT to Do on Exam

### Commands You WON'T Use

```bash
# Ad-hoc module commands (these go in PLAYBOOKS, not command line)
ansible all -m dnf -a "name=httpd state=present" --become  # ❌ WRONG
ansible all -m systemd -a "name=httpd state=started" --become  # ❌ WRONG  
ansible all -m user -a "name=webuser" --become  # ❌ WRONG

# System administration commands (not exam relevant)
ansible all -m setup --tree /tmp/facts  # ❌ WRONG
ssh -vvv ansible@hostname  # ❌ WRONG
strace ansible all -m ping  # ❌ WRONG
```

### Time Wasters

- Detailed system exploration commands
- Performance monitoring commands  
- Network troubleshooting commands
- SSH debugging commands

**Remember**: The exam is about writing PLAYBOOKS, not running ad-hoc commands for system administration!

---

**🏆 Exam Day Strategy**: Practice these commands until they're muscle memory. On exam day, you'll have no time to think about syntax - you need to execute immediately and focus your mental energy on the playbook logic, not the command syntax.
