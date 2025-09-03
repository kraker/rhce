#!/bin/bash
# Practice Exam A Environment Startup Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "  RHCE Practice Exam A Environment"
echo "========================================="
echo

# Check if VMs are already running
echo "🔍 Checking VM status..."
RUNNING_VMS=$(vagrant status | grep "running" | wc -l)

if [ "$RUNNING_VMS" -eq 5 ]; then
    echo "✅ All 5 VMs are already running!"
    echo
else
    echo "🚀 Starting Practice Exam A environment..."
    echo "   This will create 5 VMs (control + ansible1-4)"
    echo "   First run takes ~10 minutes for download and setup"
    echo

    vagrant up
    echo
    echo "✅ Environment startup complete!"
    echo
fi

# Display environment information
echo "📋 ENVIRONMENT DETAILS"
echo "======================"
echo
echo "🖥️  VM Configuration:"
vagrant status | grep -E "(control|ansible[1-4])" | while read line; do
    vm_name=$(echo $line | awk '{print $1}')
    status=$(echo $line | awk '{print $2}')

    case $vm_name in
        control)
            ip="192.168.56.10"
            disks="20GB primary"
            ;;
        ansible1)
            ip="192.168.56.11"
            disks="20GB primary + 5GB secondary"
            ;;
        ansible2)
            ip="192.168.56.12"
            disks="20GB primary + 5GB secondary"
            ;;
        ansible3)
            ip="192.168.56.13"
            disks="20GB primary"
            ;;
        ansible4)
            ip="192.168.56.14"
            disks="20GB primary"
            ;;
    esac

    printf "   %-10s %-15s %-8s %s\n" "$vm_name" "$ip" "$status" "$disks"
done

echo
echo "🔑 EXAM STARTING CONDITIONS (MINIMAL SETUP)"
echo "==========================================="
echo "✅ Root password set to 'password' on all VMs"
echo "✅ SSH password authentication enabled"
echo "✅ Hostname resolution configured in /etc/hosts"
echo
echo "⚠️  YOU MUST CONFIGURE (EXAM TASKS):"
echo "   - Set up Red Hat repositories on all VMs"
echo "   - Install Ansible on control host"
echo "   - Create ansible user with sudo privileges"
echo "   - Generate and distribute SSH keys"
echo "   - Create Ansible inventory files"
echo "   - Store all scripts in /home/ansible directory"
echo

echo "🎯 FIRST EXAM STEPS"
echo "==================="
echo "# 1. Access control host:"
echo "vagrant ssh control"
echo
echo "# 2. Configure repositories (exam task #1):"
echo "sudo subscription-manager register --username YOUR_RH_USER --password YOUR_RH_PASS"
echo "sudo subscription-manager attach --auto"
echo "sudo subscription-manager repos --enable rhel-9-for-x86_64-appstream-rpms"
echo "sudo subscription-manager repos --enable rhel-9-for-x86_64-baseos-rpms"
echo
echo "# 3. Install Ansible:"
echo "sudo dnf install -y ansible"
echo
echo "# 4. Create ansible user:"
echo "sudo useradd ansible"
echo "sudo mkdir -p /home/ansible"
echo "sudo chown ansible:ansible /home/ansible"
echo

echo "📚 EXAM ENVIRONMENT READY!"
echo "========================="
echo "All scripts and YAML files must be stored in: /home/ansible"
echo
echo "Good luck with your Practice Exam A! 🚀"
echo
echo "To reset environment for next practice: vagrant destroy -f && vagrant up"
echo
