#!/bin/bash
# RHCE Lab Halt Script
# Gracefully stops all RHCE lab VMs

set -e

echo "🛑 Stopping RHCE Ansible Lab"
echo "============================"

echo "🔄 Stopping all lab VMs gracefully..."
echo "   This will preserve VM state for next startup"

vagrant halt

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All RHCE lab VMs stopped successfully"
    echo ""
    echo "💡 Lab Management:"
    echo "   ./lab-up.sh           # Start lab again"
    echo "   ./lab-reset.sh        # Reset to initial state"
    echo "   vagrant destroy       # Remove all VMs completely"
    echo ""
    echo "📊 VM Status:"
    vagrant status
else
    echo ""
    echo "❌ Error stopping VMs"
    echo "   Check VM status: vagrant status"
    echo "   Force halt if needed: vagrant halt --force"
fi