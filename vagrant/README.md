# RHCE Vagrant Lab Environment

Minimal lab environment for Red Hat Certified Engineer (RHCE) exam preparation using Vagrant and Ansible. This setup creates a clean multi-node environment for practicing Ansible automation from scratch.

## Overview

This Vagrant configuration creates **5 RHEL 9 VMs**:

| VM Name | IP Address | RAM | Role | Purpose |
|---------|------------|-----|------|---------|
| control | 192.168.4.200 | 2GB | Control Node | Clean RHEL system for Ansible practice |
| ansible1 | 192.168.4.201 | 1GB | Managed Node | Target system for automation practice |
| ansible2 | 192.168.4.202 | 1GB | Managed Node | Target system for automation practice |
| ansible3 | 192.168.4.203 | 1GB | Managed Node | Target system for automation practice |
| ansible4 | 192.168.4.204 | 1GB | Managed Node | Target system for automation practice |

## Prerequisites

### Required Software
- **Vagrant** (≥2.3.0) - VM management
- **VirtualBox** - Hypervisor 
- **Red Hat Developer Account** - Free at [developers.redhat.com](https://developers.redhat.com/)

### Vagrant Plugins
The lab setup will automatically install required plugins:
- `vagrant-registration` - Red Hat subscription management

### System Requirements
- **RAM**: 6GB minimum (8GB recommended)
- **Disk**: 25GB free space for all VMs
- **CPU**: 4+ cores recommended
- **Network**: Internet access for initial setup

## Quick Start

### 1. Setup Credentials
```bash
# Copy credentials template
cp .rhel-credentials.template .rhel-credentials

# Edit with your Red Hat Developer account
vim .rhel-credentials
```

### 2. Start Lab Environment
```bash
# Start all VMs and configure automatically
./lab.sh up
```

This will:
- Create and start all 5 VMs
- Register with Red Hat subscription
- Create ansible user with sudo privileges
- Set up SSH key authentication between nodes
- Configure basic networking (/etc/hosts)
- Install essential packages only

### 3. Access Control Node
```bash
# SSH to the control node
vagrant ssh control

# Switch to ansible user (configured with passwordless sudo)
sudo su - ansible

# Test connectivity to all managed nodes
ansible all -m ping
```

## Lab Management

### Start/Stop Operations
```bash
./lab.sh up       # Start all VMs (initial setup ~15 minutes)
./lab.sh halt     # Stop all VMs gracefully
./lab.sh destroy  # Destroy all VMs (does not recreate)
./lab.sh status   # Show current VM status
```

### Individual VM Management
```bash
vagrant status                    # Show all VM status
vagrant ssh control              # SSH to control node
vagrant ssh ansible1            # SSH to managed node
vagrant halt ansible2           # Stop specific VM
vagrant up ansible3 --provision # Start and re-provision
```

## Ansible Configuration

### Pre-configured Setup
The lab automatically configures:

- **Ansible User**: `ansible` user on all VMs with sudo privileges
- **SSH Keys**: Passwordless authentication from control to managed nodes
- **Inventory**: Default inventory with logical host groups
- **Configuration**: Optimized ansible.cfg for lab environment
- **Collections**: Essential Ansible collections pre-installed

### Default Inventory Groups
```ini
[control]
control.example.com

[webservers]
ansible1.example.com
ansible2.example.com

[databases]  
ansible3.example.com

[development]
ansible4.example.com

[production:children]
webservers
databases
```

### Project Structure
The control node includes organized directories:
```
/home/ansible/
├── inventory           # Default inventory file
├── .ansible.cfg        # User-specific configuration
├── projects/           # Practice project directories
│   ├── webservers/     # Web server automation
│   ├── databases/      # Database management
│   └── practice/       # General practice exercises
└── .ssh/
    └── id_rsa         # SSH private key for managed nodes
```

## RHCE Practice Scenarios

### Web Server Automation (ansible1, ansible2)
- Apache HTTP Server installation and configuration
- Template deployment for configuration files
- Service management and handler implementation
- Firewall configuration for web services

### Database Management (ansible3)
- MariaDB installation and configuration
- Database and user creation
- Backup and restore procedures
- Security configuration

### Development Environment (ansible4)
- Development tools installation
- Git repository management
- Application deployment
- Testing and validation

### Multi-Node Scenarios
- Load balancer configuration
- Cross-node service dependencies
- Rolling updates and deployments
- Monitoring and logging aggregation

## Common Commands

### Connectivity Testing
```bash
# From control node as ansible user
ansible all -m ping                    # Test all nodes
ansible webservers -m setup           # Gather facts from web servers
ansible databases -m service -a "name=mariadb state=started"
```

### Inventory Management
```bash
ansible-inventory --list               # Show full inventory
ansible-inventory --graph             # Show inventory tree
ansible-inventory --host control      # Show host variables
```

### Playbook Development
```bash
ansible-playbook site.yml --check     # Dry run
ansible-playbook site.yml --syntax-check  # Validate syntax
ansible-playbook site.yml -v          # Verbose output
ansible-playbook site.yml --limit webservers  # Target specific group
```

## Troubleshooting

### Common Issues

**VMs won't start**
```bash
# Check Vagrant status
vagrant status

# Check VirtualBox VMs
VBoxManage list runningvms

# Restart VirtualBox service (Linux)
sudo systemctl restart virtualbox
```

**SSH connectivity issues**
```bash
# From control node, test SSH manually
ssh ansible@ansible1.example.com

# Check SSH keys
ls -la ~/.ssh/
cat ~/.ssh/id_rsa.pub

# Regenerate keys if needed
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
```

**Ansible connectivity problems**
```bash
# Check ansible configuration
ansible-config dump

# Test with verbose output
ansible all -m ping -vvv

# Verify inventory
ansible-inventory --list
```

**Provisioning failures**
```bash
# Re-run provisioning only
vagrant provision

# Re-run specific parts
vagrant provision --provision-with ansible

# Check provisioning logs
tail -f /tmp/ansible.log
```

### Reset Procedures

**Soft Reset** (keep VMs, re-run provisioning):
```bash
vagrant provision
```

**Hard Reset** (destroy and recreate):
```bash
./lab.sh destroy
./lab.sh up
```

**Individual VM Reset**:
```bash
vagrant destroy ansible1
vagrant up ansible1
```

## Integration with Study Materials

This lab environment is designed to work with:

- **Online Documentation**: [kraker.github.io/rhce](https://kraker.github.io/rhce)
- **Study Modules**: Practice exercises from docs/rhce_synthesis/
- **Anki Flashcards**: Hands-on validation of memorized commands
- **Practice Playbooks**: Real automation scenarios

## Security Notes

- Lab uses private network (192.168.4.0/24) isolated from external access
- SSH host key checking disabled for lab convenience (NOT for production)
- Ansible user has passwordless sudo (lab-only configuration)
- Red Hat credentials stored locally and not tracked in git

## Performance Optimization

### Resource Allocation
- Control node: 2GB RAM (runs Ansible controller)
- Managed nodes: 1GB RAM each (sufficient for practice)
- Adjust in Vagrantfile if more resources needed

### Network Performance
- Private network for fast inter-VM communication
- Host-only networking prevents external access
- SSH connection multiplexing enabled

### Storage
- Base VM disk: 20GB (auto-expanding)
- Additional 1GB disk per VM for storage exercises
- Snapshot support for quick reset scenarios

---

**Need Help?** 
- Check the main repository [README](../README.md)
- Review study materials at [kraker.github.io/rhce](https://kraker.github.io/rhce)
- Practice with the comprehensive modules in [docs/rhce_synthesis/](../docs/rhce_synthesis/)
