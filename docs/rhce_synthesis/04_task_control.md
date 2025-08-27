# Module 04: Task Control

## 🎯 Learning Objectives

By the end of this module, you will:

- Master conditional execution using when statements and complex logic
- Implement loops for efficient repetitive tasks and data processing
- Design comprehensive error handling strategies with blocks
- Control task execution flow with delegation and run strategies
- Use advanced task control features like throttling and batching
- Debug and troubleshoot complex task control scenarios

## 📋 Why Task Control Matters

### Linear vs Intelligent Automation

**Basic Approach**: All tasks run in sequence on all hosts

```yaml
# Limited flexibility
- name: Install package
  ansible.builtin.dnf:
    name: httpd
    state: present
    # Runs on ALL hosts regardless of need
```

**Advanced Approach**: Intelligent execution based on conditions

```yaml
# Conditional and intelligent
- name: Install web server package
  ansible.builtin.dnf:
    name: "{{ web_packages[ansible_facts['distribution'] | lower] }}"
    state: present
  when: "'webservers' in group_names"
  # Only runs on web servers with appropriate packages
```

### Task Control Benefits

- **Efficiency**: Run tasks only when necessary
- **Reliability**: Handle errors gracefully without stopping automation
- **Scalability**: Process large datasets with loops
- **Flexibility**: Adapt behavior based on runtime conditions

---

## ❓ Conditional Execution (when)

### Basic When Statements

**Simple Conditions**:

```yaml
---
- name: Conditional task examples
  hosts: all
  tasks:
    - name: Install Apache on Red Hat systems
      ansible.builtin.dnf:
        name: httpd
        state: present
      when: ansible_facts['distribution'] == "RedHat"

    - name: Install Apache on Ubuntu systems
      ansible.builtin.apt:
        name: apache2
        state: present
      when: ansible_facts['distribution'] == "Ubuntu"

    - name: Configure firewall on RHEL 8+
      ansible.posix.firewalld:
        service: http
        permanent: yes
        state: enabled
      when: 
        - ansible_facts['distribution'] == "RedHat"
        - ansible_facts['distribution_major_version'] | int >= 8
```

### Complex Conditional Logic

**Boolean Logic**:

```yaml
- name: Complex conditional examples
  hosts: all
  tasks:
    # AND logic (all conditions must be true)
    - name: Install development tools
      ansible.builtin.dnf:
        name: "@Development Tools"
        state: present
      when:
        - ansible_facts['distribution'] == "RedHat"
        - environment == "development"
        - install_dev_tools | default(false)

    # OR logic (any condition can be true)
    - name: Install web server
      ansible.builtin.dnf:
        name: httpd
        state: present
      when: >
        ansible_facts['distribution'] == "RedHat" or
        ansible_facts['distribution'] == "CentOS"

    # NOT logic (condition must be false)
    - name: Install security updates
      ansible.builtin.dnf:
        name: '*'
        state: latest
        security: yes
      when: not ansible_facts['virtualization_type'] == "docker"
```

**Variable Testing**:

```yaml
- name: Variable condition examples
  hosts: all
  tasks:
    - name: Use variable when defined
      ansible.builtin.debug:
        msg: "Custom message: {{ custom_message }}"
      when: custom_message is defined

    - name: Skip if variable undefined
      ansible.builtin.debug:
        msg: "Variable is not set"
      when: optional_var is undefined

    - name: Check for empty values
      ansible.builtin.fail:
        msg: "Required variable cannot be empty"
      when: required_var | length == 0

    - name: Test variable types
      ansible.builtin.debug:
        msg: "Port is numeric"
      when: web_port is number

    - name: Test variable content
      ansible.builtin.service:
        name: httpd
        state: started
      when: "'web' in server_roles"
```

### Conditional Patterns

**Based on Command Results**:

```yaml
- name: Conditional based on command output
  hosts: all
  tasks:
    - name: Check if service exists
      ansible.builtin.command: systemctl list-unit-files httpd.service
      register: service_check
      failed_when: false
      changed_when: false

    - name: Start service if it exists
      ansible.builtin.systemd:
        name: httpd
        state: started
      when: service_check.rc == 0

    - name: Install service if it doesn't exist
      ansible.builtin.dnf:
        name: httpd
        state: present
      when: service_check.rc != 0
```

**Based on File/Directory Existence**:

```yaml
- name: File-based conditionals
  hosts: all
  tasks:
    - name: Check if config file exists
      ansible.builtin.stat:
        path: /etc/httpd/conf/httpd.conf
      register: config_file

    - name: Backup existing config
      ansible.builtin.copy:
        src: /etc/httpd/conf/httpd.conf
        dest: /etc/httpd/conf/httpd.conf.backup
        remote_src: yes
      when: config_file.stat.exists

    - name: Create config from template
      ansible.builtin.template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      when: not config_file.stat.exists
```

**Based on Previous Task Results**:

```yaml
- name: Task result conditionals
  hosts: all
  tasks:
    - name: Test web service
      ansible.builtin.uri:
        url: "http://{{ inventory_hostname }}"
        status_code: 200
      register: web_test
      ignore_errors: yes

    - name: Restart web service if test failed
      ansible.builtin.systemd:
        name: httpd
        state: restarted
      when: web_test is failed

    - name: Report success
      ansible.builtin.debug:
        msg: "Web service is healthy"
      when: web_test is succeeded
```

---

## 🔄 Loops and Iteration

### Basic Loop Types

**Simple List Loop**:

```yaml
- name: Basic loop examples
  hosts: all
  tasks:
    - name: Install multiple packages
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - mysql-server
        - php

    - name: Create multiple users
      ansible.builtin.user:
        name: "{{ item }}"
        shell: /bin/bash
        groups: users
      loop:
        - alice
        - bob
        - charlie
```

**Dictionary Loop**:

```yaml
- name: Dictionary loop examples
  hosts: all
  vars:
    web_users:
      - name: webadmin
        groups: [wheel, apache]
        shell: /bin/bash
      - name: webdev
        groups: [apache, developers]
        shell: /bin/bash
      - name: webtest
        groups: [apache]
        shell: /bin/nologin
  tasks:
    - name: Create web users with different attributes
      ansible.builtin.user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        shell: "{{ item.shell }}"
        create_home: yes
      loop: "{{ web_users }}"
```

**Hash/Dictionary Processing**:

```yaml
- name: Process dictionary data
  hosts: all
  vars:
    apache_modules:
      ssl:
        state: enabled
        config: ssl.conf
      rewrite:
        state: enabled
        config: rewrite.conf
      php:
        state: disabled
        config: php.conf
  tasks:
    - name: Configure Apache modules
      ansible.builtin.lineinfile:
        path: "/etc/httpd/conf.modules.d/{{ item.value.config }}"
        line: "LoadModule {{ item.key }}_module modules/mod_{{ item.key }}.so"
        state: "{{ 'present' if item.value.state == 'enabled' else 'absent' }}"
      loop: "{{ apache_modules | dict2items }}"
```

### Advanced Loop Patterns

**Nested Loops**:

```yaml
- name: Nested loop examples
  hosts: all
  vars:
    users: [alice, bob]
    groups: [developers, testers, operators]
  tasks:
    - name: Add users to multiple groups
      ansible.builtin.user:
        name: "{{ item[0] }}"
        groups: "{{ item[1] }}"
        append: yes
      loop: "{{ users | product(groups) | list }}"
      # Creates all combinations: alice+developers, alice+testers, etc.

    - name: Configure services on multiple ports
      ansible.posix.firewalld:
        port: "{{ item[0] }}/{{ item[1] }}"
        permanent: yes
        state: enabled
      loop: "{{ ports | product(protocols) | list }}"
      vars:
        ports: [80, 443, 8080]
        protocols: [tcp, udp]
```

**Range Loops**:

```yaml
- name: Range loop examples
  hosts: all
  tasks:
    - name: Create numbered directories
      ansible.builtin.file:
        path: "/tmp/dir{{ item }}"
        state: directory
      loop: "{{ range(1, 6) | list }}"  # Creates dir1, dir2, dir3, dir4, dir5

    - name: Create backup copies
      ansible.builtin.copy:
        src: /etc/important.conf
        dest: "/backup/important.conf.{{ item }}"
        remote_src: yes
      loop: "{{ range(1, 4) | list }}"
```

**File Globbing Loops**:

```yaml
- name: File-based loops
  hosts: all
  tasks:
    - name: Find log files
      ansible.builtin.find:
        paths: /var/log
        patterns: "*.log"
      register: log_files

    - name: Archive log files
      ansible.builtin.archive:
        path: "{{ item.path }}"
        dest: "{{ item.path }}.gz"
        format: gz
        remove: yes
      loop: "{{ log_files.files }}"
      when: log_files.files | length > 0

    - name: Process config files with glob
      ansible.builtin.template:
        src: "{{ item | basename }}.j2"
        dest: "{{ item }}"
        backup: yes
      loop: "{{ query('fileglob', '/etc/httpd/conf.d/*.conf') }}"
```

### Loop Control Options

**Loop Control Variables**:

```yaml
- name: Loop control examples
  hosts: all
  tasks:
    - name: Install packages with detailed output
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - mysql-server
        - php
      loop_control:
        index_var: package_index
        label: "Installing {{ item }}"
        pause: 5  # Pause 5 seconds between iterations

    - name: Show loop progress
      ansible.builtin.debug:
        msg: "Installing package {{ package_index + 1 }}/{{ ansible_loop.length }}: {{ item }}"
      loop:
        - httpd
        - mysql-server  
        - php
      loop_control:
        index_var: package_index
```

**Conditional Loops**:

```yaml
- name: Conditional loops
  hosts: all
  tasks:
    - name: Install packages conditionally
      ansible.builtin.dnf:
        name: "{{ item.package }}"
        state: present
      loop:
        - {package: httpd, condition: "{{ 'webserver' in server_roles }}"}
        - {package: mysql-server, condition: "{{ 'database' in server_roles }}"}
        - {package: nginx, condition: "{{ web_server == 'nginx' }}"}
      when: item.condition | bool
```

---

## 🛡️ Error Handling and Recovery

### Block Structure

**Basic Block/Rescue/Always**:

```yaml
---
- name: Error handling with blocks
  hosts: all
  tasks:
    - name: Web service deployment
      block:
        - name: Install web server
          ansible.builtin.dnf:
            name: httpd
            state: present

        - name: Start web server
          ansible.builtin.systemd:
            name: httpd
            state: started
            enabled: yes

        - name: Test web server
          ansible.builtin.uri:
            url: "http://{{ inventory_hostname }}"
            status_code: 200

        - name: Deploy application
          ansible.builtin.copy:
            src: "{{ app_package }}"
            dest: /var/www/html/

      rescue:
        - name: Log deployment failure
          ansible.builtin.debug:
            msg: "Deployment failed on {{ inventory_hostname }}"

        - name: Stop failed services
          ansible.builtin.systemd:
            name: httpd
            state: stopped
          ignore_errors: yes

        - name: Clean up failed installation
          ansible.builtin.dnf:
            name: httpd
            state: absent

        - name: Notify monitoring system
          ansible.builtin.uri:
            url: "http://monitoring.example.com/alert"
            method: POST
            body_format: json
            body:
              host: "{{ inventory_hostname }}"
              status: "deployment_failed"
              timestamp: "{{ ansible_date_time.iso8601 }}"

      always:
        - name: Clean temporary files
          ansible.builtin.file:
            path: "{{ item }}"
            state: absent
          loop:
            - /tmp/deployment.lock
            - /tmp/app_temp.*
          ignore_errors: yes

        - name: Update deployment log
          ansible.builtin.linefile:
            path: /var/log/deployment.log
            line: "{{ ansible_date_time.iso8601 }} - Deployment attempt on {{ inventory_hostname }}"
            create: yes
```

### Custom Error Conditions

**Failed When Conditions**:

```yaml
- name: Custom failure conditions
  hosts: all
  tasks:
    - name: Check disk space
      ansible.builtin.shell: df / | tail -1 | awk '{print $5}' | sed 's/%//'
      register: disk_usage
      failed_when: disk_usage.stdout | int > 90

    - name: Verify service configuration
      ansible.builtin.command: httpd -t
      register: config_test
      failed_when: 
        - config_test.rc != 0
        - "'Syntax OK' not in config_test.stderr"

    - name: Complex failure conditions
      ansible.builtin.uri:
        url: "http://{{ inventory_hostname }}/api/health"
        method: GET
      register: health_check
      failed_when:
        - health_check.status != 200
        - health_check.json.status != "healthy"
        - health_check.json.database_connection != true
```

**Changed When Conditions**:

```yaml
- name: Custom change conditions
  hosts: all
  tasks:
    - name: Run deployment script
      ansible.builtin.command: /opt/deploy/deploy.sh
      register: deploy_result
      changed_when: 
        - "'deployed' in deploy_result.stdout"
        - deploy_result.rc == 0

    - name: Update application
      ansible.builtin.shell: |
        cd /opt/myapp
        git pull origin main
      register: git_pull
      changed_when: "'Already up to date' not in git_pull.stdout"
```

### Ignore Errors Strategy

```yaml
- name: Ignore errors examples
  hosts: all
  tasks:
    - name: Attempt optional configuration
      ansible.builtin.copy:
        src: optional.conf
        dest: /etc/myapp/optional.conf
      ignore_errors: yes

    - name: Try multiple package sources
      block:
        - name: Install from primary repo
          ansible.builtin.dnf:
            name: special-package
            state: present

      rescue:
        - name: Install from alternative repo
          ansible.builtin.dnf:
            name: special-package
            state: present
            enablerepo: alternative-repo
          ignore_errors: yes

        - name: Install from third-party source
          ansible.builtin.get_url:
            url: "{{ third_party_package_url }}"
            dest: /tmp/package.rpm
          ignore_errors: yes

        - name: Install downloaded package
          ansible.builtin.dnf:
            name: /tmp/package.rpm
            state: present
          ignore_errors: yes
```

---

## 🎯 Task Delegation and Control

### Delegation Patterns

**Delegate to Specific Host**:

```yaml
- name: Delegation examples
  hosts: webservers
  tasks:
    - name: Update load balancer config
      ansible.builtin.template:
        src: backend.conf.j2
        dest: /etc/haproxy/backends.conf
      delegate_to: loadbalancer.example.com
      notify: reload haproxy

    - name: Register in monitoring system
      ansible.builtin.uri:
        url: "http://monitoring.example.com/api/register"
        method: POST
        body_format: json
        body:
          hostname: "{{ inventory_hostname }}"
          ip: "{{ ansible_default_ipv4.address }}"
          service: web
      delegate_to: localhost

    - name: Update DNS records
      ansible.builtin.uri:
        url: "{{ dns_api_url }}"
        method: PUT
        body_format: json
        body:
          name: "{{ inventory_hostname }}"
          value: "{{ ansible_default_ipv4.address }}"
      delegate_to: localhost
      run_once: yes
```

**Run Once Pattern**:

```yaml
- name: Run once examples
  hosts: webservers
  tasks:
    - name: Download application package (once)
      ansible.builtin.get_url:
        url: "{{ app_download_url }}"
        dest: /tmp/app.tar.gz
      run_once: yes
      delegate_to: "{{ groups['webservers'][0] }}"

    - name: Create shared database (once)
      ansible.builtin.mysql_db:
        name: "{{ app_database }}"
        state: present
      run_once: yes
      delegate_to: "{{ groups['databases'][0] }}"

    - name: Send deployment notification (once)
      ansible.builtin.mail:
        to: ops-team@example.com
        subject: "Deployment completed"
        body: "Application deployed to {{ groups['webservers'] | join(', ') }}"
      run_once: yes
      delegate_to: localhost
```

### Execution Control

**Serial Execution**:

```yaml
---
- name: Rolling update deployment
  hosts: webservers
  serial: 1  # Update one server at a time
  tasks:
    - name: Remove from load balancer
      ansible.builtin.uri:
        url: "http://{{ load_balancer }}/api/disable/{{ inventory_hostname }}"
        method: POST
      delegate_to: localhost

    - name: Update application
      ansible.builtin.copy:
        src: "{{ app_package }}"
        dest: /opt/myapp/

    - name: Restart application service
      ansible.builtin.systemd:
        name: myapp
        state: restarted

    - name: Wait for service health check
      ansible.builtin.uri:
        url: "http://{{ inventory_hostname }}/health"
        status_code: 200
      retries: 10
      delay: 30

    - name: Add back to load balancer
      ansible.builtin.uri:
        url: "http://{{ load_balancer }}/api/enable/{{ inventory_hostname }}"
        method: POST
      delegate_to: localhost
```

**Batch Processing**:

```yaml
---
- name: Batch update servers
  hosts: all
  serial:
    - 1        # Update 1 server first
    - 25%      # Then 25% of remaining
    - 100%     # Then all remaining
  max_fail_percentage: 20  # Stop if more than 20% fail
  tasks:
    - name: Update packages
      ansible.builtin.dnf:
        name: '*'
        state: latest

    - name: Reboot if needed
      ansible.builtin.reboot:
        reboot_timeout: 300
      when: ansible_reboot_pending | default(false)
```

**Throttling**:

```yaml
- name: Resource-intensive tasks
  hosts: all
  tasks:
    - name: Download large files (throttled)
      ansible.builtin.get_url:
        url: "{{ large_file_url }}"
        dest: "/tmp/{{ large_file_name }}"
      throttle: 2  # Only 2 hosts at a time

    - name: Backup databases (one at a time)
      ansible.builtin.command: mysqldump --all-databases
      register: backup_result
      throttle: 1
```

---

## 🔍 Advanced Task Control Patterns

### Conditional Blocks

```yaml
- name: Environment-specific configuration
  hosts: all
  tasks:
    - name: Production configuration
      block:
        - name: Install production packages
          ansible.builtin.dnf:
            name: "{{ production_packages }}"
            state: present

        - name: Configure production settings
          ansible.builtin.template:
            src: prod.conf.j2
            dest: /etc/myapp/config.conf

        - name: Enable production monitoring
          ansible.builtin.systemd:
            name: monitoring-agent
            state: started
            enabled: yes
      when: environment == "production"

    - name: Development configuration
      block:
        - name: Install development packages
          ansible.builtin.dnf:
            name: "{{ development_packages }}"
            state: present

        - name: Configure development settings
          ansible.builtin.template:
            src: dev.conf.j2
            dest: /etc/myapp/config.conf

        - name: Disable monitoring in dev
          ansible.builtin.systemd:
            name: monitoring-agent
            state: stopped
            enabled: no
      when: environment == "development"
```

### Dynamic Task Generation

```yaml
- name: Dynamic task creation
  hosts: all
  vars:
    services_config:
      web:
        package: httpd
        service: httpd
        port: 80
        config_template: httpd.conf.j2
      database:
        package: mysql-server
        service: mysqld
        port: 3306
        config_template: my.cnf.j2
      cache:
        package: redis
        service: redis
        port: 6379
        config_template: redis.conf.j2
  tasks:
    - name: Configure services dynamically
      include_tasks: configure_service.yml
      loop: "{{ services_config | dict2items }}"
      when: item.key in server_roles

# configure_service.yml
- name: Install {{ item.key }} service
  ansible.builtin.dnf:
    name: "{{ item.value.package }}"
    state: present

- name: Configure {{ item.key }} service
  ansible.builtin.template:
    src: "{{ item.value.config_template }}"
    dest: "/etc/{{ item.key }}/config.conf"
  notify: restart {{ item.key }}

- name: Start {{ item.key }} service
  ansible.builtin.systemd:
    name: "{{ item.value.service }}"
    state: started
    enabled: yes
```

### Task Result Processing

```yaml
- name: Process multiple command results
  hosts: all
  tasks:
    - name: Check multiple services
      ansible.builtin.systemd:
        name: "{{ item }}"
      register: service_status
      loop:
        - httpd
        - mysqld
        - redis
        - nginx
      ignore_errors: yes

    - name: Report service states
      ansible.builtin.debug:
        msg: |
          Service {{ item.item }} is {{ item.status.ActiveState }}
          ({{ 'enabled' if item.status.UnitFileState == 'enabled' else 'disabled' }})
      loop: "{{ service_status.results }}"
      when: not item.failed | default(false)

    - name: Restart failed services
      ansible.builtin.systemd:
        name: "{{ item.item }}"
        state: restarted
      loop: "{{ service_status.results }}"
      when: 
        - not item.failed | default(false)
        - item.status.ActiveState != "active"
```

---

## 🧪 Practical Lab Exercises

### Exercise 1: Complex Conditional Logic

**Create a playbook that:**

1. Installs different packages based on OS and role
2. Configures services only if certain conditions are met
3. Skips tasks based on system resources

```yaml
---
- name: Conditional deployment
  hosts: all
  tasks:
    - name: Install web server based on OS and resources
      ansible.builtin.package:
        name: "{{ web_server }}"
        state: present
      vars:
        web_server: >-
          {% if ansible_facts['distribution'] == 'RedHat' %}
            {% if ansible_facts['memtotal_mb'] > 4096 %}nginx{% else %}httpd{% endif %}
          {% elif ansible_facts['distribution'] == 'Ubuntu' %}
            {% if ansible_facts['memtotal_mb'] > 4096 %}nginx{% else %}apache2{% endif %}
          {% else %}httpd{% endif %}
      when: 
        - "'webservers' in group_names"
        - ansible_facts['memtotal_mb'] > 1024
```

### Exercise 2: Advanced Loop Processing

**Build a playbook that:**

1. Creates users with different attributes from a complex data structure
2. Configures multiple services with nested configuration
3. Processes file lists with conditional actions

### Exercise 3: Comprehensive Error Handling

**Design error handling that:**

1. Attempts multiple strategies for package installation
2. Recovers gracefully from service failures
3. Always cleans up temporary resources
4. Logs all actions for troubleshooting

### Exercise 4: Rolling Deployment Pattern

**Implement a rolling update that:**

1. Updates servers in batches
2. Removes each server from load balancer during update
3. Verifies health before proceeding
4. Rolls back on failure

---

## 🎯 Key Takeaways

### Conditional Logic Mastery

- **When statements**: Use for simple and complex conditions
- **Boolean logic**: Combine conditions with and/or/not operators  
- **Variable testing**: Check for defined, undefined, and type conditions
- **Fact-based decisions**: Make choices based on system information

### Loop Proficiency

- **Basic loops**: Process lists efficiently with loop directive
- **Complex data**: Handle dictionaries and nested structures
- **Loop control**: Use labels, indexing, and pauses effectively
- **Performance**: Choose appropriate loop patterns for data size

### Error Handling Excellence

- **Block structure**: Organize error handling with block/rescue/always
- **Custom conditions**: Define when tasks fail or change
- **Ignore strategies**: Continue execution when appropriate
- **Recovery patterns**: Implement graceful fallback mechanisms

### Delegation and Control

- **Task delegation**: Run tasks on different hosts when needed
- **Run once**: Execute expensive operations only once
- **Serial execution**: Control deployment speed and risk
- **Throttling**: Manage resource usage during intensive operations

---

## 🔗 Next Steps

With advanced task control skills, you're ready for:

1. **[Module 05: Templates](05_templates.md)** - Dynamic configuration with Jinja2
2. **Configuration management** using template logic and variables
3. **Complex file generation** with loops and conditionals in templates
4. **Dynamic service configuration** based on runtime conditions

Your task control expertise enables sophisticated automation workflows!

---

**Next Module**: [Module 05: Templates](05_templates.md) →
