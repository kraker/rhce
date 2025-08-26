# Module 08: Ansible Vault & Advanced Features

## 🎯 Learning Objectives

By the end of this module, you will:
- Master Ansible Vault for encrypting sensitive data and secure automation
- Implement advanced security practices for credential management
- Use dynamic inventories for cloud and large-scale environments
- Optimize Ansible performance for enterprise deployments
- Debug complex automation issues with advanced troubleshooting techniques
- Apply best practices for production Ansible environments
- Understand Ansible's architecture and extending capabilities

## 📋 Why Security and Advanced Features Matter

### Security Challenges in Automation

**Common Security Issues**:
- Passwords and API keys stored in plain text
- Sensitive configuration data exposed in version control
- Inadequate access controls on automation systems
- Lack of audit trails for automated changes

**Ansible Vault Solutions**:
- **Encryption at rest**: Sensitive data encrypted in files
- **Granular encryption**: Encrypt individual variables or entire files
- **Multiple vault passwords**: Different encryption keys for different purposes
- **Integration**: Seamless integration with existing automation workflows

### Advanced Features for Enterprise

**Enterprise Requirements**:
- **Scale**: Manage thousands of systems efficiently
- **Performance**: Minimize execution time across large infrastructures  
- **Flexibility**: Adapt to dynamic, cloud-native environments
- **Observability**: Comprehensive logging and monitoring
- **Extensibility**: Custom modules and plugins for specific needs

---

## 🔐 Ansible Vault Fundamentals

### Basic Vault Operations

**Creating Encrypted Files**:
```bash
# Create new encrypted file
ansible-vault create secrets.yml

# This will open your default editor with an empty file
# Content will be encrypted when saved
---
database_password: "super_secret_password"
api_key: "abcd1234567890"
ssl_private_key: |
  -----BEGIN PRIVATE KEY-----
  MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
  -----END PRIVATE KEY-----
```

**Viewing Encrypted Files**:
```bash
# View encrypted file content
ansible-vault view secrets.yml

# Edit existing encrypted file
ansible-vault edit secrets.yml

# Show encrypted file structure (without decrypting)
cat secrets.yml
```

**File Encryption Operations**:
```bash
# Encrypt existing plain text file
ansible-vault encrypt existing_secrets.yml

# Decrypt file (permanently removes encryption)
ansible-vault decrypt secrets.yml

# Change vault password
ansible-vault rekey secrets.yml

# Change password for multiple files
ansible-vault rekey secrets.yml database.yml api_config.yml
```

### String Encryption for Inline Variables

```bash
# Encrypt a single string
ansible-vault encrypt_string 'secret_password' --name 'db_password'

# Output (to paste in playbooks/variables):
db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653761623...
          (encrypted content)

# Encrypt with specific vault ID
ansible-vault encrypt_string --vault-id prod@prompt 'secret_password' --name 'db_password'

# Encrypt multiple strings interactively
ansible-vault encrypt_string --stdin-name 'variable_name'
```

**Using Encrypted Strings in Playbooks**:
```yaml
---
- name: Deploy application with encrypted credentials
  hosts: all
  vars:
    # Plain text variables
    app_name: myapp
    app_port: 8080
    
    # Encrypted variables (generated with encrypt_string)
    db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653761623435363238643433643362643132613633353534303939666531323231
          3637626631376565376232363732653838376637636163630a383964393936653163386533
          ...
    api_secret_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          31313063396261653838376637636163630a383964393936653163386533666365376462
          66386439653761623435363238643433643362643132613633353534303939666531323231
          ...
  tasks:
    - name: Configure application with encrypted credentials
      ansible.builtin.template:
        src: app_config.j2
        dest: /etc/myapp/config.conf
        mode: '0600'
      vars:
        database_url: "mysql://user:{{ db_password }}@db.example.com/myapp"
        secret_key: "{{ api_secret_key }}"
```

---

## 🔑 Vault Password Management

### Password File Method

```bash
# Create vault password file
echo 'your_vault_password' > .vault_password
chmod 600 .vault_password

# Use password file with ansible-navigator
ansible-navigator run site.yml --vault-password-file .vault_password --mode stdout

# Configure in ansible.cfg
cat >> ansible.cfg << 'EOF'
[defaults]
vault_password_file = .vault_password
EOF
```

### Multiple Vault IDs

**Creating Multiple Vault Files**:
```bash
# Create different vault files with different IDs
ansible-vault create --vault-id dev@prompt dev_secrets.yml
ansible-vault create --vault-id prod@prompt prod_secrets.yml
ansible-vault create --vault-id shared@prompt shared_secrets.yml

# Create password files for different environments
echo 'dev_vault_password' > .vault_password_dev
echo 'prod_vault_password' > .vault_password_prod
chmod 600 .vault_password_*
```

**Using Multiple Vault IDs**:
```bash
# Specify multiple vault password sources
ansible-navigator run site.yml \
  --vault-id dev@.vault_password_dev \
  --vault-id prod@.vault_password_prod \
  --vault-id shared@prompt \
  --mode stdout

# Environment-specific decryption
ansible-navigator run deploy.yml \
  --vault-id prod@.vault_password_prod \
  --limit production \
  --mode stdout
```

**Vault ID in Playbook Structure**:
```yaml
---
- name: Multi-environment deployment
  hosts: all
  vars_files:
    - group_vars/all/common.yml
    - "group_vars/{{ environment }}/secrets.yml"  # Contains vault_id specific encryption
  vars:
    # Shared secrets (encrypted with shared@vault_id)
    monitoring_api_key: !vault |
          $ANSIBLE_VAULT;1.2;AES256;shared
          66386439653761623435363238643433643362643132613633353534303939666531323231
          ...

    # Environment-specific secrets
    database_password: !vault |
          $ANSIBLE_VAULT;1.2;AES256;prod
          31313063396261653838376637636163630a383964393936653163386533666365376462
          ...
```

### Script-Based Password Retrieval

**Password Retrieval Script** (`get_vault_password.py`):
```python
#!/usr/bin/env python3
import os
import sys
import getpass
from subprocess import check_output, CalledProcessError

def get_password_from_keyring(vault_id):
    """Retrieve password from system keyring"""
    try:
        import keyring
        return keyring.get_password("ansible-vault", vault_id)
    except ImportError:
        return None

def get_password_from_env(vault_id):
    """Retrieve password from environment variable"""
    env_var = f"ANSIBLE_VAULT_{vault_id.upper()}"
    return os.environ.get(env_var)

def get_password_from_file(vault_id):
    """Retrieve password from secure file"""
    password_file = f"/secure/vault_passwords/{vault_id}"
    try:
        with open(password_file, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        return None

def main():
    vault_id = sys.argv[1] if len(sys.argv) > 1 else 'default'
    
    # Try multiple password sources
    password = (
        get_password_from_keyring(vault_id) or
        get_password_from_env(vault_id) or
        get_password_from_file(vault_id) or
        getpass.getpass(f"Vault password for {vault_id}: ")
    )
    
    if password:
        print(password)
        sys.exit(0)
    else:
        sys.stderr.write(f"Could not retrieve vault password for {vault_id}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

**Using Password Script**:
```bash
# Make script executable
chmod +x get_vault_password.py

# Use with ansible-navigator
ansible-navigator run site.yml \
  --vault-id dev@./get_vault_password.py \
  --vault-id prod@./get_vault_password.py \
  --mode stdout
```

---

## 🗂️ Organizing Encrypted Data

### Vault File Organization

**Directory Structure**:
```
inventory/
├── group_vars/
│   ├── all/
│   │   ├── common.yml              # Plain text variables
│   │   └── vault.yml               # Encrypted variables
│   ├── production/
│   │   ├── vars.yml                # Plain text variables
│   │   └── vault.yml               # Production secrets
│   └── development/
│       ├── vars.yml                # Plain text variables  
│       └── vault.yml               # Development secrets
├── host_vars/
│   ├── web01.example.com/
│   │   ├── vars.yml                # Plain text host variables
│   │   └── vault.yml               # Host-specific secrets
└── vaults/
    ├── database_passwords.yml      # Database credentials
    ├── api_keys.yml               # API keys and tokens
    └── certificates.yml           # SSL certificates and keys
```

**Variable Naming Convention**:
```yaml
# group_vars/all/vault.yml
---
# Database passwords
vault_mysql_root_password: !vault |
    $ANSIBLE_VAULT;1.1;AES256...

vault_app_database_password: !vault |
    $ANSIBLE_VAULT;1.1;AES256...

# API credentials
vault_monitoring_api_key: !vault |
    $ANSIBLE_VAULT;1.1;AES256...

vault_backup_service_token: !vault |
    $ANSIBLE_VAULT;1.1;AES256...

# SSL certificates
vault_ssl_private_key: !vault |
    $ANSIBLE_VAULT;1.1;AES256...
```

**Reference from Plain Text Files**:
```yaml
# group_vars/all/common.yml
---
# Reference encrypted variables
mysql_root_password: "{{ vault_mysql_root_password }}"
app_database_password: "{{ vault_app_database_password }}"
monitoring_api_key: "{{ vault_monitoring_api_key }}"

# Plain text configuration
mysql_port: 3306
mysql_datadir: /var/lib/mysql
backup_schedule: "0 2 * * *"
```

### Mixed Encryption Patterns

**Template with Encrypted Content**:
```yaml
---
- name: Deploy configuration with mixed content
  hosts: all
  become: yes
  vars:
    # Plain text variables
    app_name: myapp
    app_version: "1.2.3"
    log_level: info
    
    # Encrypted sensitive variables
    database_url: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653761623435363238643433643362643132613633353534303939666531323231
          ...
    secret_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          31313063396261653838376637636163630a383964393936653163386533666365376462
          ...
  tasks:
    - name: Deploy application configuration
      ansible.builtin.template:
        src: app.conf.j2
        dest: /etc/myapp/app.conf
        owner: myapp
        group: myapp
        mode: '0600'
        backup: yes
```

**Template File** (`templates/app.conf.j2`):
```jinja2
# {{ app_name }} Configuration
# Version: {{ app_version }}
# Generated: {{ ansible_date_time.iso8601 }}

[application]
name={{ app_name }}
version={{ app_version }}
log_level={{ log_level }}

[database]
url={{ database_url }}

[security]
secret_key={{ secret_key }}
{% if ssl_enabled | default(false) %}
ssl_cert={{ ssl_cert_path }}
ssl_key={{ ssl_key_path }}
{% endif %}

[monitoring]
{% if monitoring_enabled | default(true) %}
api_key={{ vault_monitoring_api_key }}
endpoint={{ monitoring_endpoint }}
{% endif %}
```

---

## 🌐 Dynamic Inventories

### Cloud-Based Dynamic Inventories

**AWS EC2 Dynamic Inventory**:
```yaml
# aws_ec2.yml
---
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
  - us-west-2
filters:
  tag:Environment:
    - production
    - staging
  instance-state-name: running

keyed_groups:
  # Group by instance type
  - key: instance_type
    prefix: type
  # Group by availability zone
  - key: placement.availability_zone
    prefix: az
  # Group by security groups
  - key: security_groups | map(attribute='group_name')
    prefix: sg

hostnames:
  - tag:Name
  - dns-name
  - private-ip-address

compose:
  # Create custom variables from AWS data
  aws_region: placement.region
  aws_account_id: owner_id
  instance_name: tags.Name | default('unnamed')
  environment: tags.Environment | default('unknown')

cache: true
cache_plugin: jsonfile
cache_timeout: 3600
cache_connection: /tmp/ansible-aws-inventory
```

**Using Dynamic Inventory**:
```bash
# Test dynamic inventory
ansible-inventory -i aws_ec2.yml --list

# Use with playbooks
ansible-navigator run site.yml -i aws_ec2.yml --mode stdout

# Target specific groups created by dynamic inventory
ansible-navigator run web_deploy.yml -i aws_ec2.yml --limit type_t3_medium --mode stdout
```

### Custom Dynamic Inventory Scripts

**Python Inventory Script** (`custom_inventory.py`):
```python
#!/usr/bin/env python3
import json
import sys
import argparse
import requests
from typing import Dict, Any

def get_inventory_from_cmdb() -> Dict[str, Any]:
    """Fetch inventory from Configuration Management Database"""
    inventory = {
        '_meta': {
            'hostvars': {}
        }
    }
    
    # Example: Fetch from REST API
    try:
        response = requests.get('https://cmdb.example.com/api/hosts', 
                              timeout=30)
        response.raise_for_status()
        hosts_data = response.json()
        
        for host in hosts_data:
            hostname = host['hostname']
            
            # Add to appropriate groups
            for role in host.get('roles', []):
                if role not in inventory:
                    inventory[role] = {'hosts': [], 'vars': {}}
                inventory[role]['hosts'].append(hostname)
            
            # Add environment groups
            env = host.get('environment', 'unknown')
            env_group = f"env_{env}"
            if env_group not in inventory:
                inventory[env_group] = {'hosts': [], 'vars': {}}
            inventory[env_group]['hosts'].append(hostname)
            
            # Set host variables
            inventory['_meta']['hostvars'][hostname] = {
                'ansible_host': host.get('ip_address'),
                'ansible_user': host.get('ssh_user', 'ansible'),
                'environment': env,
                'data_center': host.get('datacenter'),
                'hardware_type': host.get('hardware_type'),
                'custom_vars': host.get('custom_variables', {})
            }
    
    except requests.RequestException as e:
        print(f"Error fetching inventory: {e}", file=sys.stderr)
        sys.exit(1)
    
    return inventory

def get_host_vars(hostname: str) -> Dict[str, Any]:
    """Get variables for specific host"""
    inventory = get_inventory_from_cmdb()
    return inventory['_meta']['hostvars'].get(hostname, {})

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true',
                       help='List all hosts')
    parser.add_argument('--host', 
                       help='Get variables for specific host')
    args = parser.parse_args()
    
    if args.list:
        inventory = get_inventory_from_cmdb()
        print(json.dumps(inventory, indent=2))
    elif args.host:
        host_vars = get_host_vars(args.host)
        print(json.dumps(host_vars, indent=2))
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
```

**Making Script Executable and Testing**:
```bash
# Make script executable
chmod +x custom_inventory.py

# Test inventory script
./custom_inventory.py --list | jq .

# Test host-specific variables
./custom_inventory.py --host web01.example.com | jq .

# Use with Ansible
ansible-navigator run site.yml -i ./custom_inventory.py --mode stdout
```

---

## ⚡ Performance Optimization

### Execution Performance Tuning

**Ansible Configuration** (`ansible.cfg`):
```ini
[defaults]
# Increase parallelism
forks = 20
host_key_checking = False

# Connection optimization
timeout = 30
gather_timeout = 30

# SSH optimization
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o ControlPath=/tmp/.ansible-cp-%h-%p-%r
pipelining = True
retries = 3
```

**Performance-Optimized Playbook Patterns**:
```yaml
---
- name: High-performance deployment
  hosts: all
  gather_facts: no  # Skip fact gathering when not needed
  strategy: free    # Allow hosts to complete tasks independently
  tasks:
    # Gather only essential facts
    - name: Gather minimal facts
      ansible.builtin.setup:
        gather_subset:
          - network
          - hardware
      when: need_system_info | default(false)

    # Use async for long-running tasks
    - name: Download large package
      ansible.builtin.get_url:
        url: "{{ package_url }}"
        dest: "/tmp/{{ package_name }}"
      async: 300  # 5 minute timeout
      poll: 0     # Fire and forget
      register: download_job

    # Batch operations efficiently  
    - name: Install multiple packages in single task
      ansible.builtin.dnf:
        name: "{{ packages }}"
        state: present
      vars:
        packages:
          - httpd
          - php
          - mysql-server
          - git

    # Check async job completion
    - name: Wait for download completion
      ansible.builtin.async_status:
        jid: "{{ download_job.ansible_job_id }}"
      register: download_result
      until: download_result.finished
      retries: 30
      delay: 10
      when: download_job.ansible_job_id is defined
```

### Memory and Resource Optimization

**Large File Handling**:
```yaml
---
- name: Efficient large file operations
  hosts: all
  tasks:
    # Use synchronize for large file transfers
    - name: Sync large directory
      ansible.posix.synchronize:
        src: /local/large_directory/
        dest: /remote/large_directory/
        delete: yes
        compress: yes
        times: yes
      delegate_to: localhost

    # Stream large file downloads
    - name: Download large file with streaming
      ansible.builtin.uri:
        url: "{{ large_file_url }}"
        dest: "/tmp/large_file.tar.gz"
        creates: "/tmp/large_file.tar.gz"
        timeout: 3600
        follow_redirects: all

    # Process files in chunks
    - name: Process log files in chunks
      ansible.builtin.lineinfile:
        path: "{{ item }}"
        regexp: "{{ log_pattern }}"
        line: "{{ replacement_line }}"
      loop: "{{ log_files[:50] }}"  # Process first 50 files
      when: log_files | length > 0
```

**Connection Pooling and Reuse**:
```yaml
---
- name: Connection optimization example
  hosts: all
  vars:
    ansible_ssh_common_args: >
      -o ControlMaster=auto
      -o ControlPersist=3600s
      -o ControlPath=/tmp/.ansible-cp-%h-%p-%r
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=/dev/null
  tasks:
    # Multiple tasks will reuse the same SSH connection
    - name: Check disk space
      ansible.builtin.shell: df -h

    - name: Check memory usage
      ansible.builtin.shell: free -m

    - name: Check process list
      ansible.builtin.shell: ps aux | head -20
```

---

## 🔧 Advanced Debugging and Troubleshooting

### Debug Information Collection

**Comprehensive Debug Playbook**:
```yaml
---
- name: Ansible debugging and diagnostics
  hosts: all
  gather_facts: yes
  tasks:
    # System information
    - name: Display system facts
      ansible.builtin.debug:
        msg: |
          Host: {{ inventory_hostname }}
          OS: {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}
          Architecture: {{ ansible_facts['architecture'] }}
          Memory: {{ ansible_facts['memtotal_mb'] }}MB
          Python: {{ ansible_facts['python_version'] }}
          IP: {{ ansible_facts['default_ipv4']['address'] | default('N/A') }}

    # Connection information
    - name: Display connection details
      ansible.builtin.debug:
        msg: |
          Connection type: {{ ansible_connection | default('ssh') }}
          User: {{ ansible_user | default('not specified') }}
          Host: {{ ansible_host | default(inventory_hostname) }}
          Port: {{ ansible_port | default(22) }}

    # Variable information
    - name: Display variable information
      ansible.builtin.debug:
        msg: |
          Groups: {{ group_names }}
          Play hosts: {{ play_hosts }}
          Inventory hostname: {{ inventory_hostname }}
          Magic variables available: {{ hostvars[inventory_hostname].keys() | length }} keys

    # Test connectivity and permissions
    - name: Test basic operations
      block:
        - name: Test write permissions
          ansible.builtin.copy:
            content: "Test file created at {{ ansible_date_time.iso8601 }}"
            dest: /tmp/ansible_test
          register: write_test

        - name: Test command execution
          ansible.builtin.command: whoami
          register: whoami_result
          changed_when: false

        - name: Test privilege escalation
          ansible.builtin.command: whoami
          become: yes
          register: sudo_test
          changed_when: false

        - name: Display test results
          ansible.builtin.debug:
            msg: |
              Write test: {{ 'PASS' if write_test is succeeded else 'FAIL' }}
              Command execution: {{ whoami_result.stdout }}
              Privilege escalation: {{ sudo_test.stdout }}

      rescue:
        - name: Display error information
          ansible.builtin.debug:
            msg: |
              Error occurred during testing
              Write test failed: {{ write_test is failed }}
              Command failed: {{ whoami_result is failed | default(false) }}
              Sudo failed: {{ sudo_test is failed | default(false) }}

    # Cleanup
    - name: Cleanup test files
      ansible.builtin.file:
        path: /tmp/ansible_test
        state: absent
      ignore_errors: yes
```

### Error Analysis and Resolution

**Common Error Patterns and Solutions**:
```yaml
---
- name: Error handling and resolution patterns
  hosts: all
  tasks:
    # Handle SSH connection issues
    - name: Test SSH connectivity
      ansible.builtin.ping:
      register: ping_result
      ignore_errors: yes

    - name: Debug SSH issues
      ansible.builtin.debug:
        msg: |
          SSH connection failed. Check:
          1. Host {{ ansible_host | default(inventory_hostname) }} is reachable
          2. SSH service is running on port {{ ansible_port | default(22) }}
          3. SSH key authentication is configured
          4. User {{ ansible_user | default('root') }} exists and has access
      when: ping_result is failed

    # Handle permission issues
    - name: Test file operations with error handling
      block:
        - name: Attempt file creation
          ansible.builtin.copy:
            content: "test content"
            dest: "{{ test_file_path }}"
          vars:
            test_file_path: /etc/test_ansible_access

      rescue:
        - name: Handle permission errors
          ansible.builtin.debug:
            msg: |
              Permission denied. Possible solutions:
              1. Use 'become: yes' for privilege escalation
              2. Check file/directory permissions
              3. Verify sudo configuration for user {{ ansible_user }}
              4. Check SELinux/AppArmor policies

        - name: Retry with privilege escalation
          ansible.builtin.copy:
            content: "test content"
            dest: /tmp/test_ansible_access
          become: yes

    # Handle package management issues
    - name: Install package with error handling
      ansible.builtin.dnf:
        name: nonexistent-package
        state: present
      register: package_result
      ignore_errors: yes

    - name: Debug package issues
      ansible.builtin.debug:
        msg: |
          Package installation failed: {{ package_result.msg }}
          Common solutions:
          1. Check package name spelling
          2. Verify repository configuration
          3. Update package cache: dnf makecache
          4. Check network connectivity to repositories
      when: package_result is failed
```

---

## 🏗️ Advanced Ansible Patterns

### Custom Modules and Plugins

**Simple Custom Module** (`library/custom_service_check.py`):
```python
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import subprocess
import json

def check_service_health(service_name, port=None):
    """Check if service is running and optionally test port connectivity"""
    result = {'service_running': False, 'port_open': False}
    
    # Check if service is running
    try:
        cmd = ['systemctl', 'is-active', service_name]
        proc = subprocess.run(cmd, capture_output=True, text=True)
        result['service_running'] = proc.returncode == 0
        result['service_status'] = proc.stdout.strip()
    except Exception as e:
        result['service_error'] = str(e)
    
    # Check port connectivity if specified
    if port:
        try:
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result['port_open'] = sock.connect_ex(('localhost', port)) == 0
            sock.close()
        except Exception as e:
            result['port_error'] = str(e)
    
    return result

def main():
    module = AnsibleModule(
        argument_spec=dict(
            service=dict(type='str', required=True),
            port=dict(type='int', required=False),
            expected_status=dict(type='str', default='active', 
                               choices=['active', 'inactive', 'failed'])
        ),
        supports_check_mode=True
    )
    
    service = module.params['service']
    port = module.params['port']
    expected_status = module.params['expected_status']
    
    if module.check_mode:
        module.exit_json(changed=False, msg="Check mode - no changes made")
    
    health_check = check_service_health(service, port)
    
    # Determine if service meets expected criteria
    service_ok = health_check.get('service_status') == expected_status
    port_ok = health_check.get('port_open', True) if port else True
    
    overall_health = service_ok and port_ok
    
    result = {
        'changed': False,
        'service_name': service,
        'health_check': health_check,
        'healthy': overall_health,
        'msg': f"Service {service} is {'healthy' if overall_health else 'unhealthy'}"
    }
    
    if overall_health:
        module.exit_json(**result)
    else:
        module.fail_json(**result)

if __name__ == '__main__':
    main()
```

**Using Custom Module**:
```yaml
---
- name: Use custom service health check module
  hosts: all
  tasks:
    - name: Check web service health
      custom_service_check:
        service: httpd
        port: 80
        expected_status: active
      register: web_health

    - name: Display health check results
      ansible.builtin.debug:
        var: web_health

    - name: Take action based on health check
      ansible.builtin.systemd:
        name: httpd
        state: restarted
      when: not web_health.healthy
```

### Advanced Templating and Filters

**Custom Filter Plugin** (`filter_plugins/network_filters.py`):
```python
def calculate_network(ip_address, subnet_mask):
    """Calculate network address from IP and subnet mask"""
    import ipaddress
    try:
        network = ipaddress.IPv4Network(f"{ip_address}/{subnet_mask}", strict=False)
        return {
            'network': str(network.network_address),
            'broadcast': str(network.broadcast_address),
            'netmask': str(network.netmask),
            'hostmask': str(network.hostmask),
            'num_addresses': network.num_addresses,
            'cidr': str(network)
        }
    except ValueError as e:
        return {'error': str(e)}

def subnet_hosts(network_cidr):
    """Generate list of host IPs in a subnet"""
    import ipaddress
    try:
        network = ipaddress.IPv4Network(network_cidr)
        return [str(ip) for ip in network.hosts()]
    except ValueError as e:
        return []

class FilterModule(object):
    """Custom network filters"""
    def filters(self):
        return {
            'calculate_network': calculate_network,
            'subnet_hosts': subnet_hosts
        }
```

**Using Custom Filters**:
```yaml
---
- name: Network configuration with custom filters
  hosts: all
  vars:
    server_ip: "{{ ansible_default_ipv4.address }}"
    subnet_mask: "{{ ansible_default_ipv4.netmask }}"
  tasks:
    - name: Calculate network information
      ansible.builtin.set_fact:
        network_info: "{{ server_ip | calculate_network(subnet_mask) }}"

    - name: Display network information
      ansible.builtin.debug:
        msg: |
          Server: {{ server_ip }}
          Network: {{ network_info.network }}
          Broadcast: {{ network_info.broadcast }}
          CIDR: {{ network_info.cidr }}
          Available addresses: {{ network_info.num_addresses }}

    - name: Generate host list for subnet
      ansible.builtin.set_fact:
        subnet_hosts: "{{ network_info.cidr | subnet_hosts }}"

    - name: Show first 10 available IPs
      ansible.builtin.debug:
        msg: "Available IPs: {{ subnet_hosts[:10] | join(', ') }}"
```

---

## 🧪 Practical Lab Exercises

### Exercise 1: Comprehensive Vault Implementation

**Create a secure automation setup**:
1. Set up multiple vault password files for different environments
2. Create encrypted variable files for database passwords, API keys, and SSL certificates
3. Implement a password retrieval script using environment variables
4. Create playbooks that use mixed encrypted and plain text variables
5. Test vault operations across different environments

### Exercise 2: Dynamic Inventory Integration

**Build dynamic inventory system**:
1. Create a Python script that fetches inventory from a REST API
2. Implement caching for performance optimization
3. Add custom group creation based on host attributes
4. Create host variables from external data sources
5. Test integration with cloud provider dynamic inventories

### Exercise 3: Performance Optimization Project

**Optimize automation for large-scale deployment**:
1. Configure Ansible for high-performance execution
2. Implement async operations for long-running tasks
3. Use connection pooling and SSH optimizations
4. Create efficient playbooks with minimal fact gathering
5. Benchmark and compare execution times

### Exercise 4: Advanced Debugging and Monitoring

**Create comprehensive debugging toolkit**:
1. Build debugging playbooks for common issues
2. Implement custom modules for health checking
3. Create logging and monitoring integration
4. Develop troubleshooting runbooks
5. Set up automated error reporting

---

## 🎯 Key Takeaways

### Security Mastery with Ansible Vault
- **Data protection**: Encrypt all sensitive data including passwords, keys, and certificates
- **Vault organization**: Use consistent naming and directory structures for encrypted files
- **Multiple environments**: Implement separate vault passwords for different environments
- **Automation integration**: Seamlessly integrate vault operations into CI/CD pipelines

### Advanced Features Proficiency
- **Dynamic inventories**: Adapt to cloud and container environments with automatic discovery
- **Performance optimization**: Configure Ansible for enterprise-scale deployments
- **Extensibility**: Create custom modules and plugins for specific organizational needs
- **Debugging expertise**: Develop systematic approaches to troubleshooting complex automation

### Production Best Practices
- **Security first**: Implement defense-in-depth security practices for automation systems
- **Scalability**: Design automation that grows with infrastructure needs
- **Monitoring**: Implement comprehensive logging and monitoring of automation activities
- **Documentation**: Maintain detailed documentation of advanced configurations and customizations

### Enterprise Integration
- **External systems**: Integrate with Configuration Management Databases and monitoring systems
- **Compliance**: Implement automation that supports regulatory and security compliance
- **Change management**: Integrate automation with organizational change management processes
- **Team collaboration**: Structure automation projects for multiple team collaboration

---

## 🔗 Final Steps and Continuing Education

### RHCE Exam Readiness
With completion of all 8 modules, you have comprehensive coverage of:
- ✅ **Exam Objective 1**: Understanding core Ansible components
- ✅ **Exam Objective 2**: Using roles and Ansible Content Collections
- ✅ **Exam Objective 3**: Installing and configuring Ansible control node
- ✅ **Exam Objective 4**: Configuring Ansible managed nodes
- ✅ **Exam Objective 5**: Running playbooks with Automation content navigator
- ✅ **Exam Objective 6**: Creating Ansible plays and playbooks
- ✅ **Exam Objective 7**: Automating standard RHCSA tasks
- ✅ **Exam Objective 8**: Managing content with templates and Ansible Vault

### Continuing Your Ansible Journey
- **Advanced Automation Platform**: Explore Red Hat Ansible Automation Platform (AAP)
- **Ansible Tower/AWX**: Learn enterprise automation with web UI and API
- **CI/CD Integration**: Integrate Ansible with GitLab CI, Jenkins, and other tools
- **Container Automation**: Explore Ansible for Kubernetes and container management
- **Network Automation**: Extend skills to network device automation
- **Community Contribution**: Contribute to Ansible community projects and collections

### Professional Development
- **Certification Progression**: Consider DCI (Deployment and Continuous Integration) specialization
- **Advanced Specializations**: Pursue OpenShift, Security, or Networking specializations
- **Community Engagement**: Join Ansible user groups and contribute to open source projects
- **Continuous Learning**: Stay updated with new Ansible features and best practices

**Congratulations!** You now have comprehensive RHCE-level Ansible automation skills. Apply these skills in real-world scenarios, continue practicing, and good luck with your certification journey!

---

**Study Complete** - Ready for RHCE EX294 Certification! 🎯