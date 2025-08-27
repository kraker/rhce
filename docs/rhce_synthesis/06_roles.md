# Module 06: Roles & Collections

## 🎯 Learning Objectives

By the end of this module, you will:

- Design and create Ansible roles for code reusability and organization
- Understand role structure and best practices for maintainable automation
- Master role dependencies and variable handling within roles
- Install and use Ansible Galaxy for role and collection management
- Work with Ansible Collections and use FQCN (Fully Qualified Collection Names)
- Create custom collections and understand collection distribution
- Integrate roles and collections into complex automation workflows

## 📋 Why Roles Transform Automation Architecture

### Playbook Limitations vs Role Benefits

**Large Playbook Problems**:

- Difficult to maintain and debug
- Hard to reuse across projects
- Variables and tasks become unorganized
- Testing becomes complex

**Role-Based Solutions**:

- **Modular Design**: Each role handles a specific function
- **Reusability**: Same role works across multiple projects
- **Organization**: Clear structure with defined variable locations
- **Testing**: Individual roles can be tested independently
- **Collaboration**: Teams can work on different roles simultaneously

### Role Architecture Benefits

```
Without Roles: Monolithic Playbook
├── site.yml (500+ lines)
└── Everything mixed together

With Roles: Modular Architecture
├── site.yml (20 lines)
├── roles/
│   ├── common/          # Base system setup
│   ├── web/            # Web server configuration
│   ├── database/       # Database setup
│   └── monitoring/     # Monitoring tools
└── Clean separation of concerns
```

---

## 🏗️ Role Structure and Organization

### Standard Role Directory Structure

```
roles/
└── rolename/
    ├── defaults/
    │   └── main.yml          # Default variables (lowest precedence)
    ├── files/
    │   └── static_file.txt   # Static files for copy module
    ├── handlers/
    │   └── main.yml          # Handler definitions
    ├── meta/
    │   └── main.yml          # Role metadata and dependencies
    ├── tasks/
    │   └── main.yml          # Main task list (entry point)
    ├── templates/
    │   └── config.j2         # Jinja2 templates
    ├── tests/
    │   ├── inventory         # Test inventory
    │   └── test.yml          # Test playbook
    └── vars/
        └── main.yml          # Role variables (high precedence)
```

### Role Creation with ansible-galaxy

```bash
# Create new role structure
ansible-galaxy init my_web_role

# Create role in specific directory
ansible-galaxy init roles/apache_server

# Create role with custom template
ansible-galaxy init --role-skeleton=custom_template my_role

# Verify role structure
tree roles/my_web_role/
```

### Role Metadata (meta/main.yml)

```yaml
---
galaxy_info:
  author: Your Name
  description: Apache web server configuration role
  company: Your Organization
  
  license: MIT
  
  min_ansible_version: 2.9
  
  platforms:
    - name: EL
      versions:
        - 8
        - 9
    - name: Ubuntu
      versions:
        - 18.04
        - 20.04
        - 22.04
  
  galaxy_tags:
    - web
    - apache
    - httpd
    - server

dependencies:
  - role: common
    vars:
      firewall_enabled: true
  - role: security
    when: environment == "production"
```

---

## 🎯 Role Development Best Practices

### Task Organization (tasks/main.yml)

```yaml
---
# tasks/main.yml - Main task entry point

- name: Include OS-specific variables
  ansible.builtin.include_vars: "{{ ansible_facts['distribution'] | lower }}.yml"

- name: Include pre-tasks
  ansible.builtin.include_tasks: pre_tasks.yml

- name: Install packages
  ansible.builtin.include_tasks: install.yml

- name: Configure service
  ansible.builtin.include_tasks: configure.yml

- name: Start services
  ansible.builtin.include_tasks: services.yml

- name: Include post-tasks
  ansible.builtin.include_tasks: post_tasks.yml
  when: run_post_tasks | default(true)
```

### Modular Task Files

**tasks/install.yml**:

```yaml
---
- name: Install web server package
  ansible.builtin.package:
    name: "{{ web_package_name }}"
    state: present
  become: yes

- name: Install additional packages
  ansible.builtin.package:
    name: "{{ item }}"
    state: present
  loop: "{{ additional_packages | default([]) }}"
  become: yes

- name: Create web user
  ansible.builtin.user:
    name: "{{ web_user }}"
    group: "{{ web_group }}"
    shell: /sbin/nologin
    home: "{{ web_home_dir }}"
    create_home: no
  become: yes
  when: create_web_user | default(true)
```

**tasks/configure.yml**:

```yaml
---
- name: Create configuration directories
  ansible.builtin.file:
    path: "{{ item }}"
    state: directory
    owner: root
    group: root
    mode: '0755'
  loop:
    - "{{ web_config_dir }}"
    - "{{ web_config_dir }}/conf.d"
  become: yes

- name: Deploy main configuration
  ansible.builtin.template:
    src: httpd.conf.j2
    dest: "{{ web_config_file }}"
    owner: root
    group: root
    mode: '0644'
    backup: yes
    validate: "{{ web_binary }} -t -f %s"
  become: yes
  notify: restart web service

- name: Deploy virtual host configurations
  ansible.builtin.template:
    src: vhost.conf.j2
    dest: "{{ web_config_dir }}/conf.d/{{ item.name }}.conf"
    owner: root
    group: root
    mode: '0644'
  loop: "{{ virtual_hosts | default([]) }}"
  become: yes
  notify: restart web service
```

### Variable Organization

**defaults/main.yml** (Default values):

```yaml
---
# Default variables for web role
web_package_name: httpd
web_service_name: httpd
web_user: apache
web_group: apache
web_port: 80
web_ssl_port: 443
web_config_dir: /etc/httpd
web_config_file: /etc/httpd/conf/httpd.conf
web_document_root: /var/www/html
web_binary: httpd

# Feature toggles
ssl_enabled: false
firewall_enabled: true
selinux_enabled: true

# Performance settings
max_clients: 256
keep_alive: true
keep_alive_timeout: 15

# Additional packages (can be overridden)
additional_packages: []

# Virtual hosts (empty by default)
virtual_hosts: []
```

**vars/main.yml** (Role-specific variables):

```yaml
---
# Internal role variables (high precedence)
web_config_template: httpd.conf.j2
web_pid_file: /var/run/httpd/httpd.pid
web_log_dir: /var/log/httpd

# OS-specific package names (can be overridden by os-specific files)
web_packages:
  RedHat: httpd
  Ubuntu: apache2
  Debian: apache2
```

**vars/redhat.yml** (OS-specific variables):

```yaml
---
web_package_name: httpd
web_service_name: httpd
web_user: apache
web_group: apache
web_config_dir: /etc/httpd
web_document_root: /var/www/html
web_binary: httpd
firewall_service_name: firewalld
```

**vars/ubuntu.yml**:

```yaml
---
web_package_name: apache2
web_service_name: apache2
web_user: www-data
web_group: www-data
web_config_dir: /etc/apache2
web_document_root: /var/www/html
web_binary: apache2ctl
firewall_service_name: ufw
```

### Handler Organization (handlers/main.yml)

```yaml
---
- name: restart web service
  ansible.builtin.systemd:
    name: "{{ web_service_name }}"
    state: restarted
  become: yes

- name: reload web service
  ansible.builtin.systemd:
    name: "{{ web_service_name }}"
    state: reloaded
  become: yes

- name: restart firewall
  ansible.builtin.systemd:
    name: "{{ firewall_service_name }}"
    state: restarted
  become: yes
  when: firewall_enabled | default(true)

- name: validate web config
  ansible.builtin.command: "{{ web_binary }} -t"
  become: yes
  changed_when: false

- name: update firewall rules
  ansible.posix.firewalld:
    service: "{{ item }}"
    permanent: yes
    state: enabled
    immediate: yes
  loop:
    - http
    - https
  become: yes
  when: firewall_enabled | default(true)
```

---

## 🔧 Using Roles in Playbooks

### Basic Role Usage

```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  roles:
    - common
    - web
    - monitoring
```

### Role with Variables

```yaml
---
- name: Configure web servers with custom variables
  hosts: webservers
  become: yes
  roles:
    - role: web
      vars:
        web_port: 8080
        ssl_enabled: true
        virtual_hosts:
          - name: example.com
            docroot: /var/www/example
          - name: api.example.com
            docroot: /var/www/api
```

### Conditional Role Usage

```yaml
---
- name: Conditional role application
  hosts: all
  become: yes
  roles:
    - role: common
      when: true  # Always apply common role
      
    - role: web
      when: "'webservers' in group_names"
      
    - role: database
      when: "'databases' in group_names"
      
    - role: monitoring
      when: monitoring_enabled | default(false)
```

### Dynamic Role Selection

```yaml
---
- name: Dynamic role application based on host variables
  hosts: all
  become: yes
  tasks:
    - name: Apply web server role
      ansible.builtin.include_role:
        name: "{{ web_server_type }}"
      vars:
        ssl_enabled: "{{ ssl_required | default(false) }}"
        performance_tuning: "{{ environment == 'production' }}"
      when: "'webservers' in group_names"

    - name: Apply database role
      ansible.builtin.include_role:
        name: "{{ database_engine }}"
      vars:
        backup_enabled: true
        replication_enabled: "{{ environment == 'production' }}"
      when: "'databases' in group_names"
```

---

## 🌟 Ansible Galaxy

### Installing Roles from Galaxy

```bash
# Install specific role
ansible-galaxy install geerlingguy.apache

# Install specific version
ansible-galaxy install geerlingguy.apache,2.0.0

# Install to custom directory
ansible-galaxy install geerlingguy.apache --roles-path ./custom_roles

# Install multiple roles from requirements file
ansible-galaxy install -r requirements.yml

# Force reinstall
ansible-galaxy install geerlingguy.apache --force
```

### Requirements File (requirements.yml)

```yaml
---
roles:
  # Install from Ansible Galaxy
  - name: geerlingguy.apache
    version: 2.0.0
    
  - name: geerlingguy.mysql
    version: ">=3.0.0"
    
  # Install from Git repository
  - src: https://github.com/example/custom-role.git
    name: custom_role
    version: main
    
  # Install from local path
  - src: /path/to/local/role
    name: local_role

collections:
  # Install collections
  - name: community.general
    version: ">=3.0.0"
    
  - name: ansible.posix
    version: "1.3.0"
    
  - name: community.mysql
```

### Role Management Commands

```bash
# List installed roles
ansible-galaxy list

# Show role information
ansible-galaxy info geerlingguy.apache

# Search for roles
ansible-galaxy search apache

# Remove installed role
ansible-galaxy remove geerlingguy.apache

# Install from requirements file
ansible-galaxy install -r requirements.yml

# Update roles to latest versions
ansible-galaxy install -r requirements.yml --force
```

---

## 📦 Ansible Collections

### Understanding Collections

**Collections provide**:

- **Modules**: Task plugins for specific functionality
- **Roles**: Pre-built automation patterns  
- **Plugins**: Extend Ansible capabilities
- **Playbooks**: Example automation workflows

**FQCN (Fully Qualified Collection Names)** required for modules:

```yaml
# Correct - FQCN format
- name: Configure firewall
  ansible.posix.firewalld:    # namespace.collection.module
    service: http
    state: enabled

# Incorrect - short name (deprecated)
- name: Configure firewall  
  firewalld:                  # Will fail in modern Ansible
    service: http
    state: enabled
```

### Essential Collections for RHCE

**ansible.builtin** (Core Modules):

```yaml
tasks:
  - name: Install package
    ansible.builtin.dnf:
      name: httpd
      state: present
      
  - name: Manage service
    ansible.builtin.systemd:
      name: httpd
      state: started
      enabled: yes
      
  - name: Copy file
    ansible.builtin.copy:
      src: index.html
      dest: /var/www/html/
```

**ansible.posix** (POSIX System Tools):

```yaml
tasks:
  - name: Configure firewall
    ansible.posix.firewalld:
      service: http
      permanent: yes
      state: enabled
      
  - name: Mount filesystem
    ansible.posix.mount:
      path: /mnt/data
      src: /dev/sdb1
      fstype: xfs
      state: mounted
      
  - name: Manage SSH keys
    ansible.posix.authorized_key:
      user: ansible
      key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
```

**community.general** (Extended Modules):

```yaml
tasks:
  - name: Create partition
    community.general.parted:
      device: /dev/sdb
      number: 1
      state: present
      
  - name: Create LVM volume group
    community.general.lvg:
      vg: vg_data
      pvs: /dev/sdb1
      
  - name: Create logical volume
    community.general.lvol:
      vg: vg_data
      lv: lv_web
      size: 10G
```

### Installing Collections

```bash
# Install specific collection
ansible-galaxy collection install community.general

# Install specific version
ansible-galaxy collection install community.general:==3.6.0

# Install to custom path
ansible-galaxy collection install community.general --collections-path ./collections

# Install all collections from requirements
ansible-galaxy collection install -r requirements.yml

# List installed collections
ansible-galaxy collection list

# Upgrade collections
ansible-galaxy collection install community.general --upgrade
```

### Collection Directory Structure

```
collections/
└── ansible_collections/
    └── namespace/
        └── collection_name/
            ├── plugins/
            │   ├── modules/
            │   ├── filters/
            │   └── lookup/
            ├── roles/
            ├── playbooks/
            ├── meta/
            │   └── runtime.yml
            └── galaxy.yml
```

---

## 🛠️ Advanced Role Patterns

### Role Dependencies

**meta/main.yml with dependencies**:

```yaml
---
dependencies:
  # Simple dependency
  - role: common
  
  # Dependency with variables
  - role: firewall
    vars:
      firewall_allowed_ports:
        - 80
        - 443
      firewall_allowed_services:
        - ssh
        - http
        - https
  
  # Conditional dependency
  - role: ssl_certificates
    when: ssl_enabled | default(false)
    vars:
      ssl_cert_domains: "{{ virtual_host_domains }}"
  
  # Dependency with tags
  - role: monitoring
    vars:
      monitor_services:
        - "{{ web_service_name }}"
    tags:
      - monitoring
      - health_check
```

### Role Composition Patterns

**Site Playbook (site.yml)**:

```yaml
---
- name: Configure infrastructure
  hosts: all
  become: yes
  roles:
    - role: common
      tags: always

- name: Configure web servers
  hosts: webservers
  become: yes
  roles:
    - role: web
      vars:
        web_ssl_enabled: "{{ ssl_enabled | default(false) }}"
        web_virtual_hosts: "{{ virtual_hosts | default([]) }}"
      tags: web

- name: Configure databases  
  hosts: databases
  become: yes
  roles:
    - role: database
      vars:
        db_backup_enabled: true
        db_replication_enabled: "{{ environment == 'production' }}"
      tags: database

- name: Configure monitoring
  hosts: all
  become: yes
  roles:
    - role: monitoring
      when: monitoring_enabled | default(true)
      tags: monitoring
```

### Dynamic Role Loading

```yaml
---
- name: Dynamic role application
  hosts: all
  tasks:
    - name: Load common role
      ansible.builtin.include_role:
        name: common
      tags: always

    - name: Load server-specific roles
      ansible.builtin.include_role:
        name: "{{ role_item }}"
      loop: "{{ server_roles | default([]) }}"
      loop_control:
        loop_var: role_item
      when: role_item in available_roles

    - name: Load environment-specific roles
      ansible.builtin.include_role:
        name: "{{ environment }}_config"
      when: environment in ['development', 'staging', 'production']
```

---

## 🧪 Role Testing Strategies

### Role Testing Structure

**tests/test.yml**:

```yaml
---
- hosts: localhost
  remote_user: root
  become: yes
  vars:
    # Test-specific variables
    web_port: 8080
    ssl_enabled: false
    virtual_hosts:
      - name: test.example.com
        docroot: /var/www/test
  roles:
    - ../../  # Reference to role directory
    
  post_tasks:
    - name: Verify web service is running
      ansible.builtin.systemd:
        name: "{{ web_service_name }}"
        state: started
      check_mode: yes
      register: service_status
      
    - name: Assert service is active
      ansible.builtin.assert:
        that:
          - service_status.status.ActiveState == "active"
        fail_msg: "Web service is not running"
        
    - name: Test web server response
      ansible.builtin.uri:
        url: "http://localhost:{{ web_port }}"
        status_code: 200
      register: web_response
      
    - name: Verify response
      ansible.builtin.assert:
        that:
          - web_response.status == 200
        fail_msg: "Web server not responding correctly"
```

### Role Validation Playbook

```yaml
---
- name: Validate role deployment
  hosts: all
  become: yes
  tasks:
    - name: Gather service facts
      ansible.builtin.service_facts:

    - name: Verify required services are running
      ansible.builtin.assert:
        that:
          - ansible_facts.services[item + '.service'].state == 'running'
        fail_msg: "Service {{ item }} is not running"
        success_msg: "Service {{ item }} is running correctly"
      loop:
        - "{{ web_service_name }}"
        - "{{ firewall_service_name }}"

    - name: Test port connectivity
      ansible.builtin.wait_for:
        port: "{{ web_port }}"
        host: "{{ ansible_default_ipv4.address }}"
        delay: 1
        timeout: 10
      register: port_test

    - name: Verify configuration files exist
      ansible.builtin.stat:
        path: "{{ item }}"
      register: config_files
      loop:
        - "{{ web_config_file }}"
        - "{{ web_document_root }}/index.html"

    - name: Assert configuration files present
      ansible.builtin.assert:
        that:
          - item.stat.exists
        fail_msg: "Configuration file {{ item.item }} not found"
      loop: "{{ config_files.results }}"
```

---

## 🧪 Practical Lab Exercises

### Exercise 1: Create a Comprehensive Web Server Role

**Requirements**:

1. Support multiple OS distributions (RHEL, Ubuntu)
2. Configure SSL conditionally
3. Deploy virtual hosts from variables
4. Include proper error handling and validation
5. Write tests for the role

### Exercise 2: Database Configuration Role

**Create a role that**:

1. Installs database server (MySQL/PostgreSQL)
2. Configures performance tuning based on available memory
3. Creates databases and users from variables
4. Includes backup configuration
5. Handles security hardening

### Exercise 3: Multi-Tier Application Role

**Design roles for**:

1. Load balancer configuration
2. Application server deployment
3. Database setup with replication
4. Monitoring and logging integration
5. Role dependencies and proper ordering

### Exercise 4: Collection Creation

**Build a custom collection that includes**:

1. Multiple related roles
2. Custom modules for specific tasks
3. Plugins for data manipulation
4. Documentation and examples
5. Galaxy metadata for distribution

---

## 🎯 Key Takeaways

### Role Design Excellence

- **Single responsibility**: Each role should have one clear purpose
- **Parameterization**: Use variables to make roles flexible and reusable
- **Documentation**: Include clear README files and inline comments
- **Testing**: Write tests to validate role functionality

### Organization and Structure

- **Standard layout**: Follow Ansible's standard role directory structure
- **Variable precedence**: Understand how role variables interact with other variable sources
- **Dependencies**: Use role dependencies to ensure proper ordering and prerequisites
- **Modular tasks**: Break complex roles into smaller, manageable task files

### Collection Mastery

- **FQCN usage**: Always use fully qualified collection names for modules
- **Collection installation**: Know how to install and manage collections
- **Collection organization**: Understand how collections organize related automation content
- **Requirements management**: Use requirements.yml for reproducible environments

### Best Practices

- **Version control**: Track roles and requirements files in version control
- **Environment consistency**: Use the same collection versions across environments
- **Performance**: Consider role execution performance in large deployments
- **Security**: Handle sensitive data appropriately within roles

---

## 🔗 Next Steps

With role and collection expertise, you're ready for:

1. **[Module 07: System Administration Tasks](07_system_administration.md)** - Apply roles to real system administration scenarios
2. **Enterprise automation** using role-based architecture
3. **Complex deployments** with multiple interacting roles
4. **Automation at scale** using collection-based organization

Your role mastery enables sophisticated, maintainable automation!

---

**Next Module**: [Module 07: System Administration Tasks](07_system_administration.md) →
