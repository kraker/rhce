# Module 02: Content Collections & Galaxy

## 🎯 Learning Objectives

By the end of this module, you will:
- Understand Ansible Content Collections and their structure
- Master FQCN (Fully Qualified Collection Name) requirements
- Install and manage collections using ansible-galaxy
- Know which collections are critical for the RHCE exam
- Navigate collection documentation effectively

## 📋 Why This Module Matters for Experienced Users

**The Reality:** You probably use short module names (`dnf`, `firewalld`) in production.

**The Gap:** The exam may require FQCN usage and expects familiarity with specific collections.

**The Impact:** Understanding collections and FQCN can prevent 10-15% of exam mistakes.

---

## 📦 Understanding Ansible Content Collections

### What are Collections?

Collections are a distribution format for Ansible content that includes:
- **Modules** - Task execution units
- **Plugins** - Extend Ansible functionality  
- **Roles** - Reusable automation components
- **Playbooks** - Complete automation scenarios
- **Documentation** - Usage examples and guides

### Collection Structure

```
namespace.collection_name/
├── plugins/
│   ├── modules/
│   ├── inventory/
│   ├── lookup/
│   └── filter/
├── roles/
├── playbooks/
├── docs/
└── meta/
    └── runtime.yml
```

### Collection Namespaces

| Namespace | Purpose | Maintenance |
|-----------|---------|-------------|
| `ansible.builtin` | Core Ansible modules | Red Hat/Ansible Team |
| `ansible.posix` | POSIX system modules | Red Hat/Ansible Team |
| `community.general` | General community modules | Community maintained |
| `community.crypto` | Cryptographic modules | Community maintained |
| `containers.podman` | Container management | Community maintained |

---

## 🎯 FQCN (Fully Qualified Collection Names)

### Understanding FQCN

**FQCN Format**: `namespace.collection_name.module_name`

**Examples**:
- `ansible.builtin.dnf` instead of `dnf`
- `ansible.posix.firewalld` instead of `firewalld`
- `community.general.parted` instead of `parted`

### When FQCN is Required

**Exam Context**: The exam may require FQCN usage to test your understanding of collections.

**Production Reality**: Short names work fine when collections are properly installed.

**Best Practice**: Use FQCN in playbooks for clarity and exam compliance.

### FQCN Examples in Playbooks

```yaml
---
# EXAM-COMPLIANT PLAYBOOK WITH FQCN
- name: Configure web server
  hosts: webservers
  become: true
  
  tasks:
    - name: Install web server
      ansible.builtin.dnf:           # FQCN instead of 'dnf'
        name: httpd
        state: present
    
    - name: Start and enable service
      ansible.builtin.systemd:       # FQCN instead of 'systemd'
        name: httpd
        state: started
        enabled: true
    
    - name: Configure firewall
      ansible.posix.firewalld:       # FQCN instead of 'firewalld'
        service: http
        permanent: true
        immediate: true
        state: enabled
    
    - name: Create partition
      community.general.parted:      # FQCN for community module
        device: /dev/vdb
        number: 1
        state: present
```

---

## 🔧 Collection Management with ansible-galaxy

### Installing Collections

```bash
# Install specific collection
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install containers.podman

# Install with version specification
ansible-galaxy collection install community.general:>=3.0.0

# Install to custom path
ansible-galaxy collection install community.general -p ./collections/

# Install from requirements file
ansible-galaxy collection install -r requirements.yml
```

### Requirements File Format

```yaml
# requirements.yml
---
collections:
  - name: community.general
    version: ">=4.0.0"
  
  - name: ansible.posix
    version: ">=1.3.0"
  
  - name: containers.podman
    source: https://galaxy.ansible.com
  
  - name: community.crypto
    version: ">=2.0.0"
```

### Managing Installed Collections

```bash
# List all installed collections
ansible-galaxy collection list

# List specific collection
ansible-galaxy collection list community.general

# Show collection details
ansible-galaxy collection list community.general --format yaml

# Check collection path
ansible-config dump | grep COLLECTIONS_PATHS
```

---

## 📚 Critical Collections for RHCE Exam

### ansible.builtin

**Purpose**: Core Ansible modules (always available)

**Key Modules for Exam**:
```yaml
# Package management
ansible.builtin.dnf:
ansible.builtin.package:

# Service management  
ansible.builtin.systemd:
ansible.builtin.service:

# File operations
ansible.builtin.copy:
ansible.builtin.template:
ansible.builtin.file:
ansible.builtin.lineinfile:

# User management
ansible.builtin.user:
ansible.builtin.group:
ansible.builtin.authorized_key:

# System operations
ansible.builtin.command:
ansible.builtin.shell:
ansible.builtin.setup:
```

### ansible.posix

**Purpose**: POSIX system administration modules

**Key Modules for Exam**:
```yaml
# Firewall management
ansible.posix.firewalld:

# Storage management
ansible.posix.mount:

# SELinux management
ansible.posix.seboolean:
ansible.posix.sefcontext:

# Scheduling
ansible.posix.at:

# Archiving
ansible.posix.synchronize:
```

### community.general

**Purpose**: General community-maintained modules

**Key Modules for Exam**:
```yaml
# Storage management
community.general.parted:
community.general.lvg:
community.general.lvol:
community.general.filesystem:

# System information
community.general.system_info:

# Subscription management (RHEL)
community.general.rhsm_subscription:
```

---

## 🔍 Collection Documentation and Discovery

### Using ansible-navigator

```bash
# Browse all collections
ansible-navigator collections

# View collection details
ansible-navigator collections community.general

# Browse modules within collection
ansible-navigator doc community.general.parted
ansible-navigator doc ansible.posix.firewalld
```

### Using ansible-doc

```bash
# List modules in collection
ansible-doc -l | grep community.general
ansible-doc -l | grep ansible.posix

# View specific module documentation
ansible-doc community.general.parted
ansible-doc ansible.posix.firewalld

# Get module synopsis only
ansible-doc -s community.general.lvg
```

### Galaxy Website (Pre-Exam Preparation)

```bash
# Browse collections online (before exam)
# https://galaxy.ansible.com/community/general
# https://galaxy.ansible.com/ansible/posix

# Search for specific functionality
ansible-galaxy collection search firewall
ansible-galaxy collection search storage
```

---

## ⚙️ Collection Configuration

### ansible.cfg Collection Settings

```ini
# ansible.cfg
[defaults]
collections_path = ./collections:/usr/share/ansible/collections

# Require explicit collection names (strict mode)
collections_scan_sys_paths = false
```

### Environment Variables

```bash
# Set collection path
export ANSIBLE_COLLECTIONS_PATH=./collections:/usr/share/ansible/collections

# Verify collection path
ansible-config dump | grep COLLECTIONS_PATH
```

### Collection Search Order

1. **collections_path** in ansible.cfg
2. **ANSIBLE_COLLECTIONS_PATH** environment variable
3. **~/.ansible/collections**
4. **/usr/share/ansible/collections**

---

## 🧪 Practical Examples

### Storage Management with Collections

```yaml
---
- name: Storage automation with collections
  hosts: storage_servers
  become: true
  
  tasks:
    - name: Create partition
      community.general.parted:
        device: /dev/vdb
        number: 1
        part_end: 2GiB
        state: present
      
    - name: Create volume group
      community.general.lvg:
        vg: data_vg
        pvs: /dev/vdb1
        state: present
    
    - name: Create logical volume
      community.general.lvol:
        vg: data_vg
        lv: data_lv
        size: 1G
        state: present
    
    - name: Create filesystem
      community.general.filesystem:
        fstype: ext4
        dev: /dev/data_vg/data_lv
    
    - name: Mount filesystem
      ansible.posix.mount:
        path: /mnt/data
        src: /dev/data_vg/data_lv
        fstype: ext4
        state: mounted
```

### Security Configuration with Collections

```yaml
---
- name: Security configuration with collections
  hosts: web_servers
  become: true
  
  tasks:
    - name: Configure firewall for web
      ansible.posix.firewalld:
        service: http
        permanent: true
        immediate: true
        state: enabled
    
    - name: Configure firewall for SSL
      ansible.posix.firewalld:
        service: https
        permanent: true
        immediate: true
        state: enabled
    
    - name: Set SELinux boolean for network connect
      ansible.posix.seboolean:
        name: httpd_can_network_connect
        state: true
        persistent: true
    
    - name: Set custom SELinux context
      community.general.sefcontext:
        target: '/web_content(/.*)?'
        setype: httpd_exec_t
        state: present
      notify: restore selinux context
  
  handlers:
    - name: restore selinux context
      ansible.builtin.command: restorecon -R /web_content
```

---

## 🚨 Common Exam Gotchas

### Collection Installation Issues

**Problem**: Module not found during playbook execution
```bash
# Error message
ERROR! couldn't resolve module/action 'community.general.parted'
```

**Solution**: Install missing collection
```bash
ansible-galaxy collection install community.general
```

### FQCN Requirements

**Problem**: Using short module names when FQCN required
```yaml
# Potentially problematic
- dnf:
    name: httpd
    state: present
```

**Solution**: Use FQCN format
```yaml
# Exam-compliant
- ansible.builtin.dnf:
    name: httpd
    state: present
```

### Collection Path Issues

**Problem**: Collections installed but not found
```bash
# Check collection path
ansible-config dump | grep COLLECTIONS_PATH

# Verify collection installation
ansible-galaxy collection list
```

**Solution**: Ensure collections_path is correctly configured

---

## 📋 Exam-Specific Best Practices

### Pre-Exam Preparation

1. **Install critical collections** in your lab environment
2. **Practice FQCN syntax** until it's natural
3. **Bookmark key module documentation** (mentally)
4. **Test collection installation** procedures

### During the Exam

1. **Check collection availability** early
2. **Use FQCN consistently** in playbooks  
3. **Install missing collections** immediately when needed
4. **Use ansible-navigator** to browse collections

### Time Management

- **Don't over-think FQCN** - use it consistently
- **Install collections early** in exam session
- **Use collection documentation** efficiently
- **Focus on required modules** for each task

---

## 🧪 Practical Lab Exercises

### Exercise 1: Collection Installation
1. Install community.general and ansible.posix collections
2. List installed collections
3. Verify specific modules are available

### Exercise 2: FQCN Conversion
1. Create a playbook using short module names
2. Convert all modules to FQCN format
3. Test both versions work the same

### Exercise 3: Storage Automation
1. Create a playbook using storage-related collections
2. Use community.general modules for LVM
3. Use ansible.posix.mount for filesystem mounting

### Exercise 4: Collection Documentation
1. Use ansible-navigator to browse collections
2. Find the firewalld module documentation
3. Practice quick module lookup techniques

---

## 🎯 Key Takeaways for Experienced Users

1. **Collections are the future** - embrace FQCN usage
2. **Three critical collections** - ansible.builtin, ansible.posix, community.general
3. **Installation is straightforward** - use ansible-galaxy collection install
4. **Documentation is integrated** - use navigator for browsing
5. **FQCN prevents confusion** - especially in exam scenarios

### Memory Aids

**Essential Collections:**
- **ansible.builtin** = Core modules (dnf, systemd, user, copy)
- **ansible.posix** = System modules (firewalld, mount, seboolean)  
- **community.general** = Storage modules (parted, lvg, lvol)

**FQCN Pattern:**
- **namespace.collection.module** format
- **Always start with namespace** (ansible, community)
- **Use tab completion** in editors when possible

Master collections now, and module management becomes second nature on the exam!