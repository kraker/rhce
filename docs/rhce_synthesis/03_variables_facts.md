# Module 03: Variables & Facts

## 🎯 Learning Objectives

By the end of this module, you will:
- Understand variable types, scoping, and precedence rules
- Master fact gathering and utilization in playbooks
- Organize variables using host_vars and group_vars
- Use magic variables for advanced automation logic
- Register task outputs for use in subsequent tasks
- Implement variable inheritance and override patterns
- Debug variable content and troubleshoot precedence issues

## 📋 Why Variables Transform Automation

### Static vs Dynamic Playbooks

**Static Approach**: Hard-coded values limit reusability
```yaml
# Limited reusability
- name: Install web server
  ansible.builtin.dnf:
    name: httpd              # Hard-coded package name
    state: present
```

**Dynamic Approach**: Variables enable flexibility
```yaml
# Highly reusable
- name: Install web server
  ansible.builtin.dnf:
    name: "{{ web_package }}" # Variable package name
    state: present
```

### Variable Benefits

- **Flexibility**: Same playbook works across environments
- **Maintainability**: Change values in one place
- **Reusability**: Generic playbooks for multiple scenarios
- **Security**: Sensitive data separation via Ansible Vault

---

## 🔢 Variable Types and Definition

### Variable Naming Rules

**Valid Names**:
- Letters, numbers, and underscores only
- Must start with letter or underscore
- Case-sensitive

```yaml
# Valid variable names
web_package: httpd
db_port: 3306
_private_key: /path/to/key
environment2: production

# Invalid variable names
# 2environment: production    # Cannot start with number
# web-package: httpd          # Cannot contain hyphens
# web package: httpd          # Cannot contain spaces
```

### Variable Definition Locations

**1. Playbook Variables**:
```yaml
---
- name: Web server setup
  hosts: webservers
  vars:
    web_package: httpd
    web_port: 80
    web_user: apache
  tasks:
    - name: Install {{ web_package }}
      ansible.builtin.dnf:
        name: "{{ web_package }}"
        state: present
```

**2. External Variable Files**:
```yaml
# vars/web_vars.yml
---
web_package: httpd
web_port: 80
web_service: httpd
web_config_dir: /etc/httpd/conf
web_document_root: /var/www/html

# Playbook usage
---
- name: Web server setup
  hosts: webservers
  vars_files:
    - vars/web_vars.yml
  tasks:
    - name: Install web server
      ansible.builtin.dnf:
        name: "{{ web_package }}"
        state: present
```

**3. Command Line Variables**:
```bash
# Override variables at runtime
ansible-navigator run site.yml -e "web_port=8080" --mode stdout
ansible-navigator run site.yml -e "env=production" --mode stdout
ansible-navigator run site.yml -e "@vars/production.yml" --mode stdout
```

**4. Host Variables** (`host_vars/hostname.yml`):
```yaml
# host_vars/web01.example.com.yml
---
web_port: 8080
max_clients: 150
ssl_enabled: true
custom_modules:
  - mod_ssl
  - mod_rewrite
```

**5. Group Variables** (`group_vars/groupname.yml`):
```yaml
# group_vars/webservers.yml
---
web_package: httpd
web_service: httpd
web_port: 80
document_root: /var/www/html

# group_vars/production.yml
---
environment: production
backup_enabled: true
monitoring: true
log_level: warn
```

**6. Inventory Variables**:
```ini
# INI format
[webservers]
web01.example.com web_port=8080 ssl_enabled=yes
web02.example.com web_port=80 ssl_enabled=no

[webservers:vars]
web_package=httpd
web_service=httpd
```

```yaml
# YAML format
all:
  children:
    webservers:
      hosts:
        web01.example.com:
          web_port: 8080
          ssl_enabled: yes
        web02.example.com:
          web_port: 80
          ssl_enabled: no
      vars:
        web_package: httpd
        web_service: httpd
```

### Variable Data Types

**Strings**:
```yaml
server_name: web01.example.com
config_path: "/etc/httpd/conf/httpd.conf"
message: 'Single quotes preserve content literally'
```

**Numbers**:
```yaml
web_port: 80
max_connections: 1000
timeout: 30.5
```

**Booleans**:
```yaml
ssl_enabled: true
debug_mode: false
backup_enabled: yes    # Ansible converts to boolean
maintenance: no        # Ansible converts to boolean
```

**Lists**:
```yaml
packages:
  - httpd
  - php
  - mysql-server

ports: [80, 443, 8080]

users:
  - name: alice
    shell: /bin/bash
  - name: bob
    shell: /bin/zsh
```

**Dictionaries**:
```yaml
database:
  host: db.example.com
  port: 3306
  name: webapp
  user: appuser

# Alternative syntax
database: {host: db.example.com, port: 3306, name: webapp}
```

---

## 📊 Variable Precedence (16 Levels)

### Complete Precedence Hierarchy

**Higher number = Higher precedence**

1. **role defaults** (lowest precedence)
2. **inventory file or script group vars**
3. **inventory group_vars/all**
4. **playbook group_vars/all**
5. **inventory group_vars/***
6. **playbook group_vars/***
7. **inventory file or script host vars**
8. **inventory host_vars/***
9. **playbook host_vars/***
10. **host facts / cached set_facts**
11. **play vars**
12. **play vars_prompt**
13. **play vars_files**
14. **role vars (defined in role/vars/main.yml)**
15. **block vars (only for tasks in block)**
16. **task vars (only for the specific task)**
17. **include_vars**
18. **set_facts / registered vars**
19. **role (and include_role) params**
20. **include params**
21. **extra vars** (`ansible-navigator run -e`) **(highest precedence)**

### Practical Precedence Examples

**Scenario**: Same variable defined at multiple levels

```yaml
# group_vars/all.yml (precedence 3)
web_port: 80

# host_vars/web01.example.com.yml (precedence 8)
web_port: 8080

# play vars (precedence 11)
---
- name: Configure web server
  hosts: web01.example.com
  vars:
    web_port: 443
  tasks:
    - name: Show final port value
      ansible.builtin.debug:
        var: web_port          # Will show 443 (play vars win)
```

**Command Line Override** (highest precedence):
```bash
# Command line variables always win
ansible-navigator run site.yml -e "web_port=9090" --mode stdout
# web_port will be 9090 regardless of other definitions
```

### Testing Variable Precedence

```yaml
---
- name: Variable precedence demonstration
  hosts: all
  vars:
    test_var: "from play vars"
  tasks:
    - name: Show variable from multiple sources
      ansible.builtin.debug:
        msg: |
          test_var value: {{ test_var }}
          Source: {{ test_var_source | default('unknown') }}

    - name: Set task-level variable
      ansible.builtin.debug:
        var: test_var
      vars:
        test_var: "from task vars"    # This wins over play vars
```

---

## 🔍 Facts (System Information)

### Understanding Facts

**What are Facts?**: Automatically gathered system information including:
- Operating system details
- Hardware information
- Network configuration
- Filesystem information
- Service status

### Fact Gathering Control

```yaml
---
- name: Control fact gathering
  hosts: all
  gather_facts: yes          # Default behavior
  tasks:
    - name: Manual fact gathering
      ansible.builtin.setup:  # Equivalent to automatic gathering

# Disable automatic fact gathering
- name: Skip fact gathering
  hosts: all
  gather_facts: no
  tasks:
    - name: Gather facts only when needed
      ansible.builtin.setup:
      when: gather_system_info | default(false)
```

### Essential Facts

**System Information**:
```yaml
- name: Display system facts
  ansible.builtin.debug:
    msg: |
      OS: {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}
      Architecture: {{ ansible_facts['architecture'] }}
      Kernel: {{ ansible_facts['kernel'] }}
      Python: {{ ansible_facts['python_version'] }}
      Hostname: {{ ansible_facts['hostname'] }}
      FQDN: {{ ansible_facts['fqdn'] }}
```

**Hardware Facts**:
```yaml
- name: Display hardware facts
  ansible.builtin.debug:
    msg: |
      Memory: {{ ansible_facts['memtotal_mb'] }} MB
      Processors: {{ ansible_facts['processor_count'] }}
      CPU: {{ ansible_facts['processor'][0] }}
      Virtualization: {{ ansible_facts['virtualization_type'] | default('none') }}
```

**Network Facts**:
```yaml
- name: Display network facts
  ansible.builtin.debug:
    msg: |
      Default IP: {{ ansible_facts['default_ipv4']['address'] }}
      Default Interface: {{ ansible_facts['default_ipv4']['interface'] }}
      All IPs: {{ ansible_facts['all_ipv4_addresses'] | join(', ') }}
      Hostname: {{ ansible_facts['fqdn'] }}
```

**Storage Facts**:
```yaml
- name: Display storage facts
  ansible.builtin.debug:
    msg: |
      Disks: {{ ansible_facts['devices'].keys() | list | join(', ') }}
      Root filesystem: {{ ansible_facts['mounts'] | selectattr('mount', 'equalto', '/') | first }}
      Available space: {{ ansible_facts['mounts'] | selectattr('mount', 'equalto', '/') | map(attribute='size_available') | first }}
```

### Fact Filtering

```bash
# Gather specific fact subsets
ansible all -m setup -a "filter=ansible_distribution*"
ansible all -m setup -a "filter=ansible_default_ipv4"
ansible all -m setup -a "filter=ansible_mounts"

# Gather only essential facts
ansible all -m setup -a "gather_subset=hardware,network"

# Exclude specific fact subsets
ansible all -m setup -a "gather_subset=all,!facter,!ohai"
```

### Custom Facts

**Local Facts Directory**: `/etc/ansible/facts.d/`

```bash
# Create custom fact script
sudo mkdir -p /etc/ansible/facts.d
sudo cat > /etc/ansible/facts.d/application.fact << 'EOF'
#!/bin/bash
echo '{
  "app_name": "myapp",
  "version": "1.2.3",
  "config_path": "/opt/myapp/config",
  "data_path": "/var/lib/myapp"
}'
EOF
sudo chmod +x /etc/ansible/facts.d/application.fact
```

**Using Custom Facts**:
```yaml
- name: Use custom facts
  ansible.builtin.debug:
    msg: |
      App: {{ ansible_facts['local']['application']['app_name'] }}
      Version: {{ ansible_facts['local']['application']['version'] }}
```

---

## 🔮 Magic Variables

### Built-in Magic Variables

**Inventory Variables**:
```yaml
- name: Display inventory information
  ansible.builtin.debug:
    msg: |
      Current host: {{ inventory_hostname }}
      Short hostname: {{ inventory_hostname_short }}
      Groups this host belongs to: {{ group_names | join(', ') }}
      All groups: {{ groups.keys() | list | join(', ') }}
      Webserver hosts: {{ groups['webservers'] | default([]) | join(', ') }}
```

**Play Variables**:
```yaml
- name: Display play information
  ansible.builtin.debug:
    msg: |
      Hosts in current play: {{ play_hosts | join(', ') }}
      Current batch: {{ ansible_play_batch | join(', ') }}
      Play name: {{ ansible_play_name | default('unnamed') }}
```

**Hostvars Access**:
```yaml
- name: Access other host variables
  ansible.builtin.debug:
    msg: |
      Web01 IP: {{ hostvars['web01.example.com']['ansible_default_ipv4']['address'] }}
      Database host: {{ hostvars[groups['databases'][0]]['ansible_fqdn'] }}
      All web server IPs: {% for host in groups['webservers'] %}{{ hostvars[host]['ansible_default_ipv4']['address'] }}{% if not loop.last %}, {% endif %}{% endfor %}
```

### Advanced Magic Variable Usage

**Cross-Host Information Sharing**:
```yaml
---
- name: Collect information from all hosts
  hosts: all
  tasks:
    - name: Register hostname info
      ansible.builtin.set_fact:
        server_info:
          hostname: "{{ inventory_hostname }}"
          ip: "{{ ansible_default_ipv4.address }}"
          role: "{{ server_role | default('unknown') }}"

- name: Configure load balancer with all server info
  hosts: loadbalancers
  tasks:
    - name: Generate backend configuration
      ansible.builtin.template:
        src: backends.conf.j2
        dest: /etc/haproxy/backends.conf
      vars:
        backend_servers: |
          {% for host in groups['webservers'] %}
          server {{ hostvars[host]['inventory_hostname_short'] }} {{ hostvars[host]['ansible_default_ipv4']['address'] }}:80 check
          {% endfor %}
```

---

## 📝 Registering Variables

### Basic Registration

```yaml
---
- name: Variable registration examples
  hosts: all
  tasks:
    - name: Check service status
      ansible.builtin.systemd:
        name: httpd
      register: service_status

    - name: Display service information
      ansible.builtin.debug:
        msg: |
          Service active: {{ service_status.status.ActiveState }}
          Service enabled: {{ service_status.status.UnitFileState }}
          Service running: {{ service_status.status.SubState }}
```

### Command Registration

```yaml
- name: Execute command and capture output
  ansible.builtin.command: whoami
  register: current_user

- name: Execute shell command with pipes
  ansible.builtin.shell: ps aux | grep httpd | wc -l
  register: httpd_processes

- name: Display command results
  ansible.builtin.debug:
    msg: |
      Current user: {{ current_user.stdout }}
      Apache processes: {{ httpd_processes.stdout }}
      Return code: {{ current_user.rc }}
      Command failed: {{ current_user.failed }}
```

### Advanced Registration Patterns

**Conditional Logic Based on Registration**:
```yaml
- name: Check web service availability
  ansible.builtin.uri:
    url: "http://{{ inventory_hostname }}/health"
    method: GET
    status_code: [200, 503]
  register: health_check
  ignore_errors: yes

- name: Restart service if unhealthy
  ansible.builtin.systemd:
    name: httpd
    state: restarted
  when: health_check.status == 503

- name: Report service status
  ansible.builtin.debug:
    msg: |
      Health check status: {{ health_check.status }}
      Service is {{ 'healthy' if health_check.status == 200 else 'unhealthy' }}
```

**Loop Registration**:
```yaml
- name: Check multiple services
  ansible.builtin.systemd:
    name: "{{ item }}"
  register: service_results
  loop:
    - httpd
    - mysql
    - sshd

- name: Display all service states
  ansible.builtin.debug:
    msg: "{{ item.item }} is {{ item.status.ActiveState }}"
  loop: "{{ service_results.results }}"
```

---

## 🗂️ Variable Organization Strategies

### Directory Structure

```
inventory/
├── group_vars/
│   ├── all.yml                 # Variables for all hosts
│   ├── webservers.yml         # Web server group variables
│   ├── databases.yml          # Database group variables
│   └── production/            # Environment-specific variables
│       ├── all.yml
│       ├── webservers.yml
│       └── databases.yml
├── host_vars/
│   ├── web01.example.com.yml
│   ├── web02.example.com.yml
│   └── db01.example.com.yml
└── inventory.yml
```

### Variable Organization Best Practices

**Environment Separation**:
```yaml
# group_vars/all/common.yml
---
app_name: myapp
app_user: webapp
log_level: info

# group_vars/all/development.yml
---
environment: development
debug_enabled: true
log_level: debug
database_host: dev-db.internal.com

# group_vars/all/production.yml
---
environment: production
debug_enabled: false
log_level: warn
database_host: prod-db.internal.com
```

**Service-Specific Variables**:
```yaml
# group_vars/webservers/apache.yml
---
apache:
  package: httpd
  service: httpd
  config_dir: /etc/httpd/conf
  document_root: /var/www/html
  modules:
    - mod_ssl
    - mod_rewrite
  ports:
    - 80
    - 443

# group_vars/databases/mysql.yml
---
mysql:
  package: mysql-server
  service: mysqld
  config_file: /etc/my.cnf
  data_dir: /var/lib/mysql
  port: 3306
  root_password: "{{ vault_mysql_root_password }}"
```

### Variable Validation

```yaml
---
- name: Validate required variables
  hosts: all
  tasks:
    - name: Ensure required variables are defined
      ansible.builtin.assert:
        that:
          - app_name is defined
          - environment is defined
          - database_host is defined
        fail_msg: "Required variables are not defined"
        success_msg: "All required variables are present"

    - name: Validate variable values
      ansible.builtin.assert:
        that:
          - environment in ['development', 'staging', 'production']
          - app_port | int > 1024
          - database_host | length > 0
        fail_msg: "Variable validation failed"
```

---

## 🛠️ Variable Debugging

### Debug Strategies

**Basic Variable Display**:
```yaml
- name: Debug variable content
  ansible.builtin.debug:
    var: variable_name

- name: Debug with custom message
  ansible.builtin.debug:
    msg: "The value of web_port is {{ web_port }}"

- name: Debug multiple variables
  ansible.builtin.debug:
    msg: |
      Environment: {{ environment }}
      Web port: {{ web_port }}
      SSL enabled: {{ ssl_enabled }}
```

**Fact Exploration**:
```yaml
- name: Display all facts
  ansible.builtin.debug:
    var: ansible_facts

- name: Display specific fact categories
  ansible.builtin.debug:
    var: ansible_facts['network']

- name: Search facts by pattern
  ansible.builtin.debug:
    msg: "{{ ansible_facts | dict2items | selectattr('key', 'match', 'ansible_eth.*') | list }}"
```

**Variable Source Investigation**:
```yaml
- name: Check if variable is defined
  ansible.builtin.debug:
    msg: "web_port is {{ 'defined' if web_port is defined else 'undefined' }}"

- name: Show variable type
  ansible.builtin.debug:
    msg: "web_port is of type {{ web_port | type_debug }}"

- name: Display hostvars for debugging
  ansible.builtin.debug:
    var: hostvars[inventory_hostname]
```

---

## 🧪 Practical Lab Exercises

### Exercise 1: Variable Precedence Testing

**Create a comprehensive precedence test:**

1. Define the same variable at multiple levels
2. Use debug tasks to show final values
3. Override with command-line variables
4. Document the results

```yaml
# group_vars/all.yml
test_var: "from group_vars all"

# host_vars/testhost.yml  
test_var: "from host_vars"

# Playbook
---
- name: Variable precedence test
  hosts: testhost
  vars:
    test_var: "from play vars"
  tasks:
    - name: Show variable value
      ansible.builtin.debug:
        var: test_var
      vars:
        test_var: "from task vars"
```

### Exercise 2: Fact-Based Configuration

**Create environment-specific configuration using facts:**

```yaml
---
- name: Configure based on system facts
  hosts: all
  tasks:
    - name: Install appropriate packages for OS
      ansible.builtin.dnf:
        name: "{{ packages[ansible_facts['distribution'] | lower] }}"
        state: present
      vars:
        packages:
          redhat:
            - httpd
            - php
          centos:
            - httpd
            - php
          fedora:
            - httpd
            - php
```

### Exercise 3: Cross-Host Information Sharing

**Build configuration files using information from multiple hosts:**

```yaml
---
- name: Gather web server information
  hosts: webservers
  tasks:
    - name: Set web server facts
      ansible.builtin.set_fact:
        web_server_info:
          name: "{{ inventory_hostname }}"
          ip: "{{ ansible_default_ipv4.address }}"
          port: "{{ web_port | default(80) }}"

- name: Configure load balancer
  hosts: loadbalancers
  tasks:
    - name: Generate load balancer config
      ansible.builtin.template:
        src: haproxy.cfg.j2
        dest: /etc/haproxy/haproxy.cfg
```

### Exercise 4: Dynamic Variable Loading

**Load variables based on conditions:**

```yaml
---
- name: Dynamic variable loading
  hosts: all
  tasks:
    - name: Load environment-specific variables
      ansible.builtin.include_vars: "vars/{{ environment }}.yml"
      
    - name: Load OS-specific variables
      ansible.builtin.include_vars: "vars/{{ ansible_facts['distribution'] | lower }}.yml"
```

---

## 🎯 Key Takeaways

### Variable Management Excellence
- **Precedence understanding**: Know which variable definitions take priority
- **Organization strategy**: Use logical directory structures for variables
- **Data typing**: Understand how Ansible handles different data types
- **Validation**: Always validate critical variables before use

### Fact Utilization Mastery
- **System intelligence**: Use facts to make decisions about configuration
- **Performance consideration**: Disable fact gathering when not needed
- **Custom facts**: Extend system information with application-specific data
- **Fact filtering**: Gather only needed information for efficiency

### Magic Variable Proficiency
- **Inventory access**: Use magic variables to access host and group information
- **Cross-host communication**: Share data between hosts using hostvars
- **Play context**: Understand play-level variables and their scope
- **Dynamic targeting**: Use magic variables for dynamic host selection

### Registration and Debugging Skills
- **Output capture**: Register command and module outputs for later use
- **Conditional logic**: Make decisions based on registered results
- **Debugging techniques**: Efficiently troubleshoot variable issues
- **Testing strategies**: Validate variable behavior during development

---

## 🔗 Next Steps

With solid variable and fact mastery, you're ready for:

1. **[Module 04: Task Control](04_task_control.md)** - Advanced logic with conditionals and loops
2. **Complex automation logic** using when statements and loops
3. **Error handling strategies** with blocks and failure management
4. **Advanced task delegation** and execution control

Your variable skills enable sophisticated automation scenarios!

---

**Next Module**: [Module 04: Task Control](04_task_control.md) →
