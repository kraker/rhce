# Module 03: RHCSA Task Automation

## 🎯 Learning Objectives

By the end of this module, you will:
- Automate all major RHCSA system administration tasks using Ansible
- Master the Ansible modules critical for the RHCE exam
- Understand the exam's emphasis on RHCSA task automation
- Know which system administration patterns appear frequently on the exam
- Practice realistic automation scenarios for common sysadmin tasks

## 📋 Why This Module Matters for Experienced Users

**The Reality:** You manually perform these tasks daily or have shell scripts for them.

**The Gap:** The RHCE exam requires doing RHCSA tasks **through Ansible automation**.

**The Impact:** 40-50% of exam tasks involve automating traditional sysadmin work.

---

## 🎯 RHCSA Tasks in RHCE Context

### What This Module Covers

The RHCE exam assumes RHCSA knowledge but requires **automating** these tasks:

- **Package Management** → `ansible.builtin.dnf`
- **Service Management** → `ansible.builtin.systemd`
- **User/Group Management** → `ansible.builtin.user`, `ansible.builtin.group`
- **Storage Management** → `community.general.parted`, `community.general.lvg`, `community.general.lvol`
- **File System Management** → `community.general.filesystem`, `ansible.posix.mount`
- **Firewall Configuration** → `ansible.posix.firewalld`
- **SELinux Management** → `ansible.posix.seboolean`, `community.general.sefcontext`
- **SSH and Security** → `ansible.builtin.authorized_key`, SSH configuration
- **Network Configuration** → Network service management
- **Scheduled Tasks** → `ansible.builtin.cron`

### Key Exam Pattern

**Manual RHCSA Task**: `dnf install httpd -y && systemctl enable --now httpd`

**RHCE Automation**:
```yaml
- name: Install and start web server
  hosts: webservers
  become: true
  tasks:
    - name: Install Apache
      ansible.builtin.dnf:
        name: httpd
        state: present
    
    - name: Start and enable Apache
      ansible.builtin.systemd:
        name: httpd
        state: started
        enabled: true
```

---

## 📦 Package Management Automation

### Essential Module: ansible.builtin.dnf

```yaml
---
# Package installation and management
- name: Package management examples
  hosts: all
  become: true
  
  tasks:
    # Install single package
    - name: Install web server
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
    
    # Install package group
    - name: Install development group
      ansible.builtin.dnf:
        name: "@Development Tools"
        state: present
    
    # Remove package
    - name: Remove unnecessary packages
      ansible.builtin.dnf:
        name:
          - telnet
          - rsh
        state: absent
    
    # Update all packages
    - name: Update all packages
      ansible.builtin.dnf:
        name: "*"
        state: latest
    
    # Install from URL
    - name: Install RPM from URL
      ansible.builtin.dnf:
        name: https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
        state: present
        disable_gpg_check: true
```

### Repository Management

```yaml
---
# Repository configuration
- name: Configure repositories
  hosts: all
  become: true
  
  tasks:
    # Add repository
    - name: Add EPEL repository
      ansible.builtin.yum_repository:
        name: epel
        description: EPEL YUM repo
        baseurl: https://download.fedoraproject.org/pub/epel/9/Everything/x86_64/
        gpgcheck: true
        gpgkey: https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9
        enabled: true
    
    # Import GPG key
    - name: Import EPEL GPG key
      ansible.builtin.rpm_key:
        key: https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9
        state: present
```

---

## ⚙️ Service Management Automation

### Essential Module: ansible.builtin.systemd

```yaml
---
# Service management patterns
- name: Service management examples
  hosts: all
  become: true
  
  tasks:
    # Start and enable service
    - name: Start and enable httpd
      ansible.builtin.systemd:
        name: httpd
        state: started
        enabled: true
        daemon_reload: true
    
    # Stop and disable service
    - name: Stop and disable sendmail
      ansible.builtin.systemd:
        name: sendmail
        state: stopped
        enabled: false
    
    # Restart service
    - name: Restart network service
      ansible.builtin.systemd:
        name: NetworkManager
        state: restarted
    
    # Reload service configuration
    - name: Reload systemd daemon
      ansible.builtin.systemd:
        daemon_reload: true
    
    # Check if service is running
    - name: Check httpd status
      ansible.builtin.systemd:
        name: httpd
      register: httpd_status
    
    - name: Display service status
      ansible.builtin.debug:
        msg: "HTTPd is {{ httpd_status.status.ActiveState }}"
    
    # Mask service
    - name: Mask sendmail service
      ansible.builtin.systemd:
        name: sendmail
        masked: true
```

### Service Management with Handlers

```yaml
---
- name: Web server configuration with handlers
  hosts: webservers
  become: true
  
  tasks:
    - name: Install httpd
      ansible.builtin.dnf:
        name: httpd
        state: present
      notify: restart httpd
    
    - name: Configure httpd
      ansible.builtin.template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
        backup: true
      notify: restart httpd
    
    - name: Start and enable httpd
      ansible.builtin.systemd:
        name: httpd
        state: started
        enabled: true
  
  handlers:
    - name: restart httpd
      ansible.builtin.systemd:
        name: httpd
        state: restarted
```

---

## 👥 User and Group Management

### Essential Modules: user, group, authorized_key

```yaml
---
# User and group management
- name: User management examples
  hosts: all
  become: true
  
  tasks:
    # Create group
    - name: Create developers group
      ansible.builtin.group:
        name: developers
        gid: 1500
        state: present
    
    # Create user
    - name: Create application user
      ansible.builtin.user:
        name: appuser
        uid: 1500
        group: developers
        groups: wheel
        shell: /bin/bash
        home: /home/appuser
        create_home: true
        password: "{{ 'password123' | password_hash('sha512') }}"
        state: present
    
    # Create system user
    - name: Create system service user
      ansible.builtin.user:
        name: webuser
        system: true
        shell: /sbin/nologin
        home: /var/lib/webuser
        create_home: false
        state: present
    
    # Modify existing user
    - name: Add user to additional group
      ansible.builtin.user:
        name: alice
        groups: developers,wheel
        append: true
    
    # Set up SSH keys
    - name: Configure SSH key for user
      ansible.builtin.authorized_key:
        user: appuser
        key: "{{ lookup('file', '/home/ansible/.ssh/id_rsa.pub') }}"
        state: present
    
    # Remove user
    - name: Remove old user account
      ansible.builtin.user:
        name: olduser
        state: absent
        remove: true
```

### Password Management with Vault

```yaml
---
# Secure password management
- name: Create users with vaulted passwords
  hosts: all
  become: true
  vars:
    user_passwords:
      alice: "{{ alice_password | password_hash('sha512') }}"
      bob: "{{ bob_password | password_hash('sha512') }}"
  
  tasks:
    - name: Create users with encrypted passwords
      ansible.builtin.user:
        name: "{{ item.key }}"
        password: "{{ item.value }}"
        groups: users
        shell: /bin/bash
        create_home: true
        state: present
      loop: "{{ user_passwords | dict2items }}"
      no_log: true
```

---

## 💾 Storage Management Automation

### Essential Modules: parted, lvg, lvol, filesystem, mount

```yaml
---
# Complete storage management workflow
- name: Storage management example
  hosts: storage_servers
  become: true
  
  tasks:
    # Create partition
    - name: Create partition on /dev/vdb
      community.general.parted:
        device: /dev/vdb
        number: 1
        part_end: 10GiB
        state: present
      register: partition_result
    
    # Create volume group
    - name: Create volume group
      community.general.lvg:
        vg: data_vg
        pvs: /dev/vdb1
        state: present
    
    # Create logical volumes
    - name: Create logical volumes
      community.general.lvol:
        vg: data_vg
        lv: "{{ item.name }}"
        size: "{{ item.size }}"
        state: present
      loop:
        - name: app_lv
          size: 5G
        - name: log_lv
          size: 3G
    
    # Create filesystems
    - name: Create filesystems
      community.general.filesystem:
        fstype: ext4
        dev: "/dev/data_vg/{{ item }}"
        opts: -L {{ item }}
      loop:
        - app_lv
        - log_lv
    
    # Create mount points
    - name: Create mount points
      ansible.builtin.file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop:
        - /opt/app
        - /var/log/app
    
    # Mount filesystems
    - name: Mount filesystems persistently
      ansible.posix.mount:
        path: "{{ item.mount }}"
        src: "{{ item.src }}"
        fstype: ext4
        opts: defaults
        state: mounted
      loop:
        - mount: /opt/app
          src: /dev/data_vg/app_lv
        - mount: /var/log/app
          src: /dev/data_vg/log_lv
```

### Swap Management

```yaml
---
# Swap configuration
- name: Configure swap
  hosts: all
  become: true
  
  tasks:
    # Create swap logical volume
    - name: Create swap logical volume
      community.general.lvol:
        vg: system_vg
        lv: swap_lv
        size: 2G
        state: present
    
    # Format as swap
    - name: Format swap
      ansible.builtin.command:
        cmd: mkswap /dev/system_vg/swap_lv
        creates: /dev/system_vg/swap_lv
    
    # Add to fstab and enable
    - name: Enable swap
      ansible.posix.mount:
        path: none
        src: /dev/system_vg/swap_lv
        fstype: swap
        opts: sw
        state: present
    
    # Activate swap
    - name: Activate swap
      ansible.builtin.command:
        cmd: swapon /dev/system_vg/swap_lv
```

---

## 🔥 Firewall Management

### Essential Module: ansible.posix.firewalld

```yaml
---
# Firewall configuration examples
- name: Firewall management
  hosts: all
  become: true
  
  tasks:
    # Enable firewalld service
    - name: Ensure firewalld is running
      ansible.builtin.systemd:
        name: firewalld
        state: started
        enabled: true
    
    # Add service
    - name: Allow HTTP traffic
      ansible.posix.firewalld:
        service: http
        permanent: true
        immediate: true
        state: enabled
    
    # Add multiple services
    - name: Allow web services
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - http
        - https
        - ssh
    
    # Add specific port
    - name: Allow custom application port
      ansible.posix.firewalld:
        port: 8080/tcp
        permanent: true
        immediate: true
        state: enabled
    
    # Configure rich rule
    - name: Allow database access from web servers
      ansible.posix.firewalld:
        rich_rule: 'rule family=ipv4 source address=192.168.1.0/24 port port=3306 protocol=tcp accept'
        permanent: true
        immediate: true
        state: enabled
    
    # Change zone for interface
    - name: Assign interface to internal zone
      ansible.posix.firewalld:
        interface: eth1
        zone: internal
        permanent: true
        immediate: true
        state: enabled
    
    # Remove service
    - name: Block telnet service
      ansible.posix.firewalld:
        service: telnet
        permanent: true
        immediate: true
        state: disabled
```

### Zone Management

```yaml
---
# Advanced firewall zone configuration
- name: Configure firewall zones
  hosts: all
  become: true
  
  tasks:
    # Set default zone
    - name: Set default zone to internal
      ansible.posix.firewalld:
        zone: internal
        permanent: true
        state: present
        immediate: true
    
    # Configure public zone
    - name: Configure public zone services
      ansible.posix.firewalld:
        zone: public
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - ssh
        - dhcpv6-client
    
    # Configure internal zone
    - name: Configure internal zone services
      ansible.posix.firewalld:
        zone: internal
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - ssh
        - http
        - https
        - mysql
```

---

## 🔒 SELinux Management

### Essential Modules: seboolean, sefcontext

```yaml
---
# SELinux configuration
- name: SELinux management
  hosts: all
  become: true
  
  tasks:
    # Set SELinux booleans
    - name: Allow httpd network connections
      ansible.posix.seboolean:
        name: httpd_can_network_connect
        state: true
        persistent: true
    
    # Multiple SELinux booleans
    - name: Configure web server SELinux booleans
      ansible.posix.seboolean:
        name: "{{ item }}"
        state: true
        persistent: true
      loop:
        - httpd_can_network_connect
        - httpd_can_network_relay
        - httpd_enable_homedirs
        - httpd_execmem
    
    # Set file contexts
    - name: Set SELinux context for web content
      community.general.sefcontext:
        target: '/web_content(/.*)?'
        setype: httpd_exec_t
        state: present
      notify: restore selinux contexts
    
    # Set file contexts for custom directories
    - name: Set context for application directory
      community.general.sefcontext:
        target: '/opt/myapp(/.*)?'
        setype: bin_t
        state: present
      notify: restore selinux contexts
    
    # Restore contexts
    - name: Restore SELinux contexts
      ansible.builtin.command:
        cmd: restorecon -R {{ item }}
      loop:
        - /web_content
        - /opt/myapp
      changed_when: false
  
  handlers:
    - name: restore selinux contexts
      ansible.builtin.command:
        cmd: restorecon -R /web_content /opt/myapp
```

### SELinux Troubleshooting

```yaml
---
# SELinux status and troubleshooting
- name: SELinux diagnostics
  hosts: all
  become: true
  
  tasks:
    # Check SELinux status
    - name: Get SELinux status
      ansible.builtin.command:
        cmd: getenforce
      register: selinux_status
      changed_when: false
    
    - name: Display SELinux status
      ansible.builtin.debug:
        msg: "SELinux is {{ selinux_status.stdout }}"
    
    # Set SELinux mode
    - name: Set SELinux to enforcing
      ansible.posix.selinux:
        policy: targeted
        state: enforcing
    
    # Get file context
    - name: Check file SELinux context
      ansible.builtin.command:
        cmd: ls -Z /var/www/html
      register: file_context
      changed_when: false
    
    - name: Show file contexts
      ansible.builtin.debug:
        var: file_context.stdout_lines
```

---

## 📁 File and Directory Management

### File Operations

```yaml
---
# File management examples
- name: File operations
  hosts: all
  become: true
  
  tasks:
    # Create directories
    - name: Create application directories
      ansible.builtin.file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
        owner: apache
        group: apache
      loop:
        - /var/www/app
        - /var/www/app/config
        - /var/log/app
    
    # Copy files
    - name: Deploy configuration files
      ansible.builtin.copy:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        mode: "{{ item.mode }}"
        owner: "{{ item.owner | default('root') }}"
        group: "{{ item.group | default('root') }}"
        backup: true
      loop:
        - src: app.conf
          dest: /var/www/app/config/app.conf
          mode: '0644'
        - src: database.conf
          dest: /var/www/app/config/database.conf
          mode: '0600'
          owner: apache
          group: apache
    
    # Template deployment
    - name: Deploy templated configurations
      ansible.builtin.template:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        mode: "{{ item.mode }}"
        owner: "{{ item.owner | default('root') }}"
        group: "{{ item.group | default('root') }}"
        backup: true
      loop:
        - src: httpd.conf.j2
          dest: /etc/httpd/conf/httpd.conf
          mode: '0644'
        - src: php.ini.j2
          dest: /etc/php.ini
          mode: '0644'
      notify: restart web services
    
    # Modify file content
    - name: Configure system settings
      ansible.builtin.lineinfile:
        path: /etc/sysctl.conf
        line: "{{ item }}"
        state: present
      loop:
        - "net.ipv4.ip_forward = 1"
        - "vm.swappiness = 10"
      notify: reload sysctl
    
    # Set file attributes
    - name: Set file permissions and ownership
      ansible.builtin.file:
        path: /opt/secure-app
        state: directory
        mode: '0750'
        owner: appuser
        group: appgroup
        recurse: true
  
  handlers:
    - name: restart web services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: restarted
      loop:
        - httpd
        - php-fpm
    
    - name: reload sysctl
      ansible.builtin.command:
        cmd: sysctl -p
```

### Archive Management

```yaml
---
# Archive operations
- name: Archive management
  hosts: all
  become: true
  
  tasks:
    # Create archive
    - name: Create backup archive
      community.general.archive:
        path: /var/www/html
        dest: /backup/website-{{ ansible_date_time.epoch }}.tar.gz
        format: gz
    
    # Extract archive
    - name: Extract application archive
      ansible.builtin.unarchive:
        src: application.tar.gz
        dest: /opt
        owner: appuser
        group: appuser
        mode: '0755'
    
    # Synchronize directories
    - name: Synchronize content
      ansible.posix.synchronize:
        src: /source/data/
        dest: /destination/data/
        recursive: true
        delete: true
        rsync_opts:
          - "--exclude=*.log"
          - "--exclude=cache/"
```

---

## ⏰ Scheduled Task Management

### Cron Jobs

```yaml
---
# Cron job management
- name: Configure scheduled tasks
  hosts: all
  become: true
  
  tasks:
    # Add cron job
    - name: Schedule daily backup
      ansible.builtin.cron:
        name: "Daily website backup"
        minute: "0"
        hour: "2"
        job: "/usr/local/bin/backup-website.sh"
        user: root
        state: present
    
    # Schedule multiple jobs
    - name: Configure system maintenance jobs
      ansible.builtin.cron:
        name: "{{ item.name }}"
        minute: "{{ item.minute }}"
        hour: "{{ item.hour }}"
        day: "{{ item.day | default('*') }}"
        job: "{{ item.job }}"
        user: root
        state: present
      loop:
        - name: "Log rotation"
          minute: "0"
          hour: "1"
          job: "/usr/sbin/logrotate /etc/logrotate.conf"
        - name: "System updates"
          minute: "0"
          hour: "3"
          day: "1"
          job: "/usr/bin/dnf update -y"
        - name: "Disk cleanup"
          minute: "30"
          hour: "4"
          job: "/usr/local/bin/cleanup-disks.sh"
    
    # Remove cron job
    - name: Remove old backup job
      ansible.builtin.cron:
        name: "Old backup job"
        state: absent
```

---

## 🌐 Network Configuration

### Network Service Management

```yaml
---
# Network configuration
- name: Network management
  hosts: all
  become: true
  
  tasks:
    # Configure hostname
    - name: Set system hostname
      ansible.builtin.hostname:
        name: "{{ inventory_hostname }}"
    
    # Configure /etc/hosts
    - name: Update /etc/hosts
      ansible.builtin.lineinfile:
        path: /etc/hosts
        line: "{{ hostvars[item]['ansible_default_ipv4']['address'] }} {{ item }}"
        regexp: "^.* {{ item }}$"
        state: present
      loop: "{{ groups['all'] }}"
    
    # Configure DNS
    - name: Configure DNS resolver
      ansible.builtin.template:
        src: resolv.conf.j2
        dest: /etc/resolv.conf
        mode: '0644'
        backup: true
    
    # Restart network services
    - name: Restart network service
      ansible.builtin.systemd:
        name: NetworkManager
        state: restarted
```

---

## 🔧 System Configuration Integration

### Complete System Setup Example

```yaml
---
# Complete RHCSA task automation example
- name: Complete web server setup
  hosts: webservers
  become: true
  vars:
    web_packages:
      - httpd
      - php
      - php-mysql
      - mariadb-server
    
    web_services:
      - httpd
      - mariadb
    
    web_users:
      - name: webadmin
        groups: wheel
      - name: webuser
        system: true
        shell: /sbin/nologin
  
  tasks:
    # Package management
    - name: Install web server packages
      ansible.builtin.dnf:
        name: "{{ web_packages }}"
        state: present
    
    # User management
    - name: Create web users
      ansible.builtin.user:
        name: "{{ item.name }}"
        groups: "{{ item.groups | default(omit) }}"
        system: "{{ item.system | default(false) }}"
        shell: "{{ item.shell | default('/bin/bash') }}"
        state: present
      loop: "{{ web_users }}"
    
    # Storage setup
    - name: Create web content partition
      community.general.parted:
        device: /dev/vdb
        number: 1
        part_end: 5GiB
        state: present
    
    - name: Create web filesystem
      community.general.filesystem:
        fstype: ext4
        dev: /dev/vdb1
    
    - name: Mount web content directory
      ansible.posix.mount:
        path: /var/www/html
        src: /dev/vdb1
        fstype: ext4
        state: mounted
    
    # Service management
    - name: Start and enable web services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: started
        enabled: true
      loop: "{{ web_services }}"
    
    # Firewall configuration
    - name: Configure firewall for web server
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - http
        - https
    
    # SELinux configuration
    - name: Set SELinux booleans for web server
      ansible.posix.seboolean:
        name: "{{ item }}"
        state: true
        persistent: true
      loop:
        - httpd_can_network_connect
        - httpd_can_network_connect_db
    
    # File management
    - name: Deploy web configuration
      ansible.builtin.template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
        backup: true
      notify: restart httpd
    
    # Scheduled tasks
    - name: Schedule log rotation
      ansible.builtin.cron:
        name: "Web log rotation"
        minute: "0"
        hour: "2"
        job: "/usr/sbin/logrotate /etc/httpd/conf/httpd-logs"
        state: present
  
  handlers:
    - name: restart httpd
      ansible.builtin.systemd:
        name: httpd
        state: restarted
```

---

## 🚨 Common Exam Scenarios

### Scenario 1: LAMP Stack Deployment

```yaml
---
# LAMP stack automation
- name: Deploy LAMP stack
  hosts: webservers
  become: true
  
  tasks:
    # Install packages
    - name: Install LAMP packages
      ansible.builtin.dnf:
        name:
          - httpd
          - mariadb-server
          - php
          - php-mysql
        state: present
    
    # Start services
    - name: Start LAMP services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: started
        enabled: true
      loop:
        - httpd
        - mariadb
    
    # Configure firewall
    - name: Allow web traffic
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - http
        - https
    
    # Create database
    - name: Create application database
      community.mysql.mysql_db:
        name: webapp
        state: present
    
    # Create database user
    - name: Create database user
      community.mysql.mysql_user:
        name: webuser
        password: "{{ db_password }}"
        priv: "webapp.*:ALL"
        state: present
```

### Scenario 2: Storage and User Setup

```yaml
---
# Storage and user automation
- name: Configure storage and users
  hosts: all
  become: true
  
  tasks:
    # Storage setup
    - name: Create data partition
      community.general.parted:
        device: /dev/vdb
        number: 1
        part_end: 10GiB
        state: present
    
    - name: Create volume group
      community.general.lvg:
        vg: app_vg
        pvs: /dev/vdb1
        state: present
    
    - name: Create logical volume
      community.general.lvol:
        vg: app_vg
        lv: data_lv
        size: 8G
        state: present
    
    - name: Create filesystem
      community.general.filesystem:
        fstype: xfs
        dev: /dev/app_vg/data_lv
    
    - name: Mount filesystem
      ansible.posix.mount:
        path: /data
        src: /dev/app_vg/data_lv
        fstype: xfs
        state: mounted
    
    # User setup
    - name: Create application group
      ansible.builtin.group:
        name: appusers
        gid: 2000
        state: present
    
    - name: Create application users
      ansible.builtin.user:
        name: "{{ item }}"
        group: appusers
        home: "/data/{{ item }}"
        create_home: true
        shell: /bin/bash
        state: present
      loop:
        - dev1
        - dev2
        - dev3
    
    # Set permissions
    - name: Set data directory permissions
      ansible.builtin.file:
        path: /data
        owner: root
        group: appusers
        mode: '0775'
        recurse: true
```

---

## 📋 Exam-Specific Best Practices

### Module Selection Strategy

**Always use FQCN in exam**:
- `ansible.builtin.dnf` not `dnf`
- `ansible.builtin.systemd` not `systemd`
- `community.general.parted` not `parted`
- `ansible.posix.firewalld` not `firewalld`

### Task Ordering

**Critical sequence for system setup**:
1. Package installation
2. User/group creation
3. Storage configuration
4. Service configuration
5. Firewall rules
6. SELinux settings
7. Service startup
8. Scheduled tasks

### Error Handling Patterns

```yaml
# Always include error handling for critical tasks
- name: Critical system configuration
  block:
    - name: Configure system service
      ansible.builtin.systemd:
        name: important-service
        state: started
        enabled: true
    
    - name: Verify service is running
      ansible.builtin.systemd:
        name: important-service
      register: service_status
      failed_when: service_status.status.ActiveState != "active"
  
  rescue:
    - name: Handle service failure
      ansible.builtin.debug:
        msg: "Service failed to start, checking logs..."
    
    - name: Check service logs
      ansible.builtin.command:
        cmd: journalctl -u important-service --no-pager
      register: service_logs
    
    - name: Display service logs
      ansible.builtin.debug:
        var: service_logs.stdout_lines
```

---

## 🎯 Key Takeaways for Experienced Users

1. **RHCSA tasks via Ansible** - Core exam requirement is automating what you do manually
2. **Module mastery is critical** - Know the parameters for key modules inside and out  
3. **FQCN usage required** - Always use fully qualified collection names
4. **Error handling matters** - Include proper validation and error checking
5. **Integration approach** - Tasks often chain together for complete system setup

### Essential Module Quick Reference

**Must memorize for exam:**
- `ansible.builtin.dnf` - Package management
- `ansible.builtin.systemd` - Service management  
- `ansible.builtin.user`/`group` - Account management
- `community.general.parted`/`lvg`/`lvol` - Storage
- `ansible.posix.firewalld` - Firewall
- `ansible.posix.seboolean` - SELinux
- `ansible.builtin.template` - Configuration files

Remember: The exam tests your ability to automate RHCSA tasks, not learn new concepts. Focus on the Ansible implementation of tasks you already know!
