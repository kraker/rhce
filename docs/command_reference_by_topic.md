# RHCE Command Reference by Exam Topic

## 🎯 Comprehensive Command Reference for RHCE Exam Success

*Complete command reference organized by official RHCE exam objectives with all variations, parameters, and use cases*

This comprehensive reference covers every essential command pattern you'll encounter on the RHCE exam. All commands are organized by exam objectives and include practical variations, common parameters, and real-world usage patterns.

**📚 Source Integration**: Commands and patterns synthesized from:
- Sander van Vugt's RHCE Guide (16 chapters)
- Jeff Geerling's Ansible for DevOps (15 chapters)
- Michael Jang's RHCSA/RHCE Guide
- Red Hat official documentation and best practices

**🎯 Exam Focus**: Every command has been verified for exam relevance and includes the most commonly tested parameters and use cases.

**📊 Coverage Statistics**: This comprehensive reference includes:
- 200+ essential command patterns
- 50+ module documentation lookups
- 100+ debugging and troubleshooting techniques
- 75+ vault operations and security practices
- Complete ansible-navigator TUI reference
- Advanced execution environment management
- Performance optimization techniques

---

## 1. Install and Configure Ansible Control Node

### Package Installation and Setup
```bash
# RHEL 9 Installation (Primary Method)
sudo dnf install ansible-core python3-pip
sudo dnf install ansible-navigator        # Modern execution tool
sudo dnf install python3-argcomplete      # Command completion
sudo dnf install git                       # Version control for playbooks

# Enable EPEL for additional packages
sudo dnf install epel-release
sudo dnf install ansible-lint             # Playbook linting

# Alternative: Install via pip (if needed)
pip3 install --user ansible ansible-navigator
pip3 install --user ansible-lint yamllint

# Verify installation
ansible --version
ansible-navigator --version
ansible-lint --version
ansible-doc --version

# Show installation details
ansible --version | head -5
python3 -m ansible --version
which ansible
which ansible-navigator

# Command completion setup (optional)
activate-global-python-argcomplete --user
echo 'eval "$(register-python-argcomplete ansible)"' >> ~/.bashrc
echo 'eval "$(register-python-argcomplete ansible-config)"' >> ~/.bashrc
echo 'eval "$(register-python-argcomplete ansible-doc)"' >> ~/.bashrc

# Directory structure setup
mkdir -p ~/ansible/{playbooks,roles,inventories,group_vars,host_vars}
mkdir -p ~/ansible/collections/ansible_collections
mkdir -p ~/ansible/files/{templates,scripts}
```

### Configuration Files and Management
```bash
# Configuration hierarchy (highest priority first):
# 1. ANSIBLE_CONFIG environment variable
# 2. ./ansible.cfg (current directory)
# 3. ~/.ansible.cfg (home directory)
# 4. /etc/ansible/ansible.cfg (global)

# Create project-specific configuration
vim ./ansible.cfg
cat > ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = ./inventory.ini
roles_path = ./roles
collections_paths = ./collections
remote_user = ansible
become = True
become_method = sudo
become_user = root
become_ask_pass = False
timeout = 30
forks = 5
gathering = smart
fact_caching = memory
fact_caching_timeout = 86400
stdout_callback = yaml
bin_ansible_callbacks = True
EOF

# Global configuration
sudo vim /etc/ansible/ansible.cfg

# User-specific configuration
vim ~/.ansible.cfg

# Configuration management commands
ansible-config list                        # List all config options
ansible-config dump                        # Show all current settings
ansible-config dump --only-changed        # Show only modified settings
ansible-config view                        # Show active config file
ansible-config init --disabled > ansible.cfg  # Generate sample config

# Environment variable method
export ANSIBLE_CONFIG=~/ansible/project1/ansible.cfg
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_INVENTORY=~/ansible/inventory.ini
export ANSIBLE_ROLES_PATH=~/ansible/roles
export ANSIBLE_COLLECTIONS_PATH=~/ansible/collections
export ANSIBLE_REMOTE_USER=ansible
export ANSIBLE_BECOME=True
export ANSIBLE_BECOME_METHOD=sudo
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_FORKS=10
export ANSIBLE_TIMEOUT=60

# Verify configuration settings
ansible-config dump | grep -E '(HOST_KEY_CHECKING|INVENTORY|REMOTE_USER|BECOME)'
ansible-config list | grep -i vault
ansible all --list-hosts

# Configuration validation
ansible-config dump | grep -E 'ERROR|WARNING'
ansible localhost -m setup | head -5
```

### Inventory Management and Validation
```bash
# Basic inventory operations
ansible-inventory --list                   # JSON format output
ansible-inventory --list --yaml           # YAML format output
ansible-inventory --graph                 # Tree structure view
ansible-inventory --host hostname          # Single host details
ansible-inventory --host hostname --yaml  # Host details in YAML

# Inventory file validation
ansible-inventory --list -i inventory.ini
ansible-inventory --list -i inventory.yml
ansible-inventory --list -i inventory/    # Directory of inventory files
ansible-inventory --parse -i inventory.ini # Parse and validate syntax

# Multiple inventory sources
ansible-inventory --list -i inv1.ini -i inv2.yml -i inv3/
ansible-inventory --graph -i production/ -i staging.yml

# Inventory export formats
ansible-inventory --list --output inventory_export.json
ansible-inventory --list --yaml --output inventory_export.yml

# Host and group listing
ansible all --list-hosts                  # All hosts
ansible webservers --list-hosts           # Hosts in group
ansible 'web*' --list-hosts              # Pattern matching
ansible '!excluded_group' --list-hosts    # Exclusion pattern
ansible 'group1:&group2' --list-hosts     # Intersection
ansible 'group1:!group2' --list-hosts     # Difference

# Custom inventory location
export ANSIBLE_INVENTORY=./my_inventory.ini
export ANSIBLE_INVENTORY=./inventories/production/
ansible-config dump | grep INVENTORY

# Dynamic inventory testing
ansible-inventory --list -i inventory_script.py
ansible-inventory --host hostname -i inventory_script.py

# Inventory variables
ansible-inventory --host hostname --vars   # Show all variables
ansible all -m debug -a "var=group_names"  # Show group membership
ansible all -m debug -a "var=groups"       # Show all groups
ansible all -m debug -a "var=hostvars"     # Show all host variables

# Inventory debugging
ansible-inventory --graph --vars          # Show variables in graph
ansible-inventory --list | jq '.webservers' # Parse JSON output
ansible-inventory --list | grep -A5 -B5 hostname
```

---

## 2. Configure Ansible Managed Nodes

### SSH Key Generation and Distribution
```bash
# Generate SSH key pairs (various methods)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""      # RSA 4096-bit
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""       # Ed25519 (modern)
ssh-keygen -t ecdsa -b 521 -f ~/.ssh/id_ecdsa -N ""    # ECDSA

# Generate with comment
ssh-keygen -t rsa -b 4096 -C "ansible@$(hostname)" -f ~/.ssh/id_rsa -N ""

# Copy public key to managed nodes
ssh-copy-id ansible@node1.example.com
ssh-copy-id ansible@node2.example.com
ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@node1.example.com

# Copy to multiple hosts from inventory
for host in $(ansible all --list-hosts | grep -v hosts); do
  ssh-copy-id ansible@$host
done

# Manual key distribution methods
cat ~/.ssh/id_rsa.pub | ssh user@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
scp ~/.ssh/id_rsa.pub user@remote_host:~/.ssh/authorized_keys

# Set proper permissions
ssh user@remote_host "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"

# Batch key distribution
ansible all -m authorized_key -a "user=ansible key='{{ lookup('file', '~/.ssh/id_rsa.pub') }}' state=present" --ask-pass --become

# Test SSH connectivity
ssh -o StrictHostKeyChecking=no ansible@node1.example.com
ssh -o ConnectTimeout=10 ansible@node1.example.com 'echo "Connection successful"'
ssh -o BatchMode=yes ansible@node1.example.com 'uptime'  # Non-interactive test

# SSH agent setup
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
ssh-add -l                                # List loaded keys

# SSH configuration file
vim ~/.ssh/config
cat > ~/.ssh/config << 'EOF'
Host node*
    User ansible
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IdentityFile ~/.ssh/id_rsa
    ConnectTimeout 10
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
chmod 600 ~/.ssh/config
```

### Privilege Escalation Configuration
```bash
# Configure sudo on managed nodes
sudo visudo
# Or use dedicated sudoers file
sudo visudo -f /etc/sudoers.d/ansible

# Add to sudoers file (various patterns):
ansible ALL=(ALL) NOPASSWD: ALL          # Full access without password
ansible ALL=(ALL:ALL) NOPASSWD: ALL     # Full access to all users/groups
ansible ALL=(root) NOPASSWD: /bin/systemctl, /usr/bin/dnf  # Specific commands
%ansible ALL=(ALL) NOPASSWD: ALL        # Group-based access

# Validate sudoers syntax
sudo visudo -c
sudo visudo -c -f /etc/sudoers.d/ansible

# Test privilege escalation
ansible all -m command -a "whoami" --become
ansible all -m command -a "whoami" --become --become-user=root
ansible all -m command -a "whoami" --become --become-user=apache
ansible all -m setup --become | grep ansible_user_id

# Different become methods
ansible all -m command -a "whoami" --become --become-method=sudo
ansible all -m command -a "whoami" --become --become-method=su
ansible all -m command -a "whoami" --become --become-method=pbrun
ansible all -m command -a "whoami" --become --become-method=pfexec

# Become user variations
ansible all -m command -a "id" --become --become-user=apache
ansible all -m shell -a "ps aux | grep apache" --become
ansible all -m file -a "path=/tmp/test state=touch owner=apache" --become

# Test specific sudo commands
sudo -l                                   # List allowed commands
sudo -v                                   # Validate sudo timestamp
sudo -k                                   # Reset sudo timestamp

# Group management for ansible user
sudo usermod -aG wheel ansible           # Add to wheel group (if used)
sudo groups ansible                      # Check group membership
```

### Connectivity Testing and Validation
```bash
# Basic connectivity tests
ansible all -m ping                      # Basic ping test
ansible all -m ping -f 10               # Parallel connections
ansible all -m ping --timeout=30        # Custom timeout
ansible all -m ping -o                  # One-line output

# Connection with specific inventory
ansible all -i inventory.ini -m ping
ansible all -i production/ -m ping

# Test specific groups and hosts
ansible webservers -m ping
ansible node1.example.com -m ping
ansible 'web*' -m ping                   # Pattern matching
ansible '!database' -m ping             # Exclude group

# Test privilege escalation
ansible all -m command -a "whoami" --become
ansible all -m command -a "whoami" --become --become-user=apache
ansible all -m shell -a "sudo -l" --become
ansible all -m command -a "id" --become

# Connection debugging
ansible all -m ping -vvv                # Verbose output
ansible all -m ping --check             # Check mode
ansible all -m ping -f 1                # Serial execution

# Gather system information
ansible all -m setup                     # All facts
ansible all -m setup --tree /tmp/facts  # Save facts to files
ansible hostname -m setup -a "filter=ansible_distribution*"
ansible hostname -m setup -a "filter=ansible_memory_mb"
ansible hostname -m setup -a "filter=ansible_processor*"
ansible hostname -m setup -a "filter=ansible_default_ipv4"
ansible all -m setup -a "gather_subset=network"
ansible all -m setup -a "gather_subset=hardware"
ansible all -m setup -a "gather_subset=!facter,!ohai"

# Network connectivity tests
ansible all -m wait_for -a "host=8.8.8.8 port=53 timeout=10"
ansible all -m uri -a "url=http://example.com return_content=no"
ansible all -m get_url -a "url=http://example.com/test.txt dest=/tmp/test.txt" --check

# File system tests
ansible all -m stat -a "path=/etc/passwd"
ansible all -m command -a "df -h"
ansible all -m command -a "free -m"
ansible all -m command -a "uptime"

# Service status checks
ansible all -m service_facts
ansible all -m systemd -a "name=sshd" | grep -i active
ansible all -m command -a "systemctl is-active sshd"

# User and group validation
ansible all -m command -a "getent passwd ansible"
ansible all -m command -a "groups ansible"
ansible all -m user -a "name=ansible" --check

# Performance testing
time ansible all -m ping
ansible all -m setup -a "gather_timeout=30"
ansible all -m command -a "uptime" --forks=20
```

---

## 3. Automation Content Navigator

### Basic Navigation Commands
```bash
# Run playbooks (various modes)
ansible-navigator run site.yml                    # Interactive TUI mode
ansible-navigator run site.yml --mode stdout     # Non-interactive mode
ansible-navigator run site.yml --mode interactive # Explicit TUI mode

# Syntax and validation
ansible-navigator run site.yml --syntax-check    # Syntax validation only
ansible-navigator run site.yml --check           # Dry run mode
ansible-navigator run site.yml --check --diff    # Show changes without applying

# Execution variations
ansible-navigator run site.yml --mode stdout -v  # Verbose output
ansible-navigator run site.yml --mode stdout -vv # More verbose
ansible-navigator run site.yml --mode stdout -vvv # Maximum verbosity

# Inventory and limiting
ansible-navigator run site.yml -i inventory.ini
ansible-navigator run site.yml --limit webservers
ansible-navigator run site.yml --limit 'web*:!web3'
ansible-navigator run site.yml --limit @failed_hosts.txt

# Variable passing
ansible-navigator run site.yml -e "var=value"
ansible-navigator run site.yml -e "@vars.yml"
ansible-navigator run site.yml -e "@vars.json"

# Task control
ansible-navigator run site.yml --start-at-task "Install packages"
ansible-navigator run site.yml --step            # Step through tasks
ansible-navigator run site.yml --tags "web,db"   # Run specific tags
ansible-navigator run site.yml --skip-tags "debug" # Skip specific tags

# Interactive TUI commands
# Inside TUI navigation:
# :help          - Show help
# :doc           - Module documentation  
# :collections   - Browse collections
# :inventory     - View inventory
# :images        - List execution environments
# :config        - Show configuration
# :q or :quit    - Exit
# ESC            - Go back/cancel
# Tab            - Auto-complete
# Enter          - Select/execute
# / or ?         - Search
```

### Collection and Documentation Access
```bash
# Browse collections interactively
ansible-navigator collections                     # Interactive collection browser
ansible-navigator collections --mode stdout      # List collections in stdout
ansible-navigator collections --details          # Show collection details

# Module documentation (various approaches)
ansible-navigator doc module_name                # Interactive module docs
ansible-navigator doc module_name --mode stdout # Module docs in stdout
ansible-navigator doc -l                        # List all modules interactively
ansible-navigator doc -l --mode stdout          # List modules in stdout
ansible-navigator doc -l | grep keyword         # Search modules

# FQCN documentation
ansible-navigator doc ansible.builtin.dnf
ansible-navigator doc community.general.firewalld
ansible-navigator doc ansible.posix.mount
ansible-navigator doc containers.podman.podman_container

# Plugin documentation
ansible-navigator doc -t lookup                  # Lookup plugins
ansible-navigator doc -t filter                  # Filter plugins
ansible-navigator doc -t test                    # Test plugins
ansible-navigator doc -t callback                # Callback plugins

# Documentation search and filtering
ansible-navigator doc -l --mode stdout | grep -i package
ansible-navigator doc -l --mode stdout | grep -i user
ansible-navigator doc -l --mode stdout | grep -i service
ansible-navigator doc -l --mode stdout | wc -l  # Count available modules

# Inventory exploration
ansible-navigator inventory --list               # Interactive inventory view
ansible-navigator inventory --list --mode stdout # Inventory in stdout
ansible-navigator inventory --host hostname      # Single host details
ansible-navigator inventory --graph              # Tree structure view
ansible-navigator inventory -i inventory.ini --list
ansible-navigator inventory -i production/ --graph

# Configuration viewing
ansible-navigator config                         # Interactive config browser
ansible-navigator config --mode stdout          # Config in stdout
ansible-navigator config dump                   # All config values
```

### Execution Environment Management
```bash
# List and manage execution environments
ansible-navigator images                         # Interactive image browser
ansible-navigator images --mode stdout          # List images in stdout
ansible-navigator images --details              # Show image details

# Common execution environments
ansible-navigator run site.yml --execution-environment-image registry.redhat.io/ubi8/ubi:latest
ansible-navigator run site.yml --execution-environment-image quay.io/ansible/ansible-runner:latest
ansible-navigator run site.yml --execution-environment-image quay.io/ansible/creator-ee:latest

# Pull and manage container images
podman pull registry.redhat.io/ubi8/ubi:latest
podman pull quay.io/ansible/ansible-runner:latest
podman images | grep ansible
podman inspect registry.redhat.io/ubi8/ubi:latest

# Custom execution environment usage
ansible-navigator run site.yml --execution-environment-image my-custom-ee:latest
ansible-navigator run site.yml --pull-policy always
ansible-navigator run site.yml --pull-policy missing
ansible-navigator run site.yml --pull-policy never

# Volume mounting with execution environments
ansible-navigator run site.yml --execution-environment-volume-mounts /host/path:/container/path
ansible-navigator run site.yml --execution-environment-volume-mounts /etc/ansible:/etc/ansible:ro

# Environment variable passing
ansible-navigator run site.yml --set-environment-variable ANSIBLE_HOST_KEY_CHECKING=False
ansible-navigator run site.yml --set-environment-variable ANSIBLE_TIMEOUT=30

# Container registry authentication
podman login registry.redhat.io
podman login quay.io
echo $'username\npassword' | podman login --stdin registry.example.com

# Build custom execution environment (if needed)
buildah from registry.redhat.io/ubi8/ubi:latest
buildah run $container -- dnf install -y ansible-core
buildah commit $container my-ansible-ee:latest

# Execution environment debugging
ansible-navigator run site.yml --execution-environment-image debug-ee --mode stdout -vvv
podman run -it --rm registry.redhat.io/ubi8/ubi:latest /bin/bash
```

---

## 4. Content Collections Management

### Galaxy Collection Management
```bash
# Collection discovery and search
ansible-galaxy collection list                   # List installed collections
ansible-galaxy collection list --format json    # JSON format output
ansible-galaxy collection search firewall       # Search for collections
ansible-galaxy collection search --author redhat # Search by author

# Install collections (various methods)
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install containers.podman
ansible-galaxy collection install redhat.rhel_system_roles
ansible-galaxy collection install community.crypto
ansible-galaxy collection install ansible.windows

# Version-specific installations
ansible-galaxy collection install community.general:>=3.0.0
ansible-galaxy collection install community.general:==4.2.0
ansible-galaxy collection install community.general:4.2.0  # Exact version

# Install from requirements file
ansible-galaxy collection install -r requirements.yml
ansible-galaxy collection install -r requirements.yml --force
ansible-galaxy collection install -r requirements.yml -p ./collections

# Custom installation paths
ansible-galaxy collection install community.general -p ./collections
ansible-galaxy collection install community.general -p ~/.ansible/collections
export ANSIBLE_COLLECTIONS_PATHS=./collections:~/.ansible/collections

# Collection information and verification
ansible-galaxy collection list community.general
ansible-galaxy collection list | grep community
ansible-galaxy collection verify community.general
ansible-galaxy collection verify --ignore-certs community.general

# Collection building and publishing (advanced)
ansible-galaxy collection init my_namespace.my_collection
ansible-galaxy collection build                  # Build tarball
ansible-galaxy collection publish my_collection-1.0.0.tar.gz

# Upgrade and maintenance
ansible-galaxy collection install community.general --upgrade
ansible-galaxy collection install community.general --force
ansible-galaxy collection install --requirements requirements.yml --upgrade

# Alternative sources
ansible-galaxy collection install community.general --source https://private-galaxy.example.com
ansible-galaxy collection install ./my-collection-1.0.0.tar.gz
ansible-galaxy collection install git+https://github.com/user/collection.git
```

### Requirements File Formats and Examples
```yaml
# requirements.yml - Basic format
collections:
  - name: community.general
    version: ">=3.0.0"
  - name: ansible.posix
    version: "1.4.0"
  - name: containers.podman
    source: https://galaxy.ansible.com
  - name: redhat.rhel_system_roles
  - name: community.crypto
    version: ">=2.0.0"

# Advanced requirements.yml
collections:
  # Version constraints
  - name: community.general
    version: ">=4.0.0,<5.0.0"
  - name: ansible.posix
    version: "==1.4.0"              # Exact version
  - name: community.crypto
    version: "~=2.1.0"             # Compatible release
    
  # Alternative sources
  - name: my_namespace.my_collection
    source: https://private-galaxy.example.com
  - name: community.vmware
    source: git+https://github.com/ansible-collections/community.vmware.git
  - name: local_collection
    source: ./local-collections/
    
  # Git sources with specific references
  - name: community.kubernetes
    source: git+https://github.com/ansible-collections/community.kubernetes.git,main
  - name: community.docker
    source: git+https://github.com/ansible-collections/community.docker.git,v2.7.0

# Combined roles and collections
roles:
  - name: geerlingguy.apache
    version: "3.2.0"
  - src: https://github.com/geerlingguy/ansible-role-nginx
    name: nginx
    
collections:
  - name: community.general
  - name: ansible.posix
  - name: containers.podman

# Environment-specific requirements
# requirements-dev.yml
collections:
  - name: community.general
    version: ">=4.0.0"
  - name: community.molecule
  - name: community.crypto
    
# requirements-prod.yml
collections:
  - name: community.general
    version: "==4.2.0"              # Pinned for production
  - name: ansible.posix
    version: "==1.4.0"
```

### Collection Usage and Module Discovery
```bash
# FQCN documentation lookup
ansible-navigator doc ansible.builtin.dnf
ansible-navigator doc community.general.firewalld
ansible-navigator doc ansible.posix.mount
ansible-navigator doc containers.podman.podman_container
ansible-navigator doc redhat.rhel_system_roles.selinux

# Module discovery within collections
ansible-navigator collections                     # Interactive browser
ansible-navigator doc -l | grep community.general
ansible-navigator doc -l | grep ansible.posix
ansible-navigator doc -l | grep containers.podman

# Collection path verification
ansible-config dump | grep COLLECTIONS_PATHS
ansible-galaxy collection list --format json | jq '.[].path'
find ~/.ansible/collections -name "*.py" -path "*/plugins/modules/*" | head -10

# Module testing with FQCN
ansible localhost -m ansible.builtin.debug -a "msg='Hello World'"
ansible all -m community.general.parted -a "device=/dev/sdb number=1 state=info" --check
ansible all -m ansible.posix.mount -a "path=/mnt src=/dev/sdb1 fstype=xfs state=mounted" --check

# Collection namespace verification
ansible-doc -l | cut -d. -f1-2 | sort | uniq  # List all namespaces
ansible-doc -l | grep -E '^(community|ansible|redhat)\.' | wc -l

# Plugin discovery
ansible-doc -t lookup -l | grep community
ansible-doc -t filter -l | grep ansible.builtin
ansible-doc -t callback -l
ansible-doc -t connection -l

# Collection metadata
ansible-galaxy collection list community.general --format json | jq '.[].version'
ls -la ~/.ansible/collections/ansible_collections/community/general/
cat ~/.ansible/collections/ansible_collections/community/general/MANIFEST.json

# Collection dependencies
ansible-galaxy collection list --format json | jq '.[].dependencies'
ansible-galaxy collection verify community.general --verbose

# Troubleshooting collection issues
ansible-config dump | grep -i collections
echo $ANSIBLE_COLLECTIONS_PATHS
ansible localhost -m ansible.builtin.setup -a "filter=ansible_collections"
python3 -c "import ansible_collections.community.general; print(ansible_collections.community.general.__file__)"
```

---

## 5. Role Management

### Role Creation and Structure Management
```bash
# Create role structure (various methods)
ansible-galaxy init role_name                    # Default role structure
ansible-galaxy init web_server                   # Example role name
ansible-galaxy init --role-skeleton=custom_skeleton role_name
ansible-galaxy init --init-path=./roles web_server
ansible-galaxy init roles/database               # Create in specific directory

# Role directory structure exploration
tree roles/role_name/
ls -la roles/role_name/
find roles/role_name/ -type f -name "*.yml" | sort

# Complete role structure:
# roles/role_name/
# ├── README.md              # Role documentation
# ├── defaults/main.yml      # Default variables (lowest priority)
# ├── files/                 # Static files to copy
# ├── handlers/main.yml      # Event handlers
# ├── meta/main.yml          # Role metadata and dependencies
# ├── tasks/main.yml         # Main task list
# ├── templates/             # Jinja2 templates
# ├── tests/                 # Test playbooks
# ├── vars/main.yml          # Role variables (higher priority)
# └── molecule/              # Testing framework (if used)

# Validate role structure
ansible-galaxy role init --offline web_server    # Offline mode
ansible-lint roles/web_server/                   # Lint role files
yamllint roles/web_server/tasks/main.yml        # YAML syntax check

# Role metadata examination
cat roles/web_server/meta/main.yml
ansible-galaxy role info geerlingguy.apache     # External role info

# Custom role skeleton creation
mkdir -p ~/.ansible/galaxy_role_skeleton/{tasks,handlers,templates,files,vars,defaults,meta}
echo '---' > ~/.ansible/galaxy_role_skeleton/tasks/main.yml
echo 'galaxy_info:' > ~/.ansible/galaxy_role_skeleton/meta/main.yml
ansible-galaxy init --role-skeleton ~/.ansible/galaxy_role_skeleton my_custom_role
```

### Role Installation and Management
```bash
# Install roles from Ansible Galaxy
ansible-galaxy role install geerlingguy.apache
ansible-galaxy role install geerlingguy.nginx
ansible-galaxy role install davidwittman.redis
ansible-galaxy role install bertvv.dhcp

# Version-specific installations
ansible-galaxy role install geerlingguy.apache,3.2.0
ansible-galaxy role install geerlingguy.nginx:2.8.0
ansible-galaxy role install "geerlingguy.apache>=3.0.0"

# Install from requirements file
ansible-galaxy role install -r requirements.yml
ansible-galaxy role install -r requirements.yml --force
ansible-galaxy role install -r requirements.yml --roles-path ./roles

# Custom installation paths
ansible-galaxy role install geerlingguy.apache -p ./roles
ansible-galaxy role install geerlingguy.apache -p ~/.ansible/roles
export ANSIBLE_ROLES_PATH=./roles:~/.ansible/roles:/etc/ansible/roles

# Role information and verification
ansible-galaxy role list                        # List installed roles
ansible-galaxy role list --format json         # JSON format
ansible-galaxy role info geerlingguy.apache    # Role details
ansible-galaxy role search apache              # Search for roles
ansible-galaxy role search --author geerlingguy

# Role maintenance
ansible-galaxy role remove geerlingguy.apache
ansible-galaxy role remove role_name --roles-path ./roles
ansible-galaxy role install geerlingguy.apache --force  # Force reinstall

# Install from alternative sources
ansible-galaxy role install git+https://github.com/geerlingguy/ansible-role-apache.git
ansible-galaxy role install https://github.com/geerlingguy/ansible-role-nginx/archive/master.tar.gz
ansible-galaxy role install /path/to/local/role.tar.gz

# Role dependencies management
ansible-galaxy role install -r requirements.yml --ignore-errors
ansible-galaxy role list | grep -E '(version|name)'
ansible-galaxy role list --roles-path ./roles

# Role path verification
ansible-config dump | grep ROLES_PATH
echo $ANSIBLE_ROLES_PATH
find ./roles -name "tasks" -type d 2>/dev/null
find ~/.ansible/roles -maxdepth 1 -type d 2>/dev/null
```

### Role Testing and Execution
```bash
# Role syntax validation
ansible-navigator run --syntax-check site.yml
ansible-playbook --syntax-check site.yml         # Fallback method
ansible-lint roles/web_server/                   # Lint specific role
ansible-lint site.yml                            # Lint entire playbook

# Role execution with various options
ansible-navigator run site.yml --limit webservers
ansible-navigator run site.yml --check           # Dry run with roles
ansible-navigator run site.yml --check --diff    # Show role changes

# Variable passing to roles
ansible-navigator run site.yml -e "apache_port=8080"
ansible-navigator run site.yml -e "nginx_user=www-data"
ansible-navigator run site.yml -e "@role_vars.yml"

# Tag-based role execution
ansible-navigator run site.yml --tags "web,database"
ansible-navigator run site.yml --skip-tags "debug,test"
ansible-navigator run site.yml --tags "never"    # Run 'never' tagged tasks

# Role-specific testing
ansible-navigator run test-role.yml --limit localhost
ansible localhost -m include_role -a "name=web_server"
ansible-playbook roles/web_server/tests/test.yml

# Role debugging
ansible-navigator run site.yml --mode stdout -vv
ansible all -m debug -a "var=role_path"
ansible all -m debug -a "var=ansible_role_names"

# Role performance testing
time ansible-navigator run site.yml --limit test_host
ansible-navigator run site.yml --forks 10        # Parallel execution

# Role task analysis
ansible-navigator run site.yml --list-tasks     # List all tasks
ansible-navigator run site.yml --list-tags      # List all tags
ansible-navigator run site.yml --start-at-task "Install Apache"

# Role variable debugging
ansible all -m debug -a "var=hostvars[inventory_hostname]"
ansible webservers -m debug -a "var=apache_port | default('80')"
ansible all -m debug -a "var=group_names"
ansible all -m debug -a "var=groups"

# Multiple role execution
ansible-navigator run site.yml --limit "webservers:dbservers"
ansible-navigator run site.yml --limit "all:!excluded_group"

# Role import vs include testing
ansible-navigator run import-role-test.yml       # Static import
ansible-navigator run include-role-test.yml      # Dynamic include
```

---

## 6. Playbook Development and Execution

### Playbook Syntax and Validation
```bash
# Syntax validation (various methods)
ansible-navigator run site.yml --syntax-check   # Navigator method
ansible-playbook site.yml --syntax-check       # Traditional method
ansible-navigator run site.yml --syntax-check --mode stdout

# YAML syntax validation
yamllint site.yml                               # YAML linting
yamllint -d '{extends: default, rules: {line-length: {max: 120}}}' site.yml
yamllint *.yml                                  # All YAML files

# Check mode (dry run) variations
ansible-navigator run site.yml --check          # Basic check mode
ansible-navigator run site.yml --check --diff   # Show differences
ansible-navigator run site.yml --check --diff --mode stdout
ansible-playbook site.yml --check --diff       # Fallback method

# Advanced linting
ansible-lint site.yml                           # Basic linting
ansible-lint site.yml -v                        # Verbose output
ansible-lint roles/                              # Lint all roles
ansible-lint --exclude .github/ site.yml       # Exclude directories
ansible-lint --skip-list yaml site.yml         # Skip specific rules
ansible-lint --write site.yml                   # Auto-fix issues

# Multiple file validation
ansible-lint *.yml
ansible-lint playbooks/ roles/ group_vars/
find . -name "*.yml" -exec ansible-lint {} \;
find . -name "*.yml" | xargs yamllint

# Custom lint configurations
echo 'skip_list:' > .ansible-lint
echo '  - yaml[line-length]' >> .ansible-lint
echo '  - risky-file-permissions' >> .ansible-lint
ansible-lint -c .ansible-lint site.yml

# Validation with specific inventory
ansible-navigator run site.yml --syntax-check -i inventory.ini
ansible-navigator run site.yml --check -i production/
ansible-navigator run site.yml --check --limit webservers

# Task-specific validation
ansible localhost -m debug -a "msg='{{ variable_name | default('undefined') }}'"
ansible localhost -m template -a "src=template.j2 dest=/tmp/test" --check
```

### Playbook Execution Options and Control
```bash
# Verbosity levels
ansible-navigator run site.yml --mode stdout -v    # Basic verbosity
ansible-navigator run site.yml --mode stdout -vv   # More verbose
ansible-navigator run site.yml --mode stdout -vvv  # Maximum verbosity
ansible-navigator run site.yml --mode stdout -vvvv # Connection debugging

# Host and group limiting
ansible-navigator run site.yml --limit webservers
ansible-navigator run site.yml --limit "node1,node2"
ansible-navigator run site.yml --limit "webservers:!node3"
ansible-navigator run site.yml --limit "web*"      # Pattern matching
ansible-navigator run site.yml --limit "@failed_hosts.txt"
ansible-navigator run site.yml --limit "all:!excluded_group"
ansible-navigator run site.yml --limit "webservers:&production"

# Task execution control
ansible-navigator run site.yml --start-at-task "Install packages"
ansible-navigator run site.yml --step              # Interactive step-through
ansible-navigator run site.yml --tags "web,db"     # Run specific tags
ansible-navigator run site.yml --skip-tags "debug" # Skip specific tags
ansible-navigator run site.yml --tags "never"      # Force 'never' tags
ansible-navigator run site.yml --list-tasks        # List all tasks
ansible-navigator run site.yml --list-tags         # List all tags

# Inventory and connection options
ansible-navigator run site.yml -i inventory.ini
ansible-navigator run site.yml -i inventory.yml
ansible-navigator run site.yml -i production/      # Directory inventory
ansible-navigator run site.yml -i host1,host2,     # Inline inventory

# Parallel execution control
ansible-navigator run site.yml --forks 10          # 10 parallel processes
ansible-navigator run site.yml --forks 1           # Serial execution
ansible-navigator run site.yml --serial 2          # Batch size control

# Connection and timeout options
ansible-navigator run site.yml --timeout 60        # Command timeout
ansible-navigator run site.yml --connection local  # Local connection
ansible-navigator run site.yml --connection ssh    # SSH connection
ansible-navigator run site.yml --private-key ~/.ssh/id_rsa

# Privilege escalation
ansible-navigator run site.yml --become            # Enable privilege escalation
ansible-navigator run site.yml --become-user apache # Specific become user
ansible-navigator run site.yml --become-method sudo # Specific method
ansible-navigator run site.yml --ask-become-pass   # Prompt for password

# Output and logging control
ansible-navigator run site.yml --mode stdout       # Standard output
ansible-navigator run site.yml --mode interactive  # TUI mode
ansible-navigator run site.yml --one-line          # Condensed output
ansible-navigator run site.yml --tree /tmp/results # Save results to directory

# Error handling and recovery
ansible-navigator run site.yml --force-handlers    # Run handlers on failure
ansible-navigator run site.yml --flush-cache       # Clear fact cache
ansible-navigator run site.yml --diff              # Show file changes

# Strategy control
ansible-navigator run site.yml --strategy linear   # Default strategy
ansible-navigator run site.yml --strategy free     # Don't wait for all hosts
ansible-navigator run site.yml --strategy debug    # Debug strategy
```

### Variable Management and Debugging
```bash
# Command line variable passing (various formats)
ansible-navigator run site.yml -e "var=value"
ansible-navigator run site.yml -e "apache_port=8080"
ansible-navigator run site.yml -e "env=production debug=false"
ansible-navigator run site.yml -e '{"apache_port": 8080, "ssl_enabled": true}'
ansible-navigator run site.yml -e "@vars.yml"      # From YAML file
ansible-navigator run site.yml -e "@vars.json"     # From JSON file
ansible-navigator run site.yml -e "@/path/to/external_vars.yml"

# Multiple variable sources
ansible-navigator run site.yml -e "@group_vars/production.yml" -e "debug=true"
ansible-navigator run site.yml -e "@secrets.yml" --vault-password-file .vault_pass

# Variable precedence testing and debugging
ansible all -m debug -a "var=my_variable"          # Single variable
ansible all -m debug -a "var=hostvars[inventory_hostname]" # All host vars
ansible all -m debug -a "var=group_names"           # Group membership
ansible all -m debug -a "var=groups"                # All groups
ansible all -m debug -a "var=ansible_facts"         # All facts
ansible all -m debug -a "var=vars"                  # All variables

# Specific variable debugging
ansible all -m debug -a "var=ansible_default_ipv4.address"
ansible all -m debug -a "var=ansible_distribution"
ansible all -m debug -a "var=ansible_hostname"
ansible all -m debug -a "var=ansible_user"

# Variable file validation
ansible all -m debug -a "var=lookup('file', '/path/to/file.txt')"
ansible all -m debug -a "var=lookup('env', 'HOME')"
ansible all -m debug -a "var=lookup('pipe', 'date')"

# Magic variables debugging
ansible all -m debug -a "var=inventory_hostname"
ansible all -m debug -a "var=inventory_hostname_short"
ansible all -m debug -a "var=play_hosts"
ansible all -m debug -a "var=ansible_play_batch"
ansible all -m debug -a "var=ansible_play_hosts_all"

# Variable precedence order testing
echo 'test_var: from_command_line' > test_vars.yml
ansible-navigator run site.yml -e "@test_vars.yml" -e "test_var=override"
ansible all -m debug -a "var=test_var"

# Variable filtering and selection
ansible all -m debug -a "var=ansible_facts" | grep -A 5 -B 5 "distribution"
ansible all -m debug -a "var=ansible_facts.keys() | list"
ansible all -m debug -a "var=hostvars.keys() | list"

# Environment variable testing
export ANSIBLE_VAR_custom_var="environment_value"
ansible all -m debug -a "var=custom_var"
ansible-navigator run site.yml -e "env_var={{ lookup('env', 'PATH') }}"

# Variable validation in playbooks
ansible all -m debug -a "var=variable_name | default('NOT_DEFINED')"
ansible all -m debug -a "var=variable_name is defined"
ansible all -m debug -a "var=variable_name is undefined"
```

---

## 7. RHCSA Task Automation Commands

### Package Management Automation
```bash
# Module documentation and discovery
ansible-navigator doc ansible.builtin.dnf       # Primary package manager
ansible-navigator doc ansible.builtin.package   # Generic package module
ansible-navigator doc ansible.builtin.yum       # Legacy YUM module
ansible-navigator doc ansible.builtin.rpm_key   # GPG key management
ansible-doc -s dnf                              # Synopsis only

# Basic package operations
ansible all -m dnf -a "name=httpd state=present" --become
ansible all -m dnf -a "name=httpd state=latest" --become
ansible all -m dnf -a "name=httpd state=absent" --become
ansible all -m dnf -a "name=httpd state=installed" --become  # Alias for present
ansible all -m dnf -a "name=httpd state=removed" --become    # Alias for absent

# Multiple package operations
ansible all -m dnf -a "name=['httpd','nginx','mariadb-server'] state=present" --become
ansible all -m dnf -a "name=httpd,nginx,mysql-server state=present" --become
ansible all -m dnf -a "name='@Development Tools' state=present" --become  # Group install
ansible all -m dnf -a "name='@^Minimal Install' state=present" --become  # Environment group

# Version-specific installations
ansible all -m dnf -a "name=httpd-2.4.* state=present" --become
ansible all -m dnf -a "name=kernel state=present" --become
ansible all -m dnf -a "name=kernel state=latest" --become

# Repository management
ansible all -m dnf -a "name=epel-release state=present" --become
ansible all -m dnf -a "name=httpd state=present enablerepo=epel" --become
ansible all -m dnf -a "name=httpd state=present disablerepo=epel" --become

# Package queries and information
ansible all -m package_facts
ansible all -m debug -a "var=ansible_facts.packages.httpd" --become
ansible all -m command -a "rpm -qa httpd"
ansible all -m command -a "dnf list installed httpd" --become
ansible all -m command -a "dnf info httpd" --become

# Cache and cleanup operations
ansible all -m dnf -a "update_cache=yes" --become
ansible all -m dnf -a "autoremove=yes" --become
ansible all -m command -a "dnf clean all" --become
ansible all -m command -a "dnf makecache" --become

# Security updates
ansible all -m dnf -a "name='*' state=latest security=yes" --become
ansible all -m command -a "dnf check-update --security" --become
ansible all -m command -a "dnf update --security -y" --become

# GPG key management
ansible all -m rpm_key -a "state=present key=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9" --become
ansible all -m command -a "rpm --import /path/to/key.asc" --become

# Package file operations
ansible all -m dnf -a "name=/path/to/package.rpm state=present" --become
ansible all -m command -a "rpm -ivh /path/to/package.rpm" --become
ansible all -m get_url -a "url=http://example.com/package.rpm dest=/tmp/package.rpm" --become

# Downgrade and specific version management
ansible all -m command -a "dnf downgrade httpd -y" --become
ansible all -m command -a "dnf list --showduplicates httpd" --become

# Testing package operations
ansible all -m dnf -a "name=httpd state=present" --become --check
ansible all -m package_facts --become
ansible all -m command -a "which httpd"
```

### Service Management Automation
```bash
# Module documentation and discovery
ansible-navigator doc ansible.builtin.systemd   # Systemd service management
ansible-navigator doc ansible.builtin.service   # Generic service module
ansible-navigator doc ansible.builtin.systemd_service  # Alias for systemd
ansible-doc -s systemd                          # Synopsis only

# Basic service operations
ansible all -m systemd -a "name=httpd state=started" --become
ansible all -m systemd -a "name=httpd state=stopped" --become
ansible all -m systemd -a "name=httpd state=restarted" --become
ansible all -m systemd -a "name=httpd state=reloaded" --become

# Service enablement and startup
ansible all -m systemd -a "name=httpd enabled=yes" --become
ansible all -m systemd -a "name=httpd enabled=no" --become
ansible all -m systemd -a "name=httpd state=started enabled=yes" --become
ansible all -m systemd -a "name=httpd state=stopped enabled=no" --become

# Systemd daemon operations
ansible all -m systemd -a "daemon_reload=yes" --become
ansible all -m systemd -a "daemon_reexec=yes" --become
ansible all -m command -a "systemctl daemon-reload" --become

# Service status and information
ansible all -m service_facts --become
ansible all -m debug -a "var=ansible_facts.services['httpd.service']" --become
ansible all -m command -a "systemctl status httpd" --become
ansible all -m command -a "systemctl is-active httpd"
ansible all -m command -a "systemctl is-enabled httpd"
ansible all -m command -a "systemctl is-failed httpd"

# Multiple service operations
ansible all -m systemd -a "name=httpd,nginx state=started enabled=yes" --become
for service in httpd nginx mariadb; do
  ansible all -m systemd -a "name=$service state=started enabled=yes" --become
done

# Service masking and unmasking
ansible all -m systemd -a "name=httpd masked=yes" --become
ansible all -m systemd -a "name=httpd masked=no" --become
ansible all -m command -a "systemctl mask httpd" --become
ansible all -m command -a "systemctl unmask httpd" --become

# Target and runlevel management
ansible all -m systemd -a "name=multi-user.target state=started" --become
ansible all -m command -a "systemctl get-default" --become
ansible all -m command -a "systemctl set-default multi-user.target" --become
ansible all -m systemd -a "name=graphical.target state=started" --become

# Timer management
ansible all -m systemd -a "name=backup.timer state=started enabled=yes" --become
ansible all -m command -a "systemctl list-timers" --become

# Socket management
ansible all -m systemd -a "name=httpd.socket state=started enabled=yes" --become
ansible all -m command -a "systemctl list-sockets" --become

# Service dependency analysis
ansible all -m command -a "systemctl list-dependencies httpd" --become
ansible all -m command -a "systemctl show httpd" --become

# Emergency service operations
ansible all -m command -a "systemctl kill httpd" --become
ansible all -m command -a "systemctl kill -s KILL httpd" --become
ansible all -m command -a "systemctl reset-failed httpd" --become

# Service testing and validation
ansible all -m systemd -a "name=httpd state=started" --become --check
ansible all -m uri -a "url=http://{{ ansible_default_ipv4.address }} method=GET" 
ansible all -m wait_for -a "port=80 host={{ ansible_default_ipv4.address }} timeout=10"
```

### File Management Automation
```bash
# Module documentation and discovery
ansible-navigator doc ansible.builtin.copy      # Copy files
ansible-navigator doc ansible.builtin.template  # Template files with Jinja2
ansible-navigator doc ansible.builtin.file      # File and directory operations
ansible-navigator doc ansible.builtin.fetch     # Fetch files from remote
ansible-navigator doc ansible.builtin.stat      # File statistics
ansible-navigator doc ansible.builtin.find      # Find files
ansible-navigator doc ansible.builtin.replace   # Replace text in files
ansible-navigator doc ansible.builtin.lineinfile # Manage lines in files

# Basic file copy operations
ansible all -m copy -a "src=file.txt dest=/tmp/file.txt" --become
ansible all -m copy -a "src=config.conf dest=/etc/app/config.conf backup=yes" --become
ansible all -m copy -a "content='Hello World' dest=/tmp/hello.txt" --become
ansible all -m copy -a "src=files/ dest=/tmp/ owner=apache group=apache mode=0644" --become

# Template operations
ansible all -m template -a "src=httpd.conf.j2 dest=/etc/httpd/conf/httpd.conf" --become
ansible all -m template -a "src=template.j2 dest=/tmp/result.txt backup=yes" --become
ansible all -m template -a "src=config.j2 dest=/etc/config owner=root mode=0600" --become

# Directory operations
ansible all -m file -a "path=/tmp/testdir state=directory" --become
ansible all -m file -a "path=/var/log/app state=directory owner=apache group=apache mode=0755" --become
ansible all -m file -a "path=/tmp/testdir state=absent" --become  # Remove directory
ansible all -m file -a "path=/opt/app state=directory recurse=yes owner=app group=app" --become

# File creation and modification
ansible all -m file -a "path=/tmp/testfile state=touch" --become
ansible all -m file -a "path=/tmp/testfile state=touch owner=apache group=apache mode=0644" --become
ansible all -m file -a "path=/tmp/oldfile state=absent" --become  # Remove file

# Symbolic and hard links
ansible all -m file -a "src=/etc/hosts dest=/tmp/hosts_link state=link" --become
ansible all -m file -a "src=/etc/hosts dest=/tmp/hosts_hard state=hard" --become
ansible all -m file -a "path=/tmp/broken_link state=absent" --become

# File permissions and ownership
ansible all -m file -a "path=/tmp/testfile owner=apache group=apache mode=0644" --become
ansible all -m file -a "path=/tmp/testfile mode=u+rw,g+r,o-rwx" --become
ansible all -m file -a "path=/var/www/html recurse=yes owner=apache group=apache" --become

# File content management
ansible all -m lineinfile -a "path=/etc/hosts line='192.168.1.100 myserver' state=present" --become
ansible all -m lineinfile -a "path=/etc/ssh/sshd_config regexp='^#?PasswordAuthentication' line='PasswordAuthentication no'" --become
ansible all -m replace -a "path=/etc/config.conf regexp='old_value' replace='new_value'" --become

# File statistics and information
ansible all -m stat -a "path=/etc/passwd"
ansible all -m stat -a "path=/tmp/testfile get_checksum=yes get_mime=yes"
ansible all -m debug -a "var=stat_result" 

# Find files and directories
ansible all -m find -a "paths=/var/log pattern='*.log' age=7d age_stamp=mtime"
ansible all -m find -a "paths=/tmp pattern='*temp*' file_type=file"
ansible all -m find -a "paths=/etc pattern='*.conf' recurse=yes"

# Fetch files from remote hosts
ansible all -m fetch -a "src=/etc/hostname dest=./fetched_files/"
ansible all -m fetch -a "src=/var/log/messages dest=./logs/ flat=yes"

# File archiving and compression
ansible all -m archive -a "path=/var/log dest=/tmp/logs.tar.gz format=gz" --become
ansible all -m unarchive -a "src=files.tar.gz dest=/tmp/ remote_src=yes" --become
ansible all -m unarchive -a "src=/tmp/archive.tar.gz dest=/opt/ owner=apache group=apache" --become

# File validation and testing
ansible all -m copy -a "src=test.txt dest=/tmp/test.txt" --become --check
ansible all -m file -a "path=/tmp/testdir state=directory" --become --check
ansible all -m command -a "ls -la /tmp/"
ansible all -m command -a "file /tmp/testfile"

# Bulk file operations
ansible all -m shell -a "find /tmp -name '*.tmp' -delete" --become
ansible all -m shell -a "find /var/log -name '*.log' -mtime +30 -exec rm {} \;" --become
ansible all -m command -a "du -sh /var/log" --become
```

### Storage Management
```bash
# Module documentation
ansible-navigator doc community.general.parted
ansible-navigator doc community.general.lvg
ansible-navigator doc community.general.lvol
ansible-navigator doc ansible.posix.mount

# Test storage commands
ansible all -m setup -a "filter=ansible_devices" --become
ansible all -m setup -a "filter=ansible_mounts" --become
```

### User Management
```bash
# Module documentation
ansible-navigator doc ansible.builtin.user
ansible-navigator doc ansible.builtin.group

# Ad-hoc user commands
ansible all -m user -a "name=testuser state=present" --become
ansible all -m group -a "name=testgroup state=present" --become
```

---

## 8. Ansible Vault Operations

### Comprehensive Vault Operations
```bash
# Create encrypted files (various methods)
ansible-vault create secrets.yml              # Interactive creation
ansible-vault create group_vars/webservers/vault.yml
ansible-vault create host_vars/web01/vault.yml
ansible-vault create --vault-id dev@prompt secrets.yml  # With vault ID
ansible-vault create --vault-id prod@.vault_pass_prod production_secrets.yml

# Edit encrypted files
ansible-vault edit secrets.yml                # Basic editing
ansible-vault edit secrets.yml --vault-id dev@prompt
ansible-vault edit secrets.yml --vault-password-file .vault_pass
ansible-vault edit group_vars/all/vault.yml

# View encrypted file contents
ansible-vault view secrets.yml                # Read-only viewing
ansible-vault view secrets.yml --vault-id dev@prompt
ansible-vault view secrets.yml --vault-password-file .vault_pass
ansible-vault view group_vars/production/vault.yml

# Encrypt existing files
ansible-vault encrypt vars.yml                # Encrypt plain file
ansible-vault encrypt host_vars/web01/secrets.yml
ansible-vault encrypt group_vars/*/vault.yml  # Multiple files
ansible-vault encrypt --vault-id prod@prompt production_vars.yml
ansible-vault encrypt --vault-password-file .vault_pass sensitive_data.yml

# Decrypt files
ansible-vault decrypt secrets.yml             # Decrypt to plain text
ansible-vault decrypt --output decrypted.yml secrets.yml
ansible-vault decrypt group_vars/dev/vault.yml
ansible-vault decrypt --vault-id dev@prompt secrets.yml

# String encryption (inline secrets)
ansible-vault encrypt_string 'secret_password' --name 'db_password'
ansible-vault encrypt_string 'my_secret' --name 'api_key' --vault-id dev@prompt
ansible-vault encrypt_string --stdin-name 'ssh_key' < ~/.ssh/id_rsa
echo 'secret_value' | ansible-vault encrypt_string --stdin-name 'var_name'

# Change vault passwords (rekey)
ansible-vault rekey secrets.yml               # Change password
ansible-vault rekey secrets.yml --new-vault-id prod@prompt
ansible-vault rekey --vault-id old@prompt --new-vault-id new@prompt secrets.yml
ansible-vault rekey group_vars/*/vault.yml    # Multiple files

# Vault ID management
ansible-vault create --vault-id dev@prompt dev_secrets.yml
ansible-vault create --vault-id prod@.vault_pass_prod prod_secrets.yml
ansible-vault edit --vault-id dev@prompt dev_secrets.yml
ansible-vault view --vault-id prod@.vault_pass_prod prod_secrets.yml

# Password file methods
echo 'my_vault_password' > .vault_pass
chmod 600 .vault_pass
ansible-vault create --vault-password-file .vault_pass secrets.yml
ansible-vault edit --vault-password-file .vault_pass secrets.yml

# Multiple vault passwords
echo 'dev_password' > .vault_pass_dev
echo 'prod_password' > .vault_pass_prod
chmod 600 .vault_pass_*
ansible-vault create --vault-id dev@.vault_pass_dev dev_secrets.yml
ansible-vault create --vault-id prod@.vault_pass_prod prod_secrets.yml

# Vault validation and troubleshooting
ansible-vault view secrets.yml --check        # Validate encrypted file
file secrets.yml                              # Check if file is encrypted
head -1 secrets.yml | grep -q \$ANSIBLE_VAULT && echo "Encrypted" || echo "Plain text"
```

### Vault Integration with Playbooks
```bash
# Basic vault integration
ansible-navigator run site.yml --ask-vault-pass  # Interactive password prompt
ansible-playbook site.yml --ask-vault-pass       # Fallback method

# Password file integration
echo 'vault_password' > .vault_pass
chmod 600 .vault_pass
ansible-navigator run site.yml --vault-password-file .vault_pass
ansible-navigator run site.yml --vault-password-file ~/.ansible_vault_pass

# Multiple vault IDs with playbooks
ansible-navigator run site.yml --vault-id dev@.vault_pass_dev
ansible-navigator run site.yml --vault-id prod@prompt
ansible-navigator run site.yml --vault-id dev@.vault_pass_dev --vault-id prod@prompt
ansible-navigator run site.yml --vault-id @prompt  # Default vault ID

# Environment variable method
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
ansible-navigator run site.yml
export ANSIBLE_VAULT_IDENTITY_LIST="dev@.vault_pass_dev,prod@.vault_pass_prod"
ansible-navigator run multi_env.yml

# Vault script integration
cat > .vault_pass_script.sh << 'EOF'
#!/bin/bash
echo "$VAULT_PASSWORD"
EOF
chmod +x .vault_pass_script.sh
export VAULT_PASSWORD="my_secret_password"
ansible-navigator run site.yml --vault-password-file .vault_pass_script.sh

# Check mode with vault
ansible-navigator run site.yml --ask-vault-pass --check
ansible-navigator run site.yml --vault-password-file .vault_pass --check --diff

# Debugging vault issues
ansible-navigator run site.yml --ask-vault-pass -vvv
ansible all -m debug -a "var=encrypted_variable" --ask-vault-pass
ansible all -m debug -a "var=vault_encrypted_variable" --vault-password-file .vault_pass

# Testing vault decryption
ansible localhost -m debug -a "var=secret_value" -e "@group_vars/all/vault.yml" --ask-vault-pass
ansible-navigator run test_vault.yml --vault-id dev@prompt --limit localhost

# Mixed encrypted and unencrypted variables
ansible-navigator run site.yml -e "@vars.yml" -e "@vault_vars.yml" --ask-vault-pass
ansible-navigator run site.yml --vault-id dev@.vault_pass_dev -e "environment=development"

# Vault with different execution modes
ansible-navigator run site.yml --ask-vault-pass --mode stdout
ansible-navigator run site.yml --vault-password-file .vault_pass --forks 1
ansible-navigator run site.yml --vault-id prod@prompt --limit production

# Advanced vault scenarios
ansible-navigator run site.yml --vault-id @prompt --extra-vars "@encrypted_extra_vars.yml"
ansible-navigator run deploy.yml --vault-id app@.vault_pass_app --vault-id db@.vault_pass_db

# Ansible configuration for vault
echo '[defaults]' > ansible.cfg
echo 'vault_password_file = .vault_pass' >> ansible.cfg
echo 'vault_identity_list = dev@.vault_pass_dev, prod@.vault_pass_prod' >> ansible.cfg

# Testing vault configuration
ansible-config dump | grep -i vault
ansible localhost -m debug -a "msg='Vault configuration working'" -e "@vault_test.yml"
```

---

## 9. Debugging and Troubleshooting

### Advanced Playbook Debugging
```bash
# Debug mode with various verbosity levels
ansible-navigator run site.yml --mode stdout -v    # Basic verbosity
ansible-navigator run site.yml --mode stdout -vv   # More details
ansible-navigator run site.yml --mode stdout -vvv  # Full debug output
ansible-navigator run site.yml --mode stdout -vvvv # Connection debugging

# Show differences and changes
ansible-navigator run site.yml --check --diff      # Show proposed changes
ansible-navigator run site.yml --diff              # Show actual changes
ansible-navigator run site.yml --check --diff --mode stdout

# Variable debugging (comprehensive)
ansible all -m debug -a "var=ansible_facts"        # All system facts
ansible all -m debug -a "var=hostvars[inventory_hostname]"  # All host variables
ansible all -m debug -a "var=group_names"           # Host's groups
ansible all -m debug -a "var=groups"                # All groups
ansible all -m debug -a "var=play_hosts"            # Hosts in current play
ansible all -m debug -a "var=inventory_hostname"    # Current host name

# Fact debugging and filtering
ansible all -m debug -a "var=ansible_facts.keys() | list"  # Available fact categories
ansible all -m debug -a "var=ansible_default_ipv4"
ansible all -m debug -a "var=ansible_distribution_version"
ansible all -m debug -a "var=ansible_processor_count"
ansible all -m debug -a "var=ansible_memory_mb"
ansible all -m debug -a "var=ansible_mounts"
ansible all -m debug -a "var=ansible_interfaces"

# Connection and authentication debugging
ansible all -m ping -vvv                          # Verbose connection test
ansible all -m setup --tree /tmp/facts            # Save facts for analysis
ansible all -m setup -a "filter=ansible_ssh*"     # SSH-related facts
ansible all -m debug -a "var=ansible_user"
ansible all -m debug -a "var=ansible_connection"

# Task-level debugging
ansible-navigator run site.yml --start-at-task "Debug task" --mode stdout -v
ansible-navigator run site.yml --step --mode stdout  # Step through tasks
ansible-navigator run site.yml --list-tasks        # Show all tasks
ansible-navigator run site.yml --list-hosts        # Show target hosts

# Performance and timing debugging
time ansible-navigator run site.yml --mode stdout
ansible-navigator run site.yml --mode stdout | grep -E "(TASK|PLAY|changed|ok|failed)"
ansible all -m setup -a "gather_timeout=30"

# Error analysis and recovery
ansible-navigator run site.yml --mode stdout | grep -A 5 -B 5 "FAILED"
ansible-navigator run site.yml --force-handlers    # Run handlers even on failure
ansible-navigator run site.yml --mode stdout 2>&1 | tee ansible_debug.log

# Module-specific debugging
ansible all -m debug -a "msg='Testing debug module'"
ansible all -m debug -a "msg={{ variable_name | default('undefined') }}"
ansible all -m debug -a "var=item" -e "item=test_value"
ansible all -m assert -a "that: ansible_os_family == 'RedHat'"

# Conditional debugging
ansible all -m debug -a "msg='This is a Red Hat system'" --limit "ansible_os_family == 'RedHat'"
ansible all -m debug -a "var=my_var" -e "my_var=test" when="my_var is defined"

# JSON and structured output debugging
ansible all -m setup --tree /tmp/facts
cat /tmp/facts/hostname | jq '.ansible_facts.ansible_default_ipv4'
ansible all -m debug -a "var=ansible_facts" | grep -A 20 -B 5 "default_ipv4"
```

### Comprehensive Module Testing
```bash
# System information modules
ansible hostname -m setup                      # Gather all facts
ansible hostname -m setup -a "filter=ansible_distribution*"
ansible hostname -m setup -a "filter=ansible_memory*"
ansible hostname -m setup -a "filter=ansible_processor*"
ansible hostname -m setup -a "gather_subset=network,hardware"
ansible hostname -m setup -a "gather_subset=!facter,!ohai"

# Command execution testing
ansible hostname -m command -a "uptime"
ansible hostname -m command -a "free -m"
ansible hostname -m command -a "df -h"
ansible hostname -m command -a "ps aux | head -10"
ansible hostname -m shell -a "df -h | grep /"
ansible hostname -m shell -a "netstat -tuln | grep :80"

# User and permission testing
ansible all -m command -a "whoami"
ansible all -m command -a "whoami" --become
ansible all -m command -a "whoami" --become --become-user=apache
ansible all -m command -a "id" --become
ansible all -m command -a "groups $(whoami)"
ansible all -m command -a "sudo -l" --become

# File system testing
ansible all -m stat -a "path=/etc/passwd"
ansible all -m stat -a "path=/tmp get_checksum=yes"
ansible all -m file -a "path=/tmp/test state=touch" --check
ansible all -m copy -a "content='test' dest=/tmp/test.txt" --check
ansible all -m command -a "ls -la /tmp/"

# Network connectivity testing
ansible all -m wait_for -a "host=8.8.8.8 port=53 timeout=5"
ansible all -m uri -a "url=http://httpbin.org/get method=GET" --check
ansible all -m get_url -a "url=http://httpbin.org/uuid dest=/tmp/uuid.json" --check

# Service testing
ansible all -m service_facts --become
ansible all -m systemd -a "name=sshd" --become | grep -i active
ansible all -m command -a "systemctl status sshd --no-pager" --become
ansible all -m command -a "systemctl is-active sshd"
ansible all -m command -a "systemctl is-enabled sshd"

# Package testing
ansible all -m package_facts --become
ansible all -m command -a "rpm -qa | grep httpd"
ansible all -m dnf -a "name=httpd state=present" --become --check
ansible all -m debug -a "var=ansible_facts.packages.httpd" --become

# User management testing
ansible all -m user -a "name=testuser" --become --check
ansible all -m group -a "name=testgroup" --become --check
ansible all -m command -a "getent passwd testuser"
ansible all -m command -a "getent group testgroup"

# Archive and compression testing
ansible all -m archive -a "path=/var/log dest=/tmp/logs.tar.gz" --become --check
ansible all -m unarchive -a "src=/tmp/test.tar.gz dest=/tmp/" --check

# Template and variable testing
ansible all -m template -a "src=test.j2 dest=/tmp/test.out" --check
ansible all -m debug -a "msg='Variable test: {{ ansible_hostname }}'"
ansible all -m debug -a "msg={{ 'hello world' | upper }}"

# Error testing and validation
ansible all -m command -a "exit 1" --ignore-errors
ansible all -m fail -a "msg='This is a test failure'" --check
ansible all -m assert -a "that: 1 == 1 quiet=yes"
ansible all -m assert -a "that: ansible_os_family == 'RedHat' fail_msg='Not a Red Hat system'"

# Module parameter testing
ansible all -m debug -a "var=ansible_module_args"
ansible localhost -m debug -a "var=omit"
ansible all -m copy -a "content={{ 'test' if true else omit }} dest=/tmp/conditional.txt" --check
```

### System Log Analysis and Troubleshooting
```bash
# Ansible execution logs
sudo tail -f /var/log/messages | grep ansible
journalctl -f | grep ansible
journalctl -u ansible-navigator --since "1 hour ago"
journalctl -u ssh --since "10 minutes ago"
sudo tail -f /var/log/secure | grep ansible

# SSH connection debugging
ssh -vvv ansible@hostname                      # Maximum SSH verbosity
ssh -o StrictHostKeyChecking=no ansible@hostname
ssh -o ConnectTimeout=10 ansible@hostname
ssh -o BatchMode=yes ansible@hostname          # Non-interactive mode
ssh -F ~/.ssh/config hostname
ssh -i ~/.ssh/specific_key ansible@hostname

# System authentication logs
sudo tail -f /var/log/secure                   # Authentication events
sudo grep ansible /var/log/secure
sudo journalctl -u sshd --since "1 hour ago"
sudo ausearch -m USER_AUTH --start today
lastlog | grep ansible
last | grep ansible

# Network troubleshooting
ansible all -m command -a "ss -tuln | grep :22"
ansible all -m command -a "iptables -L -n" --become
ansible all -m command -a "firewall-cmd --list-all" --become
ping -c 3 hostname
traceroute hostname
nslookup hostname

# System resource monitoring
ansible all -m command -a "top -n 1 -b | head -20"
ansible all -m command -a "iostat -x 1 3"
ansible all -m command -a "vmstat 1 3"
ansible all -m command -a "free -m"
ansible all -m command -a "df -h"

# Process and service debugging
ansible all -m command -a "ps aux | grep python"
ansible all -m command -a "systemctl status sshd --no-pager"
ansible all -m command -a "systemctl --failed" --become
ansible all -m command -a "dmesg | tail -20" --become

# File system and permissions troubleshooting
ansible all -m command -a "ls -la /home/ansible/.ssh/"
ansible all -m stat -a "path=/home/ansible/.ssh/authorized_keys"
ansible all -m command -a "getfacl /path/to/file" --become
ansible all -m command -a "semanage fcontext -l | grep ansible" --become
ansible all -m command -a "ls -Z /home/ansible/" --become

# Performance analysis
time ansible all -m ping                      # Connection timing
time ansible all -m setup                     # Fact gathering timing
ansible all -m command -a "time uptime"
strace -e trace=network ansible all -m ping 2>&1 | grep -E '(connect|send|recv)'

# Ansible configuration debugging
ansible-config dump | grep -E '(HOST_KEY_CHECKING|INVENTORY|TIMEOUT)'
echo $ANSIBLE_CONFIG
echo $ANSIBLE_INVENTORY
echo $ANSIBLE_HOST_KEY_CHECKING

# Advanced debugging techniques
strace -o ansible.trace ansible all -m ping
ltrace -o ansible.ltrace ansible all -m ping
ansible all -m setup | python3 -m json.tool > facts.json
ansible-inventory --list | jq '.webservers.hosts[]'

# Log aggregation and analysis
ansible all -m command -a "journalctl --since '1 hour ago' --no-pager" --become | tee all_logs.txt
grep -E '(ERROR|FAILED|WARNING)' ansible_debug.log
awk '/TASK.*FAILED/ {print; getline; print}' ansible_debug.log
sed -n '/PLAY RECAP/,/EOF/p' ansible_debug.log

# Remote system analysis
ansible all -m command -a "uptime && who && last | head -5"
ansible all -m shell -a "cat /proc/version && cat /etc/redhat-release" 
ansible all -m command -a "uname -a"
ansible all -m setup -a "filter=ansible_kernel"
```

---

## 10. Documentation and Help Systems

### Comprehensive Documentation Access (Exam Critical)
```bash
# Module documentation (complete reference)
ansible-doc module_name                  # Full module documentation
ansible-doc -s module_name              # Synopsis only (quick reference)
ansible-doc -l                          # List all available modules
ansible-doc -l | grep keyword           # Search for modules
ansible-doc -l | wc -l                  # Count available modules
ansible-doc -l | head -20               # First 20 modules
ansible-doc -l | sort | grep -E '^(ansible\.builtin|community\.general)'

# FQCN module documentation
ansible-doc ansible.builtin.dnf         # Built-in modules
ansible-doc community.general.firewalld # Community modules
ansible-doc ansible.posix.mount         # POSIX collection
ansible-doc containers.podman.podman_container
ansible-doc redhat.rhel_system_roles.selinux

# Plugin documentation by type
ansible-doc -t connection -l            # Connection plugins
ansible-doc -t lookup -l                # Lookup plugins  
ansible-doc -t filter -l                # Filter plugins
ansible-doc -t test -l                  # Test plugins
ansible-doc -t callback -l              # Callback plugins
ansible-doc -t cache -l                 # Cache plugins
ansible-doc -t vars -l                  # Vars plugins
ansible-doc -t inventory -l             # Inventory plugins

# Specific plugin documentation
ansible-doc -t lookup file              # File lookup plugin
ansible-doc -t lookup env               # Environment variable lookup
ansible-doc -t filter default           # Default filter
ansible-doc -t test defined             # Defined test
ansible-doc -t connection ssh           # SSH connection plugin

# Search and discovery patterns
ansible-doc -l | grep -i package        # Find package-related modules
ansible-doc -l | grep -i user           # Find user-related modules
ansible-doc -l | grep -i service        # Find service-related modules
ansible-doc -l | grep -i file           # Find file-related modules
ansible-doc -l | grep -i network        # Find network-related modules
ansible-doc -l | grep -i security       # Find security-related modules

# Documentation with examples extraction
ansible-doc dnf | grep -A 20 "EXAMPLES:"
ansible-doc systemd | grep -A 30 "EXAMPLES:"
ansible-doc copy | grep -A 15 "EXAMPLES:"
ansible-doc template | grep -A 25 "EXAMPLES:"

# Module parameter reference
ansible-doc dnf | grep -A 50 "OPTIONS:"
ansible-doc systemd | grep -A 40 "OPTIONS:"
ansible-doc user | grep -A 60 "OPTIONS:"
ansible-doc file | grep -A 35 "OPTIONS:"
```

### Navigator Interface and Help
```bash
# Navigator command help
ansible-navigator --help                 # General help
ansible-navigator run --help            # Playbook execution help
ansible-navigator config --help         # Configuration help
ansible-navigator collections --help    # Collections help
ansible-navigator doc --help            # Documentation help
ansible-navigator images --help         # Execution environment help
ansible-navigator inventory --help      # Inventory help

# Navigator interactive TUI commands
# Inside navigator interface:
:help                                   # Show comprehensive help
:doc module_name                        # View module documentation
:doc -l                                # List all modules
:collections                           # Browse collections interactively
:inventory                             # View inventory structure
:images                                # List execution environments
:config                                # View configuration
:q or :quit                           # Exit navigator
:back or ESC                          # Go back one level
:0 or :stdout                         # Switch to stdout mode
:1 or :interactive                    # Switch to interactive mode

# Navigation shortcuts in TUI
# Arrow keys or hjkl                   # Navigate lists
# Enter                                # Select item
# Tab                                  # Auto-complete
# / or ?                              # Search within content
# Page Up/Down or Ctrl+B/F            # Page through content
# Home/End                            # Go to beginning/end
# Ctrl+C or :q                        # Exit

# Navigator with different output modes
ansible-navigator --help-config         # Configuration options help
ansible-navigator --version             # Version information
ansible-navigator --help-all            # Complete help reference
```

### System Information and Fact Gathering
```bash
# Comprehensive fact gathering
ansible all -m setup                    # Gather all system facts
ansible all -m setup --tree /tmp/facts  # Save facts to files
ansible all -m setup -a "gather_subset=all" # Explicit all facts
ansible all -m setup -a "gather_timeout=30" # Custom timeout

# Filtered fact gathering (performance optimization)
ansible hostname -m setup -a "filter=ansible_distribution*"
ansible hostname -m setup -a "filter=ansible_memory*"
ansible hostname -m setup -a "filter=ansible_processor*"
ansible hostname -m setup -a "filter=ansible_mounts"
ansible hostname -m setup -a "filter=ansible_interfaces"
ansible hostname -m setup -a "filter=ansible_default_ipv4"
ansible hostname -m setup -a "filter=ansible_all_ipv4_addresses"
ansible hostname -m setup -a "filter=ansible_hostname"

# Selective fact gathering subsets
ansible all -m setup -a "gather_subset=network"
ansible all -m setup -a "gather_subset=hardware"
ansible all -m setup -a "gather_subset=virtual"
ansible all -m setup -a "gather_subset=ohai,facter"
ansible all -m setup -a "gather_subset=!all"
ansible all -m setup -a "gather_subset=!ohai,!facter"
ansible all -m setup -a "gather_subset=network,hardware"

# Network-specific information
ansible all -m setup -a "filter=ansible_default_ipv4"
ansible all -m setup -a "filter=ansible_all_ipv4_addresses"
ansible all -m setup -a "filter=ansible_dns"
ansible all -m setup -a "filter=ansible_domain"
ansible all -m setup -a "filter=ansible_interfaces"
ansible all -m setup -a "filter=ansible_route*"

# Hardware and system information
ansible all -m setup -a "filter=ansible_processor*"
ansible all -m setup -a "filter=ansible_memtotal_mb"
ansible all -m setup -a "filter=ansible_swaptotal_mb"
ansible all -m setup -a "filter=ansible_devices"
ansible all -m setup -a "filter=ansible_architecture"
ansible all -m setup -a "filter=ansible_distribution*"
ansible all -m setup -a "filter=ansible_kernel"
ansible all -m setup -a "filter=ansible_os_family"
ansible all -m setup -a "filter=ansible_pkg_mgr"
ansible all -m setup -a "filter=ansible_service_mgr"

# Custom facts and performance
ansible all -m setup -a "fact_path=/etc/ansible/facts.d"
ansible all -m setup -a "filter=ansible_local"
time ansible all -m setup > /dev/null
ansible all -m setup --tree /tmp/facts && cat /tmp/facts/hostname | jq '.ansible_facts.keys[]'
```

---

## ⚡ Quick Command Combinations for Exam

### Rapid Testing Sequence
```bash
# 1. Test connectivity
ansible all -m ping

# 2. Check syntax
ansible-navigator run site.yml --syntax-check

# 3. Dry run
ansible-navigator run site.yml --check

# 4. Execute with verbosity
ansible-navigator run site.yml --mode stdout -v

# 5. Verify results
ansible all -m setup -a "filter=ansible_service_mgr"
```

### Emergency Documentation Lookup
```bash
# Quick module search
ansible-doc -l | grep -i package
ansible-doc -l | grep -i user
ansible-doc -l | grep -i file

# Module examples
ansible-doc -s dnf
ansible-doc -s user
ansible-doc -s systemd
```

## 🎯 Exam Success Strategies

### Essential Command Patterns for Exam Day
```bash
# The "Big 4" - Master these patterns for 80% of exam tasks:

# 1. CONNECTIVITY TEST (always start here)
ansible all -m ping

# 2. SYNTAX VALIDATION (before every execution)
ansible-navigator run playbook.yml --syntax-check

# 3. DRY RUN (verify changes before applying)
ansible-navigator run playbook.yml --check --diff

# 4. EXECUTE WITH LOGGING (run and capture output)
ansible-navigator run playbook.yml --mode stdout -v | tee execution.log
```

### Time-Saving Command Combinations
```bash
# Quick validation sequence (use for every playbook):
ansible-navigator run site.yml --syntax-check && \
ansible-navigator run site.yml --check && \
ansible-navigator run site.yml --mode stdout

# Emergency troubleshooting sequence:
ansible all -m ping -vvv
ansible-config dump | grep -E '(INVENTORY|HOST_KEY|REMOTE_USER)'
ansible all -m setup -a "filter=ansible_distribution"

# Documentation lookup shortcuts:
ansible-doc -l | grep -i KEYWORD    # Find modules quickly
ansible-doc -s MODULE_NAME          # Get syntax fast
ansible-doc MODULE_NAME | grep -A 10 "EXAMPLES:"
```

### Critical Success Factors

1. **Master `ansible-doc`** - Your primary resource during the exam
2. **Always test connectivity first** - `ansible all -m ping`
3. **Validate before executing** - `--syntax-check` and `--check`
4. **Use verbosity for debugging** - `-v`, `-vv`, `-vvv` progressively
5. **Leverage navigator TUI** - Interactive mode for complex debugging
6. **Practice command patterns** - Speed comes from muscle memory
7. **Know your collections** - FQCN usage is essential
8. **Vault operations** - Practice all vault commands until automatic

**Remember**: The exam environment provides `ansible-doc` offline documentation. Use it extensively!
