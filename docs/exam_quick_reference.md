# RHCE Exam Quick Reference (Cheat Sheet)

## 🎯 Essential Commands & Syntax for EX294 Success

*Concise reference for exam day - copy-paste ready syntax and parameters*

---

## ⚙️ Core Configuration

### ansible.cfg Essential Settings
```ini
[defaults]
inventory = inventory.ini
remote_user = ansible
host_key_checking = False
become = True
become_method = sudo
roles_path = ./roles
collections_paths = ./collections
timeout = 30
forks = 5

[privilege_escalation]
become = True
become_method = sudo
become_user = root
```

### Inventory Patterns
```ini
# INI Format
[webservers]
web01.example.com
web02.example.com

[databases]
db01.example.com ansible_host=192.168.1.100

[production:children]
webservers
databases

[all:vars]
ansible_user=ansible
```

### SSH Setup
```bash
ssh-keygen -t rsa -b 4096 -N ""
ssh-copy-id ansible@managed_node
ansible all -m ping
```

---

## 🔧 Ad-hoc Commands

### Command Structure
`ansible <pattern> -m <module> -a "<arguments>" [options]`

### Essential Ad-hoc Patterns
```bash
# Connectivity and info
ansible all -m ping
ansible all -m setup
ansible all -m command -a "uptime"

# Package management
ansible all -m dnf -a "name=httpd state=present" --become
ansible all -m dnf -a "name='*' state=latest" --become

# Service control
ansible all -m systemd -a "name=httpd state=started enabled=yes" --become

# File operations
ansible all -m copy -a "src=file.txt dest=/tmp/" --become
ansible all -m file -a "path=/tmp/dir state=directory" --become

# User management
ansible all -m user -a "name=webuser groups=apache" --become
```

### Common Options
```bash
--become (-b)          # Privilege escalation
--check (-C)           # Dry run
--diff (-D)            # Show changes
--limit                # Target specific hosts
-e "var=value"        # Extra variables
-v/-vv/-vvv           # Verbosity levels
```

---

## 📝 Playbook Syntax

### Basic Structure
```yaml
---
- name: Playbook description
  hosts: target_group
  become: yes
  gather_facts: yes
  vars:
    variable_name: value
  vars_files:
    - vars/main.yml
  tasks:
    - name: Task description
      ansible.builtin.module_name:
        parameter: value
        state: present
      register: result
      when: condition
      loop: "{{ list_variable }}"
      notify: handler_name
      tags: tag_name
  handlers:
    - name: handler_name
      ansible.builtin.systemd:
        name: service_name
        state: restarted
  roles:
    - role_name
```

### Task Keywords (Complete Reference)
```yaml
- name: Task name                    # Required
  module_name:                      # Required
    parameter: value
  when: condition                   # Conditional execution
  loop: "{{ items }}"              # Iteration
  register: variable_name          # Save result
  failed_when: condition           # Custom failure
  changed_when: condition          # Custom change
  ignore_errors: yes              # Continue on failure
  no_log: yes                     # Hide from logs
  delegate_to: hostname           # Run on different host
  run_once: yes                   # Run only once
  become: yes                     # Privilege escalation
  become_user: username           # Escalate to user
  tags: [tag1, tag2]             # Task tags
  notify: handler_name            # Trigger handler
  async: 300                      # Async timeout
  poll: 5                         # Async polling
```

---

## 📦 Essential Modules with FQCN

### System Management
| Module | FQCN | Key Parameters | Example |
|--------|------|---------------|---------|
| **systemd** | `ansible.builtin.systemd` | name, state, enabled, daemon_reload | `name: httpd, state: started, enabled: yes` |
| **service** | `ansible.builtin.service` | name, state, enabled | `name: httpd, state: started` |
| **user** | `ansible.builtin.user` | name, groups, shell, home, state | `name: webuser, groups: apache, shell: /bin/bash` |
| **group** | `ansible.builtin.group` | name, gid, state | `name: webgroup, gid: 1001` |
| **cron** | `ansible.builtin.cron` | name, job, minute, hour, user | `job: "backup.sh", minute: "0", hour: "2"` |

### Package Management
| Module | FQCN | Key Parameters | Example |
|--------|------|---------------|---------|
| **dnf** | `ansible.builtin.dnf` | name, state, enablerepo, disablerepo | `name: httpd, state: present` |
| **package** | `ansible.builtin.package` | name, state | `name: httpd, state: latest` |
| **rpm_key** | `ansible.builtin.rpm_key` | key, state | `key: https://example.com/key.asc` |

### File Operations
| Module | FQCN | Key Parameters | Example |
|--------|------|---------------|---------|
| **copy** | `ansible.builtin.copy` | src, dest, owner, group, mode, backup | `src: file.txt, dest: /etc/file.txt, mode: '0644'` |
| **template** | `ansible.builtin.template` | src, dest, owner, group, mode, backup | `src: config.j2, dest: /etc/config.conf` |
| **file** | `ansible.builtin.file` | path, state, owner, group, mode | `path: /tmp/dir, state: directory, mode: '0755'` |
| **lineinfile** | `ansible.builtin.lineinfile` | path, line, regexp, state | `path: /etc/hosts, line: "192.168.1.1 server"` |
| **replace** | `ansible.builtin.replace` | path, regexp, replace | `path: /etc/config, regexp: 'old', replace: 'new'` |
| **blockinfile** | `ansible.builtin.blockinfile` | path, block, marker | `path: /etc/config, block: "content here"` |

### Storage Management
| Module | FQCN | Key Parameters | Example |
|--------|------|---------------|---------|
| **parted** | `community.general.parted` | device, number, state, part_type | `device: /dev/sdb, number: 1, state: present` |
| **lvg** | `community.general.lvg` | vg, pvs, state | `vg: vg_data, pvs: /dev/sdb1` |
| **lvol** | `community.general.lvol` | vg, lv, size, state | `vg: vg_data, lv: lv_web, size: 2G` |
| **filesystem** | `ansible.builtin.filesystem` | fstype, dev, opts | `fstype: xfs, dev: /dev/vg_data/lv_web` |
| **mount** | `ansible.posix.mount` | path, src, fstype, state, opts | `path: /mnt, src: /dev/sdb1, fstype: xfs, state: mounted` |

### Network & Security
| Module | FQCN | Key Parameters | Example |
|--------|------|---------------|---------|
| **firewalld** | `ansible.posix.firewalld` | service, port, zone, permanent, immediate, state | `service: http, permanent: yes, immediate: yes, state: enabled` |
| **seboolean** | `ansible.posix.seboolean` | name, state, persistent | `name: httpd_can_network_connect, state: yes, persistent: yes` |
| **selinux** | `ansible.posix.selinux` | policy, state | `state: enforcing` |
| **authorized_key** | `ansible.posix.authorized_key` | user, key, state | `user: ansible, key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"` |
| **uri** | `ansible.builtin.uri` | url, method, return_content | `url: http://example.com, method: GET` |

---

## 🔄 Variables & Facts

### Variable Precedence (High to Low)
1. Command line `-e`
2. Task vars
3. Block vars  
4. Role and include vars
5. Set_facts / registered vars
6. Play vars_files
7. Play vars_prompt
8. Play vars
9. Host facts
10. Host vars (inventory)
11. Group vars (inventory) 
12. Group vars (/all)
13. Group vars (/*) 
14. Role defaults
15. Command line inventory vars
16. Default vars (deprecated)

### Magic Variables
```yaml
inventory_hostname          # Current host name
inventory_hostname_short    # Short hostname
group_names                # Groups current host belongs to
groups                     # All groups and hosts
hostvars                   # All host variables
play_hosts                 # Hosts in current play
ansible_play_batch         # Current batch of hosts
ansible_facts              # All gathered facts
```

### Fact Access Patterns
```yaml
"{{ ansible_facts['distribution'] }}"
"{{ ansible_facts['default_ipv4']['address'] }}"
"{{ ansible_facts['memtotal_mb'] }}"
"{{ ansible_facts['processor_count'] }}"
"{{ ansible_facts['devices']['sda']['size'] }}"
```

### Register and Debug
```yaml
- name: Run command
  ansible.builtin.command: uptime
  register: result

- name: Show result
  ansible.builtin.debug:
    var: result
    # or
    msg: "Uptime is {{ result.stdout }}"
```

---

## 🔀 Task Control

### Conditionals
```yaml
when: ansible_facts['distribution'] == "RedHat"
when: ansible_facts['distribution_major_version'] == "8"
when: inventory_hostname in groups['webservers']
when: result is succeeded
when: result is failed
when: variable_name is defined
when: variable_name is undefined
when: item != "excluded_item"
```

### Loops
```yaml
# Simple loop
loop:
  - item1
  - item2

# Dictionary loop
loop: "{{ users }}"
vars:
  users:
    - name: alice
      group: admins
    - name: bob
      group: users

# Range loop
loop: "{{ range(1, 6) | list }}"  # 1,2,3,4,5

# File glob loop
loop: "{{ query('fileglob', '/etc/*.conf') }}"
```

### Error Handling
```yaml
# Block structure
- name: Handle errors
  block:
    - name: Risky task
      ansible.builtin.command: /might/fail
  rescue:
    - name: Recovery task
      ansible.builtin.debug:
        msg: "Task failed, recovering"
  always:
    - name: Cleanup task
      ansible.builtin.debug:
        msg: "Always runs"

# Custom conditions
failed_when: result.rc != 0 and "ignore" not in result.stdout
changed_when: "'changes made' in result.stdout"
ignore_errors: yes
```

---

## 🎨 Templates & Jinja2

### Variable Substitution
```jinja2
{{ variable_name }}
{{ ansible_facts['hostname'] }}
{{ hostvars[inventory_hostname]['custom_var'] }}
{{ groups['webservers'] | join(',') }}
```

### Control Structures
```jinja2
# Conditionals
{% if ansible_facts['distribution'] == "RedHat" %}
RedHat specific config
{% elif ansible_facts['distribution'] == "Ubuntu" %}
Ubuntu specific config
{% else %}
Generic config
{% endif %}

# Loops
{% for host in groups['webservers'] %}
server {{ hostvars[host]['ansible_default_ipv4']['address'] }}
{% endfor %}

# Comments
{# This is a comment #}
```

### Essential Filters
```jinja2
{{ variable | default('default_value') }}
{{ string_var | upper }}
{{ string_var | lower }}
{{ list_var | length }}
{{ list_var | join(',') }}
{{ list_var | sort }}
{{ list_var | unique }}
{{ string_var | regex_replace('old', 'new') }}
{{ dict_var | dict2items }}
{{ number_var | int }}
{{ string_var | bool }}
```

---

## 📁 Roles & Collections

### Role Structure
```
roles/rolename/
├── defaults/main.yml     # Default variables
├── files/               # Static files
├── handlers/main.yml    # Handlers
├── meta/main.yml        # Role metadata
├── tasks/main.yml       # Main tasks
├── templates/          # Jinja2 templates
└── vars/main.yml       # Role variables
```

### Galaxy Commands
```bash
# Role operations
ansible-galaxy init rolename
ansible-galaxy role install author.rolename
ansible-galaxy role list

# Collection operations
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
ansible-galaxy collection list
```

### FQCN Requirements
```yaml
# Always use Fully Qualified Collection Names
tasks:
  - name: Install package
    ansible.builtin.dnf:           # Not just 'dnf:'
      name: httpd
      state: present
```

---

## 🔒 Ansible Vault

### Vault Commands
```bash
# File operations
ansible-vault create secrets.yml
ansible-vault edit secrets.yml
ansible-vault view secrets.yml
ansible-vault encrypt existing_file.yml
ansible-vault decrypt secrets.yml
ansible-vault rekey secrets.yml

# String encryption
ansible-vault encrypt_string 'secret_password' --name 'db_password'
```

### Playbook Integration
```bash
# Password prompt
ansible-navigator run site.yml --ask-vault-pass

# Password file
echo 'vault_password' > .vault_pass
chmod 600 .vault_pass
ansible-navigator run site.yml --vault-password-file .vault_pass

# Multiple vault IDs
ansible-navigator run site.yml --vault-id prod@prompt --vault-id dev@.vault_pass
```

### Vault File Usage
```yaml
# In playbook
vars_files:
  - group_vars/all/vault.yml

# Encrypted string in vars
vars:
  db_password: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    encrypted_content_here
```

---

## 🧭 Navigator Commands

### Execution Modes
```bash
# Interactive TUI
ansible-navigator run site.yml

# Command-line output
ansible-navigator run site.yml --mode stdout

# Common options
ansible-navigator run site.yml --check --diff
ansible-navigator run site.yml --syntax-check
ansible-navigator run site.yml --limit webservers
ansible-navigator run site.yml -e "env=prod"
ansible-navigator run site.yml --ask-vault-pass
```

### TUI Navigation
```bash
:help                    # Show help
:doc module_name         # Module documentation
:collections             # Browse collections
:inventory               # View inventory
:q or :quit             # Exit
```

### Documentation Access
```bash
ansible-navigator doc ansible.builtin.dnf
ansible-navigator doc -l | grep firewall
ansible-doc module_name  # Fallback command
ansible-doc -s module_name  # Synopsis only
```

---

## 🐛 Troubleshooting

### Debug Strategies
```yaml
# Debug module
- name: Show variable
  ansible.builtin.debug:
    var: variable_name
    msg: "Value is {{ variable_name }}"

# Verbosity levels
ansible-navigator run site.yml -v      # Basic
ansible-navigator run site.yml -vv     # More info
ansible-navigator run site.yml -vvv    # Connection debug
ansible-navigator run site.yml -vvvv   # Everything
```

### Common Patterns
```bash
# Check syntax
ansible-navigator run site.yml --syntax-check

# Dry run with changes
ansible-navigator run site.yml --check --diff

# Test connectivity
ansible all -m ping

# Gather facts
ansible all -m setup --tree /tmp/facts

# Check specific service
ansible all -m systemd -a "name=httpd" --become
```

---

## ⚡ Exam Success Patterns

### Time-Saving Commands
```bash
# Quick validation sequence
ansible all -m ping && \
ansible-navigator run site.yml --syntax-check && \
ansible-navigator run site.yml --check && \
ansible-navigator run site.yml --mode stdout

# Fast documentation lookup
ansible-doc -l | grep keyword
ansible-doc -s module_name
```

### Essential Verifications
```bash
# Services
ansible all -m systemd -a "name=httpd" --become

# Files
ansible all -m stat -a "path=/etc/httpd/conf/httpd.conf"

# Packages
ansible all -m package_facts | grep httpd

# Network
ansible all -m uri -a "url=http://{{ ansible_default_ipv4.address }}"
```

### Must-Remember for Exam
- **Always use FQCN**: `ansible.builtin.dnf` not `dnf`
- **Test first**: `--syntax-check`, `--check`, then execute
- **Use ansible-navigator**: Primary tool, not ansible-playbook
- **Know ansible-doc**: Your main reference during exam
- **Vault everything**: Encrypt all sensitive data
- **Check connectivity**: `ansible all -m ping` at start

---

**🎯 Remember**: Practice these patterns until they're automatic. Speed and accuracy win exams!