# Practice Exam A Environment

This directory contains a dedicated Vagrant environment that exactly matches the requirements for **Practice Exam A** from Red Hat RHCE study materials.

## Environment Specifications

This environment provides **5 servers running RHEL 9**:

| Server | Hostname | IP Address | RAM | Primary Disk | Secondary Disk | Role |
|--------|----------|------------|-----|-------------|----------------|------|
| control | control.example.com | 192.168.56.10 | 1GB | 20GB | - | Control Host |
| ansible1 | ansible1.example.com | 192.168.56.11 | 1GB | 20GB | 5GB (/dev/sdb) | Managed Server |
| ansible2 | ansible2.example.com | 192.168.56.12 | 1GB | 20GB | 5GB (/dev/sdb) | Managed Server |
| ansible3 | ansible3.example.com | 192.168.56.13 | 1GB | 20GB | - | Managed Server |
| ansible4 | ansible4.example.com | 192.168.56.14 | 1GB | 20GB | - | Managed Server |

### Pre-configured Settings (Minimal - True Exam Conditions)

✅ **What's already configured** (matches exam starting conditions):

- Root user password set to `password` on all servers
- Hostname resolution configured in `/etc/hosts`
- SSH password authentication enabled for root access
- EPEL repository removed (not available on actual exam)

⚠️ **What you need to configure** (part of exam tasks):

- **Repository configuration** - Set up Red Hat repositories manually
- **Ansible installation** - Install Ansible package on control host  
- **User management** - Create ansible user with appropriate privileges
- **SSH key setup** - Generate and distribute SSH keys
- **Ansible inventory** - Create inventory files for your automation
- **Package management** - Install any additional packages needed
- **All automation tasks** as specified in exam scenarios

## Quick Start

### 1. Start the Environment

```bash
cd /path/to/rhce/vagrant/practice-exam-a
vagrant up
```

Initial startup takes ~10 minutes to download, create, and provision all 5 VMs.

### 2. Access the Control Host

```bash
# SSH to control host
vagrant ssh control

# Switch to ansible user (where you'll do your exam work)
sudo su - ansible

# Check starting conditions
pwd  # Should be /home/ansible
ls -la ~/.ssh/  # SSH keys are generated but not distributed
ansible --version  # Ansible is installed and ready
```

### 3. Begin Exam Setup Tasks

You'll need to complete these initial tasks (part of the exam):

```bash
# Test connectivity to managed nodes (this will initially fail)
ssh ansible1.example.com  # No SSH access yet

# Set up SSH access to managed nodes
ssh-copy-id root@ansible1.example.com  # Password: password
ssh-copy-id root@ansible2.example.com  # Password: password  
ssh-copy-id root@ansible3.example.com  # Password: password
ssh-copy-id root@ansible4.example.com  # Password: password

# Create and configure ansible inventory as needed for your tasks
vim inventory

# Test ansible connectivity
ansible all -i inventory -m ping
```

## Environment Management

### Start/Stop Operations

```bash
./exam-start.sh      # Start environment and show instructions
vagrant halt         # Stop all VMs
vagrant up           # Start all VMs
vagrant destroy -f   # Destroy environment (reset for next practice)
```

### Individual VM Management

```bash
vagrant status                    # Show all VM status
vagrant ssh control              # SSH to control node
vagrant ssh ansible1            # SSH to managed node
vagrant halt ansible2           # Stop specific VM
vagrant up ansible3             # Start specific VM
```

### Reset for New Practice Session

```bash
# Complete reset (destroys all VMs and data)
vagrant destroy -f
vagrant up

# This gives you a fresh exam starting environment
```

## Storage Configuration

- **ansible1** and **ansible2** have secondary 5GB disks at `/dev/sdb`
- **ansible3** and **ansible4** have only the primary 20GB disk
- Use `lsblk` or `fdisk -l` to verify disk configuration

```bash
# Check disk configuration on managed nodes
vagrant ssh ansible1 -c "lsblk"
vagrant ssh ansible2 -c "lsblk"  
```

## Network Configuration

- **Private Network**: 192.168.56.0/24 (isolated from your main network)
- **Host Resolution**: All VMs can resolve each other by hostname
- **SSH Access**: All VMs accept SSH with password authentication enabled

## Exam Practice Tips

### 1. Directory Organization

Store all your exam scripts in `/home/ansible` as required:

```bash
cd /home/ansible
mkdir playbooks roles inventory_files
```

### 2. Inventory Management

Create inventory files as needed for exam tasks:

```bash
# Basic inventory template
cat > inventory << EOF
[webservers]
ansible1.example.com
ansible2.example.com

[databases]  
ansible3.example.com

[development]
ansible4.example.com

[all:vars]
ansible_user=ansible
EOF
```

### 3. Common First Steps

```bash
# Distribute SSH keys to managed nodes (using root initially)
for host in ansible1 ansible2 ansible3 ansible4; do
    ssh-copy-id root@${host}.example.com
done

# Test connectivity
ansible all -i inventory -m ping -u root

# Create ansible user on managed nodes and configure sudo
ansible all -i inventory -m user -a "name=ansible create_home=yes" -u root
ansible all -i inventory -m copy -a "content='ansible ALL=(ALL) NOPASSWD: ALL' dest=/etc/sudoers.d/ansible mode=0440" -u root

# Set up SSH keys for ansible user
ansible all -i inventory -m authorized_key -a "user=ansible key='{{ lookup('file', '~/.ssh/id_rsa.pub') }}'" -u root

# Test with ansible user
ansible all -i inventory -m ping -u ansible
```

## Troubleshooting

### VM Issues

```bash
# Check VM status
vagrant status
VBoxManage list runningvms

# Restart VirtualBox if needed (Linux)
sudo systemctl restart virtualbox
```

### SSH Issues

```bash
# Check SSH connectivity manually
ssh root@192.168.56.11  # Password: password
ssh ansible@192.168.56.11  # After SSH key setup

# Reset SSH keys if needed
rm ~/.ssh/id_rsa*
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
```

### Ansible Issues

```bash
# Check ansible configuration
ansible-config dump
ansible-inventory --list -i inventory

# Test with verbose output
ansible all -i inventory -m ping -vvv
```

## Files and Structure

```text
practice-exam-a/
├── Vagrantfile           # VM configuration matching exam specs
├── ansible.cfg           # Basic Ansible configuration  
├── inventory             # Minimal inventory for provisioning
├── provision/
│   └── site.yml         # Initial system setup
├── exam-start.sh        # Helper script to start environment
└── README.md            # This file
```

---

**Ready to practice?** Run `./exam-start.sh` to begin your Practice Exam A session!
