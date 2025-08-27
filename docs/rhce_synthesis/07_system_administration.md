# Module 07: System Administration Tasks

## 🎯 Learning Objectives

By the end of this module, you will:

- Automate standard RHCSA system administration tasks using Ansible
- Master package management automation across different systems
- Implement service management with systemd automation
- Configure storage solutions including LVM and filesystem management
- Automate user and group management with proper security practices
- Manage network configuration including firewall and SELinux automation
- Create comprehensive system hardening and compliance automation
- Design monitoring and maintenance automation workflows

## 📋 Why Automate System Administration

### Manual Administration vs Automation

**Manual Administration Challenges**:

- Time-consuming repetitive tasks
- Human errors and inconsistency
- Difficult to scale across many systems
- Hard to audit and track changes
- Knowledge concentrated in individuals

**Automation Benefits**:

- **Consistency**: Same configuration across all systems
- **Speed**: Deploy changes to hundreds of systems simultaneously
- **Reliability**: Eliminate human errors in routine tasks
- **Auditability**: Track all changes through version control
- **Scalability**: Manage infrastructure growth efficiently

### RHCE System Administration Focus

The RHCE exam tests automation of standard RHCSA tasks:

- Software package and repository management
- Service configuration and control
- Storage device and filesystem management
- Network and security configuration
- User and group administration
- System monitoring and maintenance

---

## 📦 Package and Repository Management

### Package Installation and Management

**Basic Package Operations**:

```yaml
---
- name: Package management examples
  hosts: all
  become: yes
  tasks:
    # Install single package
    - name: Install Apache web server
      ansible.builtin.dnf:
        name: httpd
        state: present

    # Install multiple packages
    - name: Install development tools
      ansible.builtin.dnf:
        name:
          - gcc
          - make
          - git
          - vim
        state: present

    # Install package groups
    - name: Install development group
      ansible.builtin.dnf:
        name: "@Development Tools"
        state: present

    # Update specific package
    - name: Update kernel
      ansible.builtin.dnf:
        name: kernel
        state: latest

    # Update all packages
    - name: Update all packages
      ansible.builtin.dnf:
        name: '*'
        state: latest
      register: update_result

    # Remove packages
    - name: Remove unnecessary packages
      ansible.builtin.dnf:
        name:
          - telnet
          - rsh
          - rlogin
        state: absent
```

### Repository Management

**Repository Configuration**:

```yaml
---
- name: Repository management
  hosts: all
  become: yes
  tasks:
    # Add repository
    - name: Add EPEL repository
      ansible.builtin.dnf:
        name: epel-release
        state: present

    # Configure custom repository
    - name: Add custom repository
      ansible.builtin.yum_repository:
        name: custom-repo
        description: Custom Software Repository
        baseurl: https://repo.example.com/rhel/$releasever/$basearch/
        gpgcheck: yes
        gpgkey: https://repo.example.com/RPM-GPG-KEY-custom
        enabled: yes

    # Import GPG key
    - name: Import repository GPG key
      ansible.builtin.rpm_key:
        key: https://repo.example.com/RPM-GPG-KEY-custom
        state: present

    # Install from specific repository
    - name: Install package from EPEL
      ansible.builtin.dnf:
        name: htop
        state: present
        enablerepo: epel

    # Disable repository temporarily
    - name: Install with disabled repo
      ansible.builtin.dnf:
        name: some-package
        state: present
        disablerepo: epel
```

### Package Facts and Validation

```yaml
---
- name: Package validation and facts
  hosts: all
  become: yes
  tasks:
    # Gather package facts
    - name: Get package information
      ansible.builtin.package_facts:
        manager: auto

    # Verify packages are installed
    - name: Verify required packages
      ansible.builtin.assert:
        that:
          - "'httpd' in ansible_facts.packages"
          - "'mysql-server' in ansible_facts.packages"
        fail_msg: "Required packages not installed"
        success_msg: "All required packages present"

    # Check package versions
    - name: Display package versions
      ansible.builtin.debug:
        msg: "{{ item }} version: {{ ansible_facts.packages[item][0].version }}"
      loop:
        - httpd
        - mysql-server
      when: item in ansible_facts.packages

    # Conditional package installation
    - name: Install missing packages
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop:
        - nginx
        - php-fpm
        - mariadb-server
      when: item not in ansible_facts.packages
```

---

## 🔧 Service Management with Systemd

### Basic Service Operations

```yaml
---
- name: Service management examples
  hosts: all
  become: yes
  tasks:
    # Start and enable services
    - name: Start and enable web services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: started
        enabled: yes
        daemon_reload: yes
      loop:
        - httpd
        - php-fpm

    # Stop and disable services
    - name: Stop and disable unnecessary services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: stopped
        enabled: no
      loop:
        - postfix
        - cups
      ignore_errors: yes

    # Restart services
    - name: Restart network service
      ansible.builtin.systemd:
        name: NetworkManager
        state: restarted

    # Reload service configuration
    - name: Reload systemd daemon
      ansible.builtin.systemd:
        daemon_reload: yes

    # Mask/unmask services
    - name: Mask unwanted service
      ansible.builtin.systemd:
        name: bluetooth
        masked: yes
```

### Advanced Service Configuration

```yaml
---
- name: Advanced service management
  hosts: all
  become: yes
  tasks:
    # Create custom service unit
    - name: Create custom application service
      ansible.builtin.copy:
        content: |
          [Unit]
          Description=My Custom Application
          After=network.target

          [Service]
          Type=simple
          User=myapp
          ExecStart=/opt/myapp/bin/myapp
          Restart=always
          RestartSec=10

          [Install]
          WantedBy=multi-user.target
        dest: /etc/systemd/system/myapp.service
        mode: '0644'
      notify: reload systemd

    # Override service configuration
    - name: Override httpd service settings
      ansible.builtin.file:
        path: /etc/systemd/system/httpd.service.d
        state: directory

    - name: Create service override
      ansible.builtin.copy:
        content: |
          [Service]
          LimitNOFILE=65536
          PrivateTmp=yes
        dest: /etc/systemd/system/httpd.service.d/override.conf
      notify: reload systemd

    # Service facts and validation
    - name: Gather service facts
      ansible.builtin.service_facts:

    - name: Verify critical services
      ansible.builtin.assert:
        that:
          - ansible_facts.services['sshd.service'].state == 'running'
          - ansible_facts.services['firewalld.service'].state == 'running'
        fail_msg: "Critical services not running"

  handlers:
    - name: reload systemd
      ansible.builtin.systemd:
        daemon_reload: yes
```

### Service Dependencies and Ordering

```yaml
---
- name: Service dependency management
  hosts: all
  become: yes
  tasks:
    # Install and configure database first
    - name: Install database server
      ansible.builtin.dnf:
        name: mariadb-server
        state: present

    - name: Start database service
      ansible.builtin.systemd:
        name: mariadb
        state: started
        enabled: yes

    # Wait for service to be ready
    - name: Wait for database to be ready
      ansible.builtin.wait_for:
        port: 3306
        host: localhost
        delay: 5
        timeout: 60

    # Configure application that depends on database
    - name: Configure application
      ansible.builtin.template:
        src: app-config.j2
        dest: /etc/myapp/config.conf
      notify: restart application

    - name: Start application service
      ansible.builtin.systemd:
        name: myapp
        state: started
        enabled: yes

  handlers:
    - name: restart application
      ansible.builtin.systemd:
        name: myapp
        state: restarted
```

---

## 💾 Storage and Filesystem Management

### Disk and Partition Management

```yaml
---
- name: Storage management
  hosts: all
  become: yes
  tasks:
    # Gather disk information
    - name: Gather disk facts
      ansible.builtin.setup:
        gather_subset: hardware

    # Create partition
    - name: Create primary partition
      community.general.parted:
        device: /dev/sdb
        number: 1
        state: present
        part_type: primary
        part_start: 1MiB
        part_end: 10GiB

    # Create extended partition
    - name: Create extended partition
      community.general.parted:
        device: /dev/sdb
        number: 2
        state: present
        part_type: extended
        part_start: 10GiB
        part_end: 100%

    # Create logical partitions
    - name: Create logical partitions
      community.general.parted:
        device: /dev/sdb
        number: "{{ item.number }}"
        state: present
        part_type: logical
        part_start: "{{ item.start }}"
        part_end: "{{ item.end }}"
      loop:
        - {number: 5, start: 10.1GiB, end: 20GiB}
        - {number: 6, start: 20.1GiB, end: 30GiB}
```

### LVM Configuration

```yaml
---
- name: LVM management
  hosts: all
  become: yes
  tasks:
    # Create physical volumes
    - name: Create physical volumes
      community.general.lvg:
        vg: vg_data
        pvs: 
          - /dev/sdb1
          - /dev/sdc1
        state: present

    # Extend volume group
    - name: Add physical volume to VG
      community.general.lvg:
        vg: vg_data
        pvs: 
          - /dev/sdb1
          - /dev/sdc1
          - /dev/sdd1
        state: present

    # Create logical volumes
    - name: Create logical volumes
      community.general.lvol:
        vg: vg_data
        lv: "{{ item.name }}"
        size: "{{ item.size }}"
        state: present
      loop:
        - {name: lv_web, size: 10G}
        - {name: lv_database, size: 20G}
        - {name: lv_logs, size: 5G}

    # Extend logical volume
    - name: Extend logical volume
      community.general.lvol:
        vg: vg_data
        lv: lv_database
        size: 30G
        resizefs: yes

    # Create snapshots
    - name: Create database snapshot
      community.general.lvol:
        vg: vg_data
        lv: lv_database_snap
        size: 2G
        snapshot: lv_database
        state: present
```

### Filesystem Creation and Management

```yaml
---
- name: Filesystem management
  hosts: all
  become: yes
  tasks:
    # Create filesystems
    - name: Create XFS filesystems
      ansible.builtin.filesystem:
        fstype: xfs
        dev: "{{ item.device }}"
        opts: "{{ item.opts | default(omit) }}"
      loop:
        - {device: /dev/vg_data/lv_web, opts: "-b size=4096"}
        - {device: /dev/vg_data/lv_database}
        - {device: /dev/vg_data/lv_logs}

    # Create ext4 filesystem with options
    - name: Create ext4 filesystem
      ansible.builtin.filesystem:
        fstype: ext4
        dev: /dev/sdb2
        opts: -cc

    # Mount filesystems
    - name: Mount filesystems
      ansible.posix.mount:
        path: "{{ item.mount }}"
        src: "{{ item.device }}"
        fstype: "{{ item.fstype }}"
        opts: "{{ item.opts | default('defaults') }}"
        state: mounted
      loop:
        - {device: /dev/vg_data/lv_web, mount: /var/www, fstype: xfs}
        - {device: /dev/vg_data/lv_database, mount: /var/lib/mysql, fstype: xfs}
        - {device: /dev/vg_data/lv_logs, mount: /var/log/apps, fstype: xfs, opts: "defaults,noatime"}

    # Create swap
    - name: Create swap filesystem
      ansible.builtin.filesystem:
        fstype: swap
        dev: /dev/vg_data/lv_swap

    - name: Enable swap
      ansible.posix.mount:
        path: none
        src: /dev/vg_data/lv_swap
        fstype: swap
        opts: sw
        state: present

    # Verify mounts
    - name: Verify filesystems are mounted
      ansible.builtin.mount:
        path: "{{ item }}"
        state: mounted
      loop:
        - /var/www
        - /var/lib/mysql
        - /var/log/apps
      check_mode: yes
      register: mount_check

    - name: Display mount status
      ansible.builtin.debug:
        msg: "{{ item.path }} is {{ 'mounted' if not item.changed else 'not mounted' }}"
      loop: "{{ mount_check.results }}"
```

---

## 👥 User and Group Management

### User Account Management

```yaml
---
- name: User management
  hosts: all
  become: yes
  tasks:
    # Create groups first
    - name: Create system groups
      ansible.builtin.group:
        name: "{{ item.name }}"
        gid: "{{ item.gid | default(omit) }}"
        system: "{{ item.system | default(false) }}"
        state: present
      loop:
        - {name: webadmin, gid: 2001}
        - {name: dbadmin, gid: 2002}
        - {name: developers, gid: 2010}
        - {name: appservice, gid: 3001, system: true}

    # Create user accounts
    - name: Create user accounts
      ansible.builtin.user:
        name: "{{ item.name }}"
        uid: "{{ item.uid | default(omit) }}"
        group: "{{ item.primary_group | default(item.name) }}"
        groups: "{{ item.groups | default([]) }}"
        append: "{{ item.append | default(true) }}"
        shell: "{{ item.shell | default('/bin/bash') }}"
        home: "{{ item.home | default('/home/' + item.name) }}"
        create_home: "{{ item.create_home | default(true) }}"
        system: "{{ item.system | default(false) }}"
        password: "{{ item.password | default('!') }}"
        state: present
      loop:
        - name: webuser
          uid: 2001
          primary_group: webadmin
          groups: [wheel]
          password: "{{ webuser_password_hash }}"
        - name: dbuser
          uid: 2002
          primary_group: dbadmin
          groups: [wheel]
          password: "{{ dbuser_password_hash }}"
        - name: appuser
          uid: 3001
          primary_group: appservice
          system: true
          shell: /sbin/nologin
          create_home: false

    # Configure SSH keys
    - name: Configure SSH authorized keys
      ansible.posix.authorized_key:
        user: "{{ item.user }}"
        key: "{{ item.key }}"
        comment: "{{ item.comment | default('Ansible managed key') }}"
        state: present
      loop:
        - user: webuser
          key: "{{ webuser_ssh_key }}"
          comment: "Web administrator key"
        - user: dbuser
          key: "{{ dbuser_ssh_key }}"
          comment: "Database administrator key"

    # Set password policies
    - name: Configure password aging
      ansible.builtin.user:
        name: "{{ item }}"
        password_expire_max: 90
        password_expire_min: 7
        password_expire_warn: 14
      loop:
        - webuser
        - dbuser
```

### Sudo Configuration

```yaml
---
- name: Sudo configuration
  hosts: all
  become: yes
  tasks:
    # Create sudo rules
    - name: Configure sudo rules
      ansible.builtin.copy:
        content: |
          # {{ item.name }} sudo rules
          {{ item.rule }}
        dest: "/etc/sudoers.d/{{ item.name }}"
        mode: '0440'
        validate: /usr/sbin/visudo -cf %s
      loop:
        - name: webadmin
          rule: "%webadmin ALL=(ALL) NOPASSWD: /bin/systemctl restart httpd, /bin/systemctl reload httpd"
        - name: dbadmin
          rule: "%dbadmin ALL=(ALL) NOPASSWD: /bin/systemctl * mysqld, /usr/bin/mysql"
        - name: developers
          rule: "%developers ALL=(appuser) NOPASSWD: ALL"

    # Verify sudo configuration
    - name: Test sudo configuration
      ansible.builtin.command: sudo -u webuser sudo -l
      become_user: webuser
      register: sudo_test
      changed_when: false
      failed_when: sudo_test.rc != 0
```

---

## 🔥 Network and Security Configuration

### Firewall Management with firewalld

```yaml
---
- name: Firewall configuration
  hosts: all
  become: yes
  tasks:
    # Ensure firewalld is running
    - name: Start and enable firewalld
      ansible.builtin.systemd:
        name: firewalld
        state: started
        enabled: yes

    # Configure zones
    - name: Set default zone
      ansible.posix.firewalld:
        zone: public
        state: enabled
        permanent: yes
        immediate: yes

    # Add interfaces to zones
    - name: Add interface to internal zone
      ansible.posix.firewalld:
        zone: internal
        interface: eth1
        permanent: yes
        immediate: yes
        state: enabled
      when: "'eth1' in ansible_interfaces"

    # Configure services
    - name: Allow services in public zone
      ansible.posix.firewalld:
        zone: public
        service: "{{ item }}"
        permanent: yes
        immediate: yes
        state: enabled
      loop:
        - ssh
        - http
        - https

    # Configure custom ports
    - name: Allow custom ports
      ansible.posix.firewalld:
        zone: public
        port: "{{ item }}"
        permanent: yes
        immediate: yes
        state: enabled
      loop:
        - 8080/tcp
        - 3306/tcp

    # Configure rich rules
    - name: Add rich rules
      ansible.posix.firewalld:
        zone: public
        rich_rule: "{{ item }}"
        permanent: yes
        immediate: yes
        state: enabled
      loop:
        - "rule family='ipv4' source address='192.168.1.0/24' service name='mysql' accept"
        - "rule family='ipv4' source address='10.0.0.0/8' port port=22 protocol=tcp accept"

    # Remove unwanted services
    - name: Remove unwanted services
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: yes
        immediate: yes
        state: disabled
      loop:
        - dhcpv6-client
        - cockpit
      ignore_errors: yes
```

### SELinux Configuration

```yaml
---
- name: SELinux configuration
  hosts: all
  become: yes
  tasks:
    # Set SELinux mode
    - name: Set SELinux to enforcing
      ansible.posix.selinux:
        policy: targeted
        state: enforcing

    # Configure SELinux booleans
    - name: Configure SELinux booleans
      ansible.posix.seboolean:
        name: "{{ item.name }}"
        state: "{{ item.state }}"
        persistent: yes
      loop:
        - {name: httpd_can_network_connect, state: yes}
        - {name: httpd_can_network_connect_db, state: yes}
        - {name: httpd_execmem, state: no}
        - {name: httpd_enable_homedirs, state: no}

    # Set SELinux file contexts
    - name: Set SELinux file contexts
      community.general.sefcontext:
        target: "{{ item.path }}"
        setype: "{{ item.type }}"
        state: present
      loop:
        - {path: "/var/www/html(/.*)?", type: httpd_exec_t}
        - {path: "/var/log/myapp(/.*)?", type: var_log_t}
      notify: restore selinux contexts

    # Configure SELinux ports
    - name: Configure SELinux port contexts
      community.general.seport:
        ports: "{{ item.port }}"
        proto: "{{ item.proto }}"
        setype: "{{ item.type }}"
        state: present
      loop:
        - {port: 8080, proto: tcp, type: http_port_t}
        - {port: 3306, proto: tcp, type: mysqld_port_t}

  handlers:
    - name: restore selinux contexts
      ansible.builtin.command: restorecon -R "{{ item }}"
      loop:
        - /var/www/html
        - /var/log/myapp
```

---

## 📊 System Monitoring and Maintenance

### Log Management

```yaml
---
- name: Log management configuration
  hosts: all
  become: yes
  tasks:
    # Configure rsyslog
    - name: Configure rsyslog for application logs
      ansible.builtin.lineinfile:
        path: /etc/rsyslog.conf
        line: "{{ item }}"
        insertafter: "# Log anything"
      loop:
        - "local0.*    /var/log/myapp.log"
        - "local1.*    /var/log/myapp-error.log"
      notify: restart rsyslog

    # Configure logrotate
    - name: Configure logrotate for application logs
      ansible.builtin.copy:
        content: |
          /var/log/myapp*.log {
              daily
              missingok
              rotate 30
              compress
              delaycompress
              notifempty
              sharedscripts
              postrotate
                  /bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true
              endscript
          }
        dest: /etc/logrotate.d/myapp
        mode: '0644'

    # Create log directories
    - name: Create application log directories
      ansible.builtin.file:
        path: "{{ item.path }}"
        state: directory
        owner: "{{ item.owner }}"
        group: "{{ item.group }}"
        mode: "{{ item.mode }}"
      loop:
        - {path: /var/log/myapp, owner: myapp, group: myapp, mode: '0755'}
        - {path: /var/log/backup, owner: root, group: root, mode: '0755'}

  handlers:
    - name: restart rsyslog
      ansible.builtin.systemd:
        name: rsyslog
        state: restarted
```

### System Maintenance Tasks

```yaml
---
- name: System maintenance
  hosts: all
  become: yes
  tasks:
    # Configure automatic updates
    - name: Configure dnf-automatic
      ansible.builtin.lineinfile:
        path: /etc/dnf/automatic.conf
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - {regexp: "^upgrade_type", line: "upgrade_type = security"}
        - {regexp: "^apply_updates", line: "apply_updates = yes"}
        - {regexp: "^emit_via", line: "emit_via = email"}
      notify: enable dnf-automatic

    # Configure cron jobs
    - name: Configure maintenance cron jobs
      ansible.builtin.cron:
        name: "{{ item.name }}"
        user: "{{ item.user | default('root') }}"
        minute: "{{ item.minute }}"
        hour: "{{ item.hour }}"
        day: "{{ item.day | default('*') }}"
        month: "{{ item.month | default('*') }}"
        weekday: "{{ item.weekday | default('*') }}"
        job: "{{ item.job }}"
        state: present
      loop:
        - name: "Database backup"
          minute: "0"
          hour: "2"
          job: "/usr/local/bin/backup-database.sh"
        - name: "Log cleanup"
          minute: "30"
          hour: "3"
          weekday: "0"
          job: "find /var/log -name '*.log' -mtime +30 -delete"
        - name: "System health check"
          minute: "*/15"
          hour: "*"
          job: "/usr/local/bin/health-check.sh"

    # Configure system limits
    - name: Configure system limits
      ansible.builtin.pam_limits:
        domain: "{{ item.domain }}"
        limit_type: "{{ item.type }}"
        limit_item: "{{ item.item }}"
        value: "{{ item.value }}"
      loop:
        - {domain: "*", type: soft, item: nofile, value: "65536"}
        - {domain: "*", type: hard, item: nofile, value: "65536"}
        - {domain: mysql, type: soft, item: nproc, value: "32768"}
        - {domain: mysql, type: hard, item: nproc, value: "32768"}

  handlers:
    - name: enable dnf-automatic
      ansible.builtin.systemd:
        name: dnf-automatic-install.timer
        state: started
        enabled: yes
```

---

## 🔒 System Security Hardening

### Security Configuration

```yaml
---
- name: System security hardening
  hosts: all
  become: yes
  tasks:
    # Disable unused services
    - name: Disable unnecessary services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: stopped
        enabled: no
        masked: yes
      loop:
        - avahi-daemon
        - cups
        - bluetooth
        - rpcbind
      ignore_errors: yes

    # Configure SSH hardening
    - name: Harden SSH configuration
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        backup: yes
      loop:
        - {regexp: "^#?PermitRootLogin", line: "PermitRootLogin no"}
        - {regexp: "^#?PasswordAuthentication", line: "PasswordAuthentication no"}
        - {regexp: "^#?MaxAuthTries", line: "MaxAuthTries 3"}
        - {regexp: "^#?ClientAliveInterval", line: "ClientAliveInterval 300"}
        - {regexp: "^#?ClientAliveCountMax", line: "ClientAliveCountMax 2"}
        - {regexp: "^#?Protocol", line: "Protocol 2"}
      notify: restart sshd

    # Configure kernel parameters
    - name: Configure kernel security parameters
      ansible.posix.sysctl:
        name: "{{ item.name }}"
        value: "{{ item.value }}"
        state: present
        sysctl_file: /etc/sysctl.d/99-security.conf
      loop:
        - {name: net.ipv4.ip_forward, value: "0"}
        - {name: net.ipv4.conf.all.send_redirects, value: "0"}
        - {name: net.ipv4.conf.default.send_redirects, value: "0"}
        - {name: net.ipv4.conf.all.accept_redirects, value: "0"}
        - {name: net.ipv4.conf.default.accept_redirects, value: "0"}
        - {name: net.ipv4.conf.all.secure_redirects, value: "0"}
        - {name: net.ipv4.conf.default.secure_redirects, value: "0"}
        - {name: kernel.dmesg_restrict, value: "1"}
        - {name: kernel.kptr_restrict, value: "2"}

    # File permissions hardening
    - name: Set secure file permissions
      ansible.builtin.file:
        path: "{{ item.path }}"
        mode: "{{ item.mode }}"
      loop:
        - {path: /etc/passwd, mode: '0644'}
        - {path: /etc/shadow, mode: '0000'}
        - {path: /etc/group, mode: '0644'}
        - {path: /etc/gshadow, mode: '0000'}
        - {path: /boot/grub2/grub.cfg, mode: '0600'}

  handlers:
    - name: restart sshd
      ansible.builtin.systemd:
        name: sshd
        state: restarted
```

---

## 🧪 Practical Lab Exercises

### Exercise 1: Web Server Infrastructure

**Create automation for a complete web server setup**:

1. Package installation (Apache, PHP, MySQL)
2. Service configuration and startup
3. Firewall configuration for web services
4. SSL certificate installation and configuration
5. Log rotation and monitoring setup

### Exercise 2: Database Server Configuration

**Automate database server deployment**:

1. MySQL/MariaDB installation and hardening
2. User and database creation
3. Backup automation setup
4. Performance tuning based on system resources
5. Security configuration and firewall rules

### Exercise 3: Multi-Tier Application Deployment

**Deploy a complete application stack**:

1. Load balancer configuration
2. Application server setup with clustering
3. Database replication configuration
4. Shared storage configuration
5. Monitoring and alerting setup

### Exercise 4: System Compliance Automation

**Create compliance automation**:

1. Security hardening according to security benchmarks
2. User account policy enforcement
3. System auditing configuration
4. Backup and disaster recovery automation
5. Compliance reporting and validation

---

## 🎯 Key Takeaways

### System Administration Automation Excellence

- **Comprehensive coverage**: Automate all standard RHCSA tasks with Ansible
- **Consistency**: Ensure identical configuration across all managed systems
- **Scalability**: Deploy changes to hundreds of systems simultaneously
- **Reliability**: Eliminate human error in routine administrative tasks

### Package and Service Management Mastery

- **Repository management**: Automate software repository configuration and updates
- **Service dependencies**: Understand and manage service startup ordering
- **Health checking**: Implement service monitoring and automated recovery
- **Security updates**: Automate security patch management

### Storage and User Management

- **LVM automation**: Create flexible storage solutions with logical volume management
- **Filesystem management**: Automate filesystem creation, mounting, and maintenance
- **User lifecycle**: Implement complete user account lifecycle management
- **Security policies**: Enforce password policies and access controls

### Security and Compliance

- **Firewall automation**: Implement comprehensive network security policies
- **SELinux management**: Configure mandatory access controls appropriately
- **System hardening**: Apply security benchmarks consistently
- **Audit and monitoring**: Implement comprehensive system monitoring

---

## 🔗 Next Steps

With system administration automation mastery, you're ready for:

1. **[Module 08: Ansible Vault & Advanced Features](08_advanced_features.md)** - Secure automation and advanced techniques
2. **Enterprise security practices** with encrypted sensitive data
3. **Advanced automation patterns** for complex infrastructures
4. **Performance optimization** for large-scale deployments

Your system administration automation skills enable enterprise-level infrastructure management!

---

**Next Module**: [Module 08: Ansible Vault & Advanced Features](08_advanced_features.md) →
