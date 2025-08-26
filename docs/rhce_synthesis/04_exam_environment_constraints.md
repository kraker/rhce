# Module 04: Exam Environment & Constraints

## 🎯 Learning Objectives

By the end of this module, you will:
- Understand the RHCE exam environment and its limitations
- Master offline documentation usage with ansible-doc
- Know time management strategies for the 4-hour exam
- Understand how to work within provided inventory constraints
- Practice working without internet access or external references

## 📋 Why This Module Matters for Experienced Users

**The Reality:** You have internet access, documentation, and unlimited time in production.

**The Gap:** The exam is offline, timed, with limited documentation and provided inventory.

**The Impact:** Understanding constraints prevents 20-30% of exam failures due to poor time management or documentation dependence.

---

## ⏰ Exam Environment Overview

### Time Constraints

**Total Exam Time**: 4 hours (240 minutes)

**Realistic Breakdown**:
- **Setup & Orientation**: 15-20 minutes
- **Task Execution**: 180-200 minutes  
- **Final Validation**: 20-25 minutes

**Tasks Distribution** (typical):
- 15-20 individual automation tasks
- 3-5 complex multi-step scenarios
- 1-2 troubleshooting/debugging challenges

### Environment Limitations

| Resource | Production | Exam Environment |
|----------|------------|------------------|
| **Internet Access** | Available | ❌ None |
| **External Documentation** | Unlimited | ❌ None |
| **Reference Materials** | Full access | ❌ ansible-doc only |
| **Time** | Unlimited | ⏰ 4 hours strict |
| **Systems** | Your choice | 📋 Pre-configured |
| **Software Versions** | Latest | 📌 RHEL 9 specific |

---

## 🖥️ Physical Exam Environment

### System Configuration

**Control Node**:
- RHEL 9 with Ansible installed
- `ansible-core` package (not full Ansible)
- Essential collections pre-installed
- Text editors: vim, nano
- No GUI access

**Managed Nodes**:
- 3-5 RHEL 9 systems
- Pre-configured with SSH access
- Predefined hostnames and groups
- Limited to exam requirements

### Network Setup

```ini
# Typical exam inventory structure
[control]
control.example.com

[web]
web1.example.com
web2.example.com

[database]
db1.example.com

[development]
dev1.example.com
dev2.example.com

[production:children]
web
database

[all:vars]
ansible_user=student
ansible_ssh_private_key_file=/home/student/.ssh/id_rsa
```

### Available Software

**Pre-installed on Control Node**:
- `ansible-core` (latest RHEL 9 version)
- `ansible-navigator` (exam-preferred tool)
- Essential collections
- Standard Linux utilities
- Text editors (vi/vim, nano)

**NOT Available**:
- Full Ansible package
- Additional Python modules
- Development tools
- External package repositories

---

## 📚 Documentation Constraints

### Available Documentation

**Only Available Resource**: `ansible-doc`

```bash
# Module documentation
ansible-doc dnf
ansible-doc systemd
ansible-doc template

# List all modules
ansible-doc -l

# Module synopsis (short form)
ansible-doc -s user

# Plugin documentation
ansible-doc -t lookup file
ansible-doc -t filter dict2items
```

**Using ansible-navigator for docs**:

```bash
# Interactive documentation browsing
ansible-navigator doc
ansible-navigator doc ansible.builtin.dnf
ansible-navigator collections
```

### Documentation Strategy

**Pre-Exam Preparation**:
1. **Memorize key module parameters** for frequently used modules
2. **Practice ansible-doc navigation** until it's fast
3. **Know module relationships** (which modules work together)
4. **Understand FQCN patterns** for collections

**During Exam**:
1. **Quick syntax check**: `ansible-doc -s module_name`
2. **Full examples**: `ansible-doc module_name` 
3. **Parameter verification**: Look for required vs optional parameters
4. **Copy-paste examples**: Use documentation examples as templates

---

## 🎯 Time Management Strategies

### Time Allocation Framework

**Phase 1: Setup & Inventory (15 minutes)**
```bash
# Verify Ansible installation
ansible --version
ansible-navigator --version

# Test connectivity
ansible all -m ping

# Examine inventory structure
ansible-inventory --list
ansible-inventory --graph

# Check available collections
ansible-galaxy collection list
```

**Phase 2: Task Execution (200 minutes)**

**Simple Tasks** (5-10 minutes each):
- Package installation
- Service management
- User creation
- Basic file operations

**Complex Tasks** (15-25 minutes each):
- Storage configuration with LVM
- Multi-service deployments
- Role-based configurations
- Template deployments

**Troubleshooting Tasks** (10-20 minutes each):
- Debug failed playbooks
- Fix configuration errors
- Resolve permission issues

**Phase 3: Validation (25 minutes)**
```bash
# Final verification commands
ansible-playbook site.yml --check
ansible all -m setup --limit hostname
systemctl status service_name
```

### Time-Saving Techniques

**Efficient Development Patterns**:

1. **Start with check mode**:
   ```bash
   ansible-navigator run playbook.yml --check --mode stdout
   ```

2. **Test incrementally**:
   ```bash
   # Test single task
   ansible-navigator run playbook.yml --start-at-task "Install packages" --mode stdout
   
   # Test specific hosts
   ansible-navigator run playbook.yml --limit webservers --mode stdout
   ```

3. **Use verbose output for debugging**:
   ```bash
   ansible-navigator run playbook.yml --mode stdout -v
   ```

4. **Quick syntax validation**:
   ```bash
   ansible-navigator run playbook.yml --syntax-check
   ```

---

## 📋 Working with Provided Inventory

### Understanding Exam Inventory

**Typical Structure**:
```ini
# /etc/ansible/hosts or inventory.ini
[web_servers]
web1.example.com ansible_host=192.168.1.10
web2.example.com ansible_host=192.168.1.11

[db_servers]
db1.example.com ansible_host=192.168.1.20

[app_servers]
app1.example.com ansible_host=192.168.1.30
app2.example.com ansible_host=192.168.1.31

[production:children]
web_servers
db_servers

[staging:children]
app_servers

[all:vars]
ansible_user=student
ansible_become=true
ansible_ssh_private_key_file=/home/student/.ssh/id_rsa
```

### Inventory Exploration Commands

```bash
# List all hosts
ansible-inventory --list --yaml

# Show host variables
ansible-inventory --host web1.example.com

# Display inventory graph
ansible-inventory --graph

# Test group targeting
ansible web_servers -m ping
ansible production -m ping
ansible all -m ping
```

### Inventory Constraints

**You CANNOT**:
- Modify the provided inventory
- Add or remove hosts
- Change group memberships
- Modify SSH configuration

**You CAN**:
- Use group variables in playbooks
- Target specific groups
- Use host-specific variables
- Create additional variable files

---

## 🔧 ansible.cfg Configuration

### Exam Environment Configuration

**Typical exam ansible.cfg**:
```ini
[defaults]
inventory = /home/student/inventory
remote_user = student
private_key_file = /home/student/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
collections_path = /usr/share/ansible/collections

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

**Key Settings for Exam**:
- **inventory**: Points to provided inventory file
- **remote_user**: Predefined user account
- **host_key_checking**: Disabled for speed
- **become settings**: Configured for privilege escalation

### Configuration Verification

```bash
# View current configuration
ansible-config view

# Dump all configuration
ansible-config dump

# List configuration files in precedence order
ansible-config list
```

---

## 🚫 Offline Work Strategies

### Working Without Internet

**Documentation Workflow**:
1. **Use ansible-doc extensively** - it's your only reference
2. **Memorize common module parameters** beforehand
3. **Practice syntax patterns** until they're muscle memory
4. **Know error message patterns** for quick debugging

**Common Module Quick Reference** (memorize these):

```yaml
# Package management
ansible.builtin.dnf:
  name: package_name
  state: present|absent|latest

# Service management
ansible.builtin.systemd:
  name: service_name
  state: started|stopped|restarted
  enabled: true|false

# User management
ansible.builtin.user:
  name: username
  groups: group_list
  shell: /bin/bash
  password: "{{ 'password' | password_hash('sha512') }}"

# File operations
ansible.builtin.copy:
  src: source_file
  dest: /path/to/destination
  mode: '0644'
  owner: username
  group: groupname
```

### Error Resolution Without Internet

**Common Error Patterns**:

1. **Module not found**:
   ```bash
   # Check available modules
   ansible-doc -l | grep module_name
   
   # Verify collection installation
   ansible-galaxy collection list
   ```

2. **Connection failures**:
   ```bash
   # Test basic connectivity
   ansible all -m ping
   
   # Debug connection issues
   ansible all -m ping -vvv
   ```

3. **Permission denied**:
   ```bash
   # Verify become configuration
   ansible-config dump | grep -i become
   
   # Test with explicit become
   ansible all -m ping -b
   ```

4. **YAML syntax errors**:
   ```bash
   # Check playbook syntax
   ansible-navigator run playbook.yml --syntax-check
   
   # Use YAML validator
   python3 -c "import yaml; yaml.safe_load(open('playbook.yml'))"
   ```

---

## ⚡ Speed Optimization Techniques

### Fast Development Workflow

**1. Template-Based Development**:

```yaml
# Keep a basic template ready
---
- name: Task template
  hosts: TARGET_GROUP
  become: true
  
  tasks:
    - name: Task description
      MODULE_NAME:
        parameter: value
        state: present
```

**2. Copy-Paste from ansible-doc**:

```bash
# Get example quickly
ansible-doc -s dnf | head -20

# Get full examples
ansible-doc dnf | grep -A 20 "EXAMPLES"
```

**3. Incremental Testing**:

```bash
# Test single task first
ansible TARGET_GROUP -m MODULE_NAME -a "parameter=value"

# Then convert to playbook
```

### Common Task Patterns

**Package + Service Pattern**:
```yaml
- name: Install and start service
  hosts: webservers
  become: true
  tasks:
    - name: Install package
      ansible.builtin.dnf:
        name: httpd
        state: present
    
    - name: Start service
      ansible.builtin.systemd:
        name: httpd
        state: started
        enabled: true
```

**Storage Configuration Pattern**:
```yaml
- name: Configure storage
  hosts: storage_servers
  become: true
  tasks:
    - name: Create partition
      community.general.parted:
        device: /dev/vdb
        number: 1
        part_end: 5GiB
        state: present
    
    - name: Create filesystem
      community.general.filesystem:
        fstype: ext4
        dev: /dev/vdb1
    
    - name: Mount filesystem
      ansible.posix.mount:
        path: /mnt/data
        src: /dev/vdb1
        fstype: ext4
        state: mounted
```

---

## 🎯 Exam Day Strategies

### Pre-Exam Checklist

**1 Week Before**:
- [ ] Practice offline documentation usage
- [ ] Memorize key module parameters
- [ ] Time yourself on practice scenarios
- [ ] Review FQCN syntax patterns

**1 Day Before**:
- [ ] Review quick reference materials
- [ ] Practice ansible-navigator usage
- [ ] Get familiar with exam environment setup
- [ ] Rest well - avoid cramming

### Exam Execution Strategy

**First 15 Minutes**:
1. **Read all tasks** before starting any
2. **Identify dependencies** between tasks
3. **Note time estimates** for each task
4. **Plan task execution order**

**During Execution**:
1. **Start with familiar tasks** to build confidence
2. **Use check mode** to validate before execution
3. **Test incrementally** - don't wait until the end
4. **Skip stuck tasks** and return later
5. **Document issues** for later troubleshooting

**Final 30 Minutes**:
1. **Run full validation** on all playbooks
2. **Check service status** on all managed nodes
3. **Verify file permissions** and ownership
4. **Test any custom configurations**

### Common Time Traps to Avoid

**❌ Time Wasters**:
- Spending too long on one difficult task
- Not using check mode before execution
- Re-reading documentation multiple times
- Perfectionism on non-critical details
- Not testing connectivity early

**✅ Time Savers**:
- Using templates and copy-paste from docs
- Starting with simple tasks for momentum
- Using incremental testing approach
- Focusing on working solutions over perfect code
- Moving on from stuck tasks

---

## 🧪 Practice Scenarios for Constraints

### Offline Documentation Practice

**Exercise**: Complete these tasks using only ansible-doc:

1. **Find the correct syntax** for creating a logical volume
2. **Determine required parameters** for firewall module
3. **Look up template module** examples
4. **Find SELinux boolean** module usage

```bash
# Practice these commands until they're fast
ansible-doc -l | grep -i volume
ansible-doc -s community.general.lvol
ansible-doc community.general.lvol
ansible-doc -l | grep -i firewall
ansible-doc ansible.posix.firewalld
```

### Time Management Practice

**4-Hour Simulation**:
1. **Set up timer** for 240 minutes
2. **Complete 3-4 scenarios** from exam scenarios module
3. **Track time per task** and identify bottlenecks
4. **Practice final validation** procedures

### Inventory Constraint Practice

**Exercise**: Work with this constrained inventory:

```ini
# You cannot modify this inventory
[webservers]
web1.lab.example.com
web2.lab.example.com

[databases]
db1.lab.example.com

[all:vars]
ansible_user=student
ansible_ssh_private_key_file=/home/student/.ssh/lab_rsa
```

**Tasks**:
1. Deploy web application to webservers only
2. Configure database on database server only  
3. Set up monitoring on all systems
4. Create users with different privileges per group

---

## 🎯 Key Takeaways for Experienced Users

1. **Time pressure changes everything** - Practice under time constraints
2. **Offline documentation mastery** - ansible-doc becomes your lifeline
3. **Incremental testing is crucial** - Don't wait to validate
4. **Inventory constraints are fixed** - Work within provided structure
5. **Speed over perfection** - Working solution beats elegant solution

### Essential Exam Commands (Memorize)

```bash
# Quick connectivity test
ansible all -m ping

# Syntax validation
ansible-navigator run playbook.yml --syntax-check

# Check mode (dry run)
ansible-navigator run playbook.yml --check --mode stdout

# Execute with output
ansible-navigator run playbook.yml --mode stdout

# Debug with verbosity
ansible-navigator run playbook.yml --mode stdout -v

# Quick module lookup
ansible-doc -s module_name

# Full module documentation
ansible-doc module_name
```

### Mental Framework for Exam Success

**Time Management**: "If I'm stuck for more than 10 minutes, move on"

**Documentation**: "ansible-doc is my internet - use it constantly"  

**Testing**: "Test early, test often, test incrementally"

**Validation**: "Save 30 minutes at the end for complete testing"

**Confidence**: "I know Ansible - the exam is just Ansible under pressure"

Master these constraints in practice, and the exam environment becomes just another day at the office!