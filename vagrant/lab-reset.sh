#!/bin/bash
# RHCE Lab Reset Script
# Resets the lab environment to initial state

set -e

echo "🔄 Resetting RHCE Ansible Lab"
echo "=============================="

echo "⚠️  WARNING: This will:"
echo "   • Stop all running VMs"
echo "   • Destroy all VMs and data"
echo "   • Recreate fresh VMs from scratch"
echo "   • Re-run provisioning automation"
echo ""

read -p "Are you sure you want to reset the lab? (yes/no): " confirm

case $confirm in
    yes|YES|y|Y)
        echo ""
        echo "🗑️  Destroying current lab environment..."
        vagrant destroy --force
        
        echo ""
        echo "🚀 Creating fresh lab environment..."
        ./lab-up.sh
        ;;
    *)
        echo ""
        echo "❌ Lab reset cancelled"
        echo ""
        echo "💡 Alternative options:"
        echo "   ./lab-halt.sh         # Stop VMs without destroying"
        echo "   ./lab-up.sh           # Start existing VMs" 
        echo "   vagrant provision     # Re-run provisioning only"
        exit 1
        ;;
esac