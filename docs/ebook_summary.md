# RHCE Study Guide Summary

## 🎯 Concise Reference for RHCE EX294 Exam Success

**Purpose**: Focused summary of essential RHCE exam content covering all objectives without unnecessary detail.

**Source Materials**:
- Sander van Vugt's RHCE Guide (16 chapters) - Primary exam guide
- Jeff Geerling's Ansible for DevOps (15 chapters) - Real-world patterns
- Red Hat RHCE Study Guide - Exam-focused content

**Study Approach**: Master these topics through hands-on practice and systematic review.

---

## 📋 RHCE Exam Overview

**Exam Code**: EX294 | **Duration**: 4 hours | **Format**: Performance-based | **Passing Score**: 210/300

### Prerequisites
- Current RHCSA certification required
- RHEL 8/9 system administration knowledge
- Basic Linux command line proficiency

### Exam Environment
- **Control Node**: RHEL 8/9 with Ansible pre-installed
- **Managed Nodes**: 2-4 RHEL systems for automation targets
- **Tools Available**: ansible-navigator, ansible-doc, man pages (offline only)
- **No Internet Access**: All documentation must be local

---

## 🔧 Core RHCE Topics

### 1. Installation and Configuration (20%)

#### Control Node Setup
- **Package Installation**: `dnf install ansible-core ansible-navigator`
- **Configuration File**: `/etc/ansible/ansible.cfg` or `./ansible.cfg`
- **Key Settings**: `host_key_checking = False`, `remote_user = ansible`, `become = True`
- **Directory Structure**: `playbooks/`, `roles/`, `group_vars/`, `host_vars/`

#### SSH Key Management
- **Generate Keys**: `ssh-keygen -t rsa -b 4096`
- **Distribute Keys**: `ssh-copy-id ansible@managed_node`
- **Test Connectivity**: `ansible all -m ping`

#### Essential Configuration
```ini
[defaults]
inventory = inventory.ini
remote_user = ansible
host_key_checking = False
become = True
become_method = sudo
roles_path = ./roles
collections_paths = ./collections
```

### 2. Inventory Management (15%)

#### Static Inventory Formats
- **INI Format**: Groups in `[brackets]`, hosts listed below
- **YAML Format**: Hierarchical structure with `children:` and `hosts:`
- **Variables**: `host_vars/` directory or inline `hostname var=value`

#### Host Patterns
- **All hosts**: `all` or `*`
- **Groups**: `webservers`, `databases`  
- **Exclusions**: `webservers:!web03`
- **Intersections**: `webservers:&production`
- **Regular expressions**: `~web\d+`

#### Group Variables
- **Structure**: `group_vars/groupname.yml` or `group_vars/groupname/`
- **Precedence**: host_vars > group_vars > all
- **Best Practice**: Use descriptive variable names

### 3. Ad-hoc Commands (10%)

#### Command Structure
`ansible <pattern> -m <module> -a "<arguments>" [options]`

#### Essential Modules
| Module | Purpose | Example |
|--------|---------|---------|
| `ping` | Connectivity test | `ansible all -m ping` |
| `command` | Run commands | `ansible all -m command -a "uptime"` |
| `shell` | Shell with pipes | `ansible all -m shell -a "ps aux \| grep http"` |
| `copy` | Copy files | `ansible all -m copy -a "src=file dest=/tmp/"` |
| `dnf` | Package management | `ansible all -m dnf -a "name=httpd state=present" --become` |
| `systemd` | Service control | `ansible all -m systemd -a "name=httpd state=started enabled=yes" --become` |

#### Common Options
- `--become` or `-b`: Privilege escalation
- `--check` or `-C`: Dry run mode
- `--limit`: Target specific hosts
- `-v/-vv/-vvv`: Increase verbosity

### 4. Playbook Development (25%)

#### Basic Structure
```yaml
---
- name: Playbook description
  hosts: target_group
  become: yes
  vars:
    variable_name: value
  tasks:
    - name: Task description
      module_name:
        parameter: value
      notify: handler_name
  handlers:
    - name: handler_name
      module_name:
        parameter: value
```

#### Essential Modules with FQCN
| Module | FQCN | Primary Use |
|--------|------|-------------|
| `dnf` | `ansible.builtin.dnf` | Package management |
| `systemd` | `ansible.builtin.systemd` | Service control |
| `copy` | `ansible.builtin.copy` | File copying |
| `template` | `ansible.builtin.template` | Jinja2 templating |
| `file` | `ansible.builtin.file` | File/directory operations |
| `user` | `ansible.builtin.user` | User management |
| `group` | `ansible.builtin.group` | Group management |
| `firewalld` | `ansible.posix.firewalld` | Firewall configuration |
| `mount` | `ansible.posix.mount` | Filesystem mounting |
| `seboolean` | `ansible.posix.seboolean` | SELinux booleans |

#### Task Control
- **Conditionals**: `when: condition`
- **Loops**: `loop:` or `with_items:`
- **Error Handling**: `failed_when:`, `ignore_errors:`
- **Change Control**: `changed_when:`

### 5. Variables and Facts (20%)

#### Variable Types
| Type | Scope | Definition Location |
|------|-------|-------------------|
| Global | All hosts | Command line `-e` |
| Play | Single play | `vars:` section |
| Host | Single host | `host_vars/` |
| Group | Host group | `group_vars/` |
| Role | Role scope | `roles/*/vars/` |
| Default | Fallback | `roles/*/defaults/` |

#### Magic Variables
- `inventory_hostname`: Current host name
- `hostvars`: All host variables
- `groups`: All inventory groups
- `group_names`: Groups current host belongs to
- `play_hosts`: Hosts in current play

#### Facts
- **Gathering**: Automatic via `setup` module
- **Usage**: `{{ ansible_facts['distribution'] }}`
- **Custom Facts**: `/etc/ansible/facts.d/*.fact`
- **Disable**: `gather_facts: no`

### 6. Templates and Jinja2 (15%)

#### Template Basics
- **File Extension**: `.j2`
- **Module**: `ansible.builtin.template`
- **Variables**: `{{ variable_name }}`
- **Conditionals**: `{% if condition %} ... {% endif %}`
- **Loops**: `{% for item in list %} ... {% endfor %}`

#### Common Filters
| Filter | Purpose | Example |
|--------|---------|---------|
| `default` | Fallback value | `{{ var \| default('none') }}` |
| `upper`/`lower` | Case conversion | `{{ name \| upper }}` |
| `length` | Count items | `{{ list \| length }}` |
| `join` | Combine with separator | `{{ items \| join(',') }}` |
| `regex_replace` | Pattern replacement | `{{ text \| regex_replace('old', 'new') }}` |

#### Template Example
```jinja2
# Generated by Ansible
ServerName {{ ansible_fqdn }}
Listen {{ http_port | default(80) }}

{% for vhost in virtual_hosts %}
<VirtualHost *:{{ http_port }}>
    ServerName {{ vhost.name }}
    DocumentRoot {{ vhost.docroot }}
</VirtualHost>
{% endfor %}
```

### 7. Roles and Collections (20%)

#### Role Structure
```
roles/rolename/
├── defaults/main.yml    # Default variables
├── files/              # Static files
├── handlers/main.yml   # Event handlers
├── meta/main.yml       # Role metadata
├── tasks/main.yml      # Primary tasks
├── templates/          # Jinja2 templates
└── vars/main.yml       # Role variables
```

#### Role Usage
- **Create**: `ansible-galaxy init rolename`
- **Install**: `ansible-galaxy role install author.rolename`
- **Use in Playbook**: `roles:` section or `include_role` task

#### Collections
- **Install**: `ansible-galaxy collection install namespace.collection`
- **Requirements**: `requirements.yml` file
- **Usage**: FQCN format (`namespace.collection.module`)

#### Essential Collections
| Collection | Modules | Use Case |
|------------|---------|----------|
| `ansible.builtin` | Core modules | System administration |
| `ansible.posix` | POSIX tools | Unix/Linux systems |
| `community.general` | Extended modules | Additional functionality |

### 8. Ansible Vault (15%)

#### Basic Operations
| Command | Purpose | Usage |
|---------|---------|-------|
| `create` | New encrypted file | `ansible-vault create secrets.yml` |
| `edit` | Modify encrypted file | `ansible-vault edit secrets.yml` |
| `view` | Read encrypted file | `ansible-vault view secrets.yml` |
| `encrypt` | Encrypt existing file | `ansible-vault encrypt file.yml` |
| `decrypt` | Remove encryption | `ansible-vault decrypt file.yml` |
| `rekey` | Change password | `ansible-vault rekey secrets.yml` |

#### String Encryption
- **Encrypt**: `ansible-vault encrypt_string 'secret' --name 'db_password'`
- **Usage**: Embed in regular YAML files

#### Playbook Integration
- **Prompt**: `ansible-navigator run site.yml --ask-vault-pass`
- **File**: `ansible-navigator run site.yml --vault-password-file .vault_pass`
- **Multiple**: `ansible-navigator run site.yml --vault-id prod@prompt`

### 9. System Administration Tasks (25%)

#### Package Management
```yaml
- name: Install packages
  ansible.builtin.dnf:
    name: ['httpd', 'php', 'mariadb-server']
    state: present
    
- name: Update all packages
  ansible.builtin.dnf:
    name: '*'
    state: latest
```

#### Service Management
```yaml
- name: Start and enable services
  ansible.builtin.systemd:
    name: "{{ item }}"
    state: started
    enabled: yes
  loop:
    - httpd
    - mariadb
```

#### User Management
```yaml
- name: Create user
  ansible.builtin.user:
    name: webuser
    groups: apache
    shell: /bin/bash
    create_home: yes
    state: present
```

#### Storage Management
```yaml
- name: Create partition
  community.general.parted:
    device: /dev/sdb
    number: 1
    state: present
    
- name: Create volume group
  community.general.lvg:
    vg: vg_data
    pvs: /dev/sdb1
    
- name: Create logical volume
  community.general.lvol:
    vg: vg_data
    lv: lv_web
    size: 2G
```

#### Firewall Configuration
```yaml
- name: Configure firewall
  ansible.posix.firewalld:
    service: "{{ item }}"
    permanent: yes
    state: enabled
    immediate: yes
  loop:
    - http
    - https
```

#### SELinux Management
```yaml
- name: Set SELinux booleans
  ansible.posix.seboolean:
    name: httpd_can_network_connect
    state: yes
    persistent: yes
```

### 10. Automation Content Navigator (10%)

#### Execution Modes
- **Interactive (TUI)**: `ansible-navigator run playbook.yml`
- **Stdout**: `ansible-navigator run playbook.yml --mode stdout`

#### TUI Navigation
- `:help` - Show help
- `:doc module_name` - Module documentation
- `:collections` - Browse collections
- `:inventory` - View inventory
- `:q` - Quit

#### Common Options
- `--check` - Dry run mode
- `--syntax-check` - YAML validation
- `--limit group` - Target specific hosts
- `--tags tag1,tag2` - Run specific tags
- `--vault-password-file` - Vault password

---

## 🎯 Exam Strategy and Tips

### Time Management (4 hours total)
1. **Read all tasks first** (15 minutes)
2. **Set up environment** (30 minutes) - SSH keys, inventory, ansible.cfg
3. **Complete tasks systematically** (3 hours)
4. **Verify and test** (15 minutes)

### Critical Success Factors
- **Test connectivity first**: `ansible all -m ping`
- **Syntax check always**: `ansible-navigator run --syntax-check`
- **Use check mode**: `--check --diff` before executing
- **Know ansible-doc**: Your primary reference tool
- **FQCN required**: Always use full module names
- **Vault everything**: Encrypt all sensitive data

### Common Pitfalls
- **Wrong tool**: Use `ansible-navigator` not `ansible-playbook`
- **Missing FQCN**: Short module names will fail
- **No collections**: Install required collections first
- **SSH issues**: Verify key authentication before starting
- **Syntax errors**: One mistake fails entire playbook

### Documentation Strategy
- **Module parameters**: `ansible-doc module_name`
- **Examples**: `ansible-doc module_name | grep -A20 EXAMPLES`
- **Quick syntax**: `ansible-doc -s module_name`
- **All modules**: `ansible-doc -l | grep keyword`

### Verification Commands
```bash
# Test playbook execution
ansible-navigator run site.yml --check --diff

# Verify services
ansible all -m systemd -a "name=httpd" --become

# Check files
ansible all -m stat -a "path=/etc/httpd/conf/httpd.conf"

# Test web services
ansible all -m uri -a "url=http://{{ ansible_default_ipv4.address }}"
```

---

## 📚 Essential Module Quick Reference

### System Management
| Module | Key Parameters | Example |
|--------|---------------|---------|
| `ansible.builtin.systemd` | `name`, `state`, `enabled` | `state: started, enabled: yes` |
| `ansible.builtin.user` | `name`, `groups`, `state` | `name: webuser, groups: apache` |
| `ansible.builtin.group` | `name`, `state`, `gid` | `name: webgroup, gid: 1001` |

### Package Management
| Module | Key Parameters | Example |
|--------|---------------|---------|
| `ansible.builtin.dnf` | `name`, `state` | `name: httpd, state: present` |
| `ansible.builtin.package` | `name`, `state` | Generic package module |

### File Operations
| Module | Key Parameters | Example |
|--------|---------------|---------|
| `ansible.builtin.copy` | `src`, `dest`, `owner`, `mode` | `src: file.txt, dest: /tmp/` |
| `ansible.builtin.template` | `src`, `dest`, `backup` | `src: config.j2, dest: /etc/app/` |
| `ansible.builtin.file` | `path`, `state`, `owner`, `mode` | `path: /tmp/dir, state: directory` |

### Network and Security
| Module | Key Parameters | Example |
|--------|---------------|---------|
| `ansible.posix.firewalld` | `service`, `port`, `state` | `service: http, state: enabled` |
| `ansible.posix.seboolean` | `name`, `state`, `persistent` | `name: httpd_can_network_connect` |
| `ansible.posix.mount` | `path`, `src`, `fstype`, `state` | `path: /mnt, src: /dev/sdb1` |

### Storage Management
| Module | Key Parameters | Example |
|--------|---------------|---------|
| `community.general.parted` | `device`, `number`, `state` | `device: /dev/sdb, number: 1` |
| `community.general.lvg` | `vg`, `pvs` | `vg: vg_data, pvs: /dev/sdb1` |
| `community.general.lvol` | `vg`, `lv`, `size` | `vg: vg_data, lv: lv_web, size: 2G` |

---

## 🏆 Final Preparation Checklist

### Lab Environment Ready
- [ ] Control node with Ansible installed
- [ ] SSH keys distributed to managed nodes
- [ ] Inventory file configured and tested
- [ ] Basic playbook execution verified

### Core Skills Mastered  
- [ ] Ad-hoc commands for all essential modules
- [ ] Playbook structure and syntax
- [ ] Variable usage and precedence
- [ ] Template creation with Jinja2
- [ ] Role development and usage
- [ ] Vault encryption for sensitive data

### System Administration Tasks
- [ ] Package installation and updates
- [ ] Service start/stop/enable
- [ ] User and group management
- [ ] File permissions and ownership
- [ ] Storage: partitions, LVM, filesystems
- [ ] Network: firewall configuration
- [ ] Security: SELinux settings

### Exam Readiness
- [ ] ansible-navigator proficiency (TUI and stdout)
- [ ] ansible-doc for module reference
- [ ] Time management under pressure
- [ ] Systematic verification approach
- [ ] Troubleshooting failed tasks

**Remember**: The RHCE exam tests practical automation skills. Focus on hands-on practice over theoretical knowledge.