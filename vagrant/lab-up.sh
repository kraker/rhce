#!/bin/bash
# RHCE Lab Startup Script
# Automatically sources credentials and starts Vagrant VMs for Ansible practice

set -e  # Exit on any error

echo "🔧 RHCE Ansible Lab Startup"
echo "============================"

# Check if credentials file exists
if [ ! -f ".rhel-credentials" ]; then
    echo "❌ Error: .rhel-credentials file not found"
    echo "   Please create it first with your Red Hat Developer credentials"
    echo ""
    echo "   You can copy the template:"
    echo "   cp .rhel-credentials.template .rhel-credentials"
    echo "   Then edit .rhel-credentials with your actual credentials"
    exit 1
fi

# Source the credentials
echo "🔑 Loading Red Hat Developer credentials..."
source .rhel-credentials

# Verify credentials were loaded
if [ -z "$RHS_USERNAME" ] || [ -z "$RHS_PASSWORD" ]; then
    echo "❌ Error: Credentials not properly loaded"
    echo "   Please check your .rhel-credentials file"
    exit 1
fi

# Check for required Vagrant plugins
echo "🔍 Checking Vagrant plugins..."
if ! vagrant plugin list | grep -q vagrant-registration; then
    echo "📦 Installing vagrant-registration plugin..."
    vagrant plugin install vagrant-registration
fi

# Start the VMs
echo ""
echo "🚀 Starting RHEL 9 VMs for RHCE lab..."
echo "   This will create 5 VMs: 1 control node + 4 managed nodes"
echo "   Initial startup may take 10-15 minutes..."
echo ""

# Show VM configuration
echo "📋 VM Configuration:"
echo "   control    (192.168.4.200) - 2GB RAM, 2 CPU - Ansible control node"
echo "   ansible1   (192.168.4.201) - 1GB RAM, 1 CPU - Web server"
echo "   ansible2   (192.168.4.202) - 1GB RAM, 1 CPU - Web server"
echo "   ansible3   (192.168.4.203) - 1GB RAM, 1 CPU - Database server"
echo "   ansible4   (192.168.4.204) - 1GB RAM, 1 CPU - Development server"
echo ""

# Start VMs
vagrant up

# Check if provisioning completed successfully
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ RHCE Lab environment ready!"
    echo ""
    echo "🎯 Ansible Setup Completed:"
    echo "   • Ansible user created on all VMs"
    echo "   • SSH key authentication configured"
    echo "   • Ansible installed on control node"
    echo "   • Default inventory and configuration deployed"
    echo "   • Web servers and database pre-configured"
    echo ""
    echo "🔗 Quick Access:"
    echo "   vagrant ssh control    # SSH to control node (Ansible controller)"
    echo "   vagrant ssh ansible1   # SSH to first managed node"
    echo "   vagrant ssh ansible2   # SSH to second managed node"
    echo "   vagrant ssh ansible3   # SSH to database server"
    echo "   vagrant ssh ansible4   # SSH to development server"
    echo ""
    echo "🎓 Getting Started:"
    echo "   1. SSH to control node: vagrant ssh control"
    echo "   2. Switch to ansible user: sudo su - ansible"
    echo "   3. Test connectivity: ansible all -m ping"
    echo "   4. Check inventory: ansible-inventory --list"
    echo ""
    echo "💡 Lab Management:"
    echo "   ./lab-halt.sh         # Stop all VMs"
    echo "   ./lab-reset.sh        # Reset lab to initial state"
    echo "   vagrant destroy       # Remove all VMs completely"
else
    echo ""
    echo "❌ Lab startup encountered errors"
    echo "   Check the output above for details"
    echo "   You may need to run 'vagrant destroy' and try again"
fi
