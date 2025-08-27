# Module 02: Playbooks & Tasks

## 🎯 Learning Objectives

By the end of this module, you will:

- Create well-structured Ansible playbooks using YAML syntax
- Understand playbook components and execution flow
- Master task definition and module usage with FQCN
- Implement handlers for service and configuration management
- Use tags for selective task execution
- Handle errors and implement proper testing workflows
- Execute playbooks with ansible-navigator

## 📋 Why Playbooks Matter

### Beyond Ad-hoc Commands

**Ad-hoc Commands**: Great for quick, one-time tasks
**Playbooks**: Essential for:

- Complex multi-step automation
- Repeatable infrastructure management  
- Configuration management
- Application deployment
- Documented automation workflows

### Playbook Benefits

- **Declarative**: Describe desired end state
- **Idempotent**: Safe to run multiple times
- **Reusable**: Version controlled automation
- **Readable**: Self-documenting YAML format
- **Scalable**: Handle simple to complex scenarios

---

## 📖 YAML Fundamentals for Ansible

### YAML Syntax Essentials

**Basic Structure**:

```yaml
---  # Document start marker (optional but recommended)
# This is a comment
key: value
string_value: "quoted strings when needed"
number_value: 42
boolean_value: true
null_value: null

# Lists
fruits:
  - apple
  - banana
  - orange

# Alternative list syntax
fruits: [apple, banana, orange]

# Dictionaries
person:
  name: John
  age: 30
  active: true

# Alternative dictionary syntax
person: {name: John, age: 30, active: true}
```

### YAML Best Practices for Ansible

**Indentation Rules**:

- Use 2 spaces for indentation (not tabs)
- Be consistent throughout the file
- Align items at the same level

**Quoting Guidelines**:

```yaml
# Quote when necessary
shell_command: "echo 'Hello World'"
path_with_spaces: "/path/with spaces/file.txt"
special_chars: "String with: colons, {braces}, and [brackets]"

# Variables always need quotes in certain contexts
when: "ansible_distribution == 'RedHat'"
```

**Multi-line Strings**:

```yaml
# Literal scalar (preserves line breaks)
script_content: |
  #!/bin/bash
  echo "Line 1"
  echo "Line 2"

# Folded scalar (joins lines)
description: >
  This is a long description
  that will be folded into
  a single line.
```

### Common YAML Pitfalls

```yaml
# Wrong - inconsistent indentation
tasks:
  - name: Task 1
    command: echo "hello"
    - name: Task 2  # Wrong indentation
      command: echo "world"

# Right - consistent indentation
tasks:
  - name: Task 1
    command: echo "hello"
  - name: Task 2
    command: echo "world"

# Wrong - missing quotes
when: variable == yes  # Should be "yes"

# Right - proper quoting
when: variable == "yes"
```

---

## 📚 Playbook Structure

### Basic Playbook Anatomy

```yaml
---
- name: Descriptive playbook name
  hosts: target_hosts
  become: yes
  gather_facts: yes
  vars:
    variable_name: value
  vars_files:
    - vars/external_vars.yml
  tasks:
    - name: Descriptive task name
      module_name:
        parameter: value
        another_parameter: "{{ variable_name }}"
      notify: handler_name
      tags: tag_name
  handlers:
    - name: handler_name
      module_name:
        parameter: value
  roles:
    - role_name
```

### Play-Level Keywords

**Essential Play Keywords**:

```yaml
---
- name: Web server configuration               # Play description
  hosts: webservers                           # Target hosts/groups
  become: yes                                 # Privilege escalation
  become_user: root                           # Escalation target user
  become_method: sudo                         # Escalation method
  gather_facts: yes                           # Collect system facts
  serial: 2                                   # Batch execution size
  max_fail_percentage: 20                     # Failure tolerance
  remote_user: ansible                        # Connection user
  connection: ssh                             # Connection plugin
  timeout: 300                                # Task timeout
  vars:                                       # Play variables
    http_port: 80
  vars_files:                                 # External variable files
    - vars/web_vars.yml
  vars_prompt:                                # Interactive variables
    - name: target_env
      prompt: "Which environment?"
      private: no
```

### Multi-Play Playbooks

```yaml
---
# Play 1: Database setup
- name: Configure database servers
  hosts: databases
  become: yes
  tasks:
    - name: Install MySQL
      ansible.builtin.dnf:
        name: mysql-server
        state: present

# Play 2: Web server setup  
- name: Configure web servers
  hosts: webservers
  become: yes
  tasks:
    - name: Install Apache
      ansible.builtin.dnf:
        name: httpd
        state: present

# Play 3: Load balancer setup
- name: Configure load balancers
  hosts: loadbalancers
  become: yes
  tasks:
    - name: Install HAProxy
      ansible.builtin.dnf:
        name: haproxy
        state: present
```

---

## 🔧 Task Definition and Module Usage

### Task Anatomy

```yaml
- name: Descriptive task name                 # Required: Human readable description
  ansible.builtin.module_name:               # Required: FQCN module name
    parameter1: value1                        # Module-specific parameters
    parameter2: "{{ variable_name }}"
    parameter3:
      - list_item1
      - list_item2
  register: result_variable                   # Capture task output
  when: condition                             # Conditional execution
  loop: "{{ items_list }}"                    # Iteration
  failed_when: custom_failure_condition       # Custom failure criteria
  changed_when: custom_change_condition       # Custom change detection
  ignore_errors: yes                         # Continue on failure
  become: yes                                 # Task-level privilege escalation
  become_user: specific_user                  # Task-level escalation user
  delegate_to: other_host                     # Execute on different host
  run_once: yes                               # Execute only once in batch
  tags:                                       # Task tags
    - tag1
    - tag2
  notify:                                     # Trigger handlers
    - handler_name
```

### Fully Qualified Collection Names (FQCN)

**Modern Ansible Requirement**: All modules must use FQCN format

```yaml
# Correct - FQCN format
tasks:
  - name: Install packages
    ansible.builtin.dnf:          # Not just 'dnf'
      name: httpd
      state: present

  - name: Configure firewall
    ansible.posix.firewalld:      # Not just 'firewalld'
      service: http
      permanent: yes
      state: enabled

  - name: Create partition
    community.general.parted:     # Not just 'parted'
      device: /dev/sdb
      number: 1
      state: present
```

**Essential FQCN Module Categories**:

| Category | Collection | Example Modules |
|----------|------------|-----------------|
| **Core System** | `ansible.builtin` | `dnf`, `systemd`, `copy`, `file`, `user` |
| **POSIX Tools** | `ansible.posix` | `firewalld`, `mount`, `seboolean`, `authorized_key` |
| **Extended** | `community.general` | `parted`, `lvg`, `lvol`, `htpasswd` |

### Common Module Patterns

**Package Management**:

```yaml
- name: Install single package
  ansible.builtin.dnf:
    name: httpd
    state: present

- name: Install multiple packages
  ansible.builtin.dnf:
    name:
      - httpd
      - php
      - mysql-server
    state: present

- name: Install package from specific repository
  ansible.builtin.dnf:
    name: nginx
    state: present
    enablerepo: epel

- name: Update all packages
  ansible.builtin.dnf:
    name: '*'
    state: latest
```

**Service Management**:

```yaml
- name: Start and enable service
  ansible.builtin.systemd:
    name: httpd
    state: started
    enabled: yes
    daemon_reload: yes

- name: Restart service
  ansible.builtin.systemd:
    name: httpd
    state: restarted

- name: Stop and disable service
  ansible.builtin.systemd:
    name: httpd
    state: stopped
    enabled: no
```

**File Operations**:

```yaml
- name: Copy file to remote host
  ansible.builtin.copy:
    src: /local/path/file.txt
    dest: /remote/path/file.txt
    owner: root
    group: root
    mode: '0644'
    backup: yes

- name: Create directory
  ansible.builtin.file:
    path: /path/to/directory
    state: directory
    mode: '0755'
    owner: apache
    group: apache

- name: Create symbolic link
  ansible.builtin.file:
    src: /path/to/source
    dest: /path/to/link
    state: link

- name: Remove file or directory
  ansible.builtin.file:
    path: /path/to/remove
    state: absent
```

**User Management**:

```yaml
- name: Create user account
  ansible.builtin.user:
    name: webuser
    groups:
      - apache
      - wheel
    shell: /bin/bash
    create_home: yes
    state: present

- name: Set user password
  ansible.builtin.user:
    name: webuser
    password: "{{ 'plaintext_password' | password_hash('sha512') }}"
    update_password: always
```

---

## 🔄 Handlers

### Handler Concepts

**Purpose**: Execute tasks only when notified by changed tasks
**Common Use Cases**:

- Restart services after configuration changes
- Reload configurations
- Run cleanup tasks

### Handler Syntax

```yaml
---
- name: Configure web service
  hosts: webservers
  become: yes
  tasks:
    - name: Install Apache
      ansible.builtin.dnf:
        name: httpd
        state: present
      notify: start apache

    - name: Copy configuration file
      ansible.builtin.copy:
        src: httpd.conf
        dest: /etc/httpd/conf/httpd.conf
        backup: yes
      notify:
        - restart apache
        - reload firewall

  handlers:
    - name: start apache
      ansible.builtin.systemd:
        name: httpd
        state: started
        enabled: yes

    - name: restart apache
      ansible.builtin.systemd:
        name: httpd
        state: restarted

    - name: reload firewall
      ansible.builtin.systemd:
        name: firewalld
        state: reloaded
```

### Handler Execution Rules

**Key Behaviors**:

- Handlers run at the end of each play
- Handlers only run if notified by a changed task
- Each handler runs only once, even if notified multiple times
- Handlers run in the order defined, not notification order
- Failed tasks prevent handler execution

**Force Handler Execution**:

```yaml
- name: Force handlers to run immediately
  ansible.builtin.meta: flush_handlers
```

### Advanced Handler Patterns

```yaml
---
- name: Multi-service configuration
  hosts: all
  become: yes
  tasks:
    - name: Update web server config
      ansible.builtin.template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: restart web services

    - name: Update database config  
      ansible.builtin.template:
        src: mysql.cnf.j2
        dest: /etc/mysql/mysql.conf.d/custom.cnf
      notify: restart database services

  handlers:
    - name: restart web services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: restarted
      loop:
        - httpd
        - php-fpm

    - name: restart database services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: restarted
      loop:
        - mysql
        - redis
```

---

## 🏷️ Tags for Task Organization

### Tag Usage

**Purpose**: Selective task execution without running entire playbook

```yaml
---
- name: Complete system setup
  hosts: all
  become: yes
  tasks:
    - name: Install packages
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - mysql-server
        - php
      tags:
        - packages
        - install

    - name: Configure services
      ansible.builtin.template:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
      loop:
        - {src: httpd.conf.j2, dest: /etc/httpd/conf/httpd.conf}
        - {src: mysql.cnf.j2, dest: /etc/mysql/mysql.conf.d/custom.cnf}
      tags:
        - config
        - templates

    - name: Start services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: started
        enabled: yes
      loop:
        - httpd
        - mysql
      tags:
        - services
        - start
```

### Tag Execution Options

```bash
# Run only specific tags
ansible-navigator run site.yml --tags "packages,config" --mode stdout

# Skip specific tags
ansible-navigator run site.yml --skip-tags "services" --mode stdout

# List available tags
ansible-navigator run site.yml --list-tags --mode stdout

# Run multiple tag sets
ansible-navigator run site.yml --tags "install" --tags "config" --mode stdout
```

### Special Tags

```yaml
tasks:
  - name: Always run this task
    ansible.builtin.debug:
      msg: "This always executes"
    tags: always

  - name: Never run this task by default
    ansible.builtin.debug:
      msg: "Only runs when explicitly called"
    tags: never
```

---

## 🚨 Error Handling

### Basic Error Control

**Failed When**: Define custom failure conditions

```yaml
- name: Check web service response
  ansible.builtin.uri:
    url: "http://{{ inventory_hostname }}/health"
    method: GET
  register: health_check
  failed_when: 
    - health_check.status != 200
    - "'healthy' not in health_check.content"
```

**Changed When**: Define when tasks register as changed

```yaml
- name: Run application deployment
  ansible.builtin.command: /opt/app/deploy.sh
  register: deploy_result
  changed_when: "'deployed' in deploy_result.stdout"
```

**Ignore Errors**: Continue despite failures

```yaml
- name: Attempt optional configuration
  ansible.builtin.copy:
    src: optional_config.conf
    dest: /etc/app/optional.conf
  ignore_errors: yes
```

### Block Error Handling

```yaml
- name: Web server deployment with error handling
  block:
    - name: Install web server
      ansible.builtin.dnf:
        name: httpd
        state: present

    - name: Start web server
      ansible.builtin.systemd:
        name: httpd
        state: started

    - name: Test web server
      ansible.builtin.uri:
        url: "http://{{ inventory_hostname }}"
        status_code: 200

  rescue:
    - name: Log deployment failure
      ansible.builtin.debug:
        msg: "Web server deployment failed, attempting rollback"

    - name: Stop failed service
      ansible.builtin.systemd:
        name: httpd
        state: stopped
      ignore_errors: yes

    - name: Remove failed installation
      ansible.builtin.dnf:
        name: httpd
        state: absent

  always:
    - name: Clean temporary files
      ansible.builtin.file:
        path: /tmp/deployment.*
        state: absent
```

---

## 🧪 Playbook Testing and Execution

### Syntax Validation

```bash
# Check playbook syntax
ansible-navigator run site.yml --syntax-check

# Validate without execution
ansible-navigator run site.yml --check --mode stdout

# Show what would change
ansible-navigator run site.yml --check --diff --mode stdout
```

### Execution Modes

```bash
# Standard execution
ansible-navigator run site.yml --mode stdout

# Verbose output
ansible-navigator run site.yml --mode stdout -v

# Maximum verbosity for debugging
ansible-navigator run site.yml --mode stdout -vvv

# Interactive TUI mode
ansible-navigator run site.yml

# Limit to specific hosts
ansible-navigator run site.yml --limit webservers --mode stdout

# Start at specific task
ansible-navigator run site.yml --start-at-task "Configure Apache" --mode stdout
```

### Testing Workflow

**Recommended Test Sequence**:

```bash
# 1. Syntax check
ansible-navigator run site.yml --syntax-check

# 2. Dry run
ansible-navigator run site.yml --check --mode stdout

# 3. Limited execution (single host)
ansible-navigator run site.yml --limit web01 --mode stdout

# 4. Full execution
ansible-navigator run site.yml --mode stdout

# 5. Idempotency test (should show no changes)
ansible-navigator run site.yml --mode stdout
```

---

## 🧪 Practical Lab Exercises

### Exercise 1: Basic Playbook Creation

**Create a playbook that:**

1. Installs Apache web server
2. Copies a custom index.html file  
3. Starts and enables the service
4. Uses a handler to restart on config change

```yaml
---
- name: Web server setup
  hosts: webservers
  become: yes
  tasks:
    - name: Install Apache
      ansible.builtin.dnf:
        name: httpd
        state: present
      notify: start apache

    - name: Copy index page
      ansible.builtin.copy:
        content: |
          <html>
          <head><title>Welcome</title></head>
          <body><h1>Ansible Managed Server</h1></body>
          </html>
        dest: /var/www/html/index.html
        owner: apache
        group: apache
        mode: '0644'

    - name: Configure firewall
      ansible.posix.firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

  handlers:
    - name: start apache
      ansible.builtin.systemd:
        name: httpd
        state: started
        enabled: yes
```

### Exercise 2: Error Handling Practice

**Create a playbook with:**

1. Block/rescue/always structure
2. Custom failed_when conditions
3. Ignore_errors usage
4. Proper error recovery

### Exercise 3: Multi-Play Workflow

**Create a multi-play playbook that:**

1. Configures database servers (first play)
2. Configures web servers (second play)  
3. Configures load balancers (third play)
4. Uses facts from previous plays

### Exercise 4: Tag Organization

**Create a comprehensive playbook with:**

1. Install, configure, and service tags
2. Environment-specific tags (dev, prod)
3. Practice selective execution

---

## 🎯 Key Takeaways

### Playbook Structure Mastery

- **YAML syntax**: Proper indentation and quoting
- **Play organization**: Logical grouping of related tasks
- **FQCN requirement**: Always use fully qualified collection names
- **Documentation**: Clear, descriptive names for plays and tasks

### Task Design Principles  

- **Idempotency**: Tasks should be safe to run repeatedly
- **Atomicity**: Each task should accomplish one specific goal
- **Clarity**: Task names should clearly describe the action
- **Error handling**: Anticipate and handle failure scenarios

### Handler Usage

- **Event-driven**: Only run when notified by changed tasks
- **Service management**: Ideal for service restarts and reloads
- **Execution timing**: Understand when handlers run
- **Notification patterns**: Multiple tasks can notify same handler

### Testing Best Practices

- **Syntax validation**: Always check syntax before execution
- **Dry run testing**: Use --check mode to validate logic
- **Limited testing**: Test on single host before full deployment
- **Idempotency verification**: Run twice to ensure no unexpected changes

---

## 🔗 Next Steps

With solid playbook skills established, you're ready to advance to:

1. **[Module 03: Variables & Facts](03_variables_facts.md)** - Dynamic playbooks with variables
2. **Dynamic content** with variable substitution and fact usage
3. **Complex logic** with variable precedence and scoping
4. **Data-driven automation** using external variable sources

Your playbook foundation will support all advanced Ansible features!

---

**Next Module**: [Module 03: Variables & Facts](03_variables_facts.md) →
