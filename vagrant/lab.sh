#!/bin/bash
# RHCE Lab Management Script
# Unified script for managing RHCE Ansible lab environment

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo "🎓 RHCE Lab Management"
    echo "Usage: $0 {up|halt|destroy|status}"
    echo ""
    echo "Commands:"
    echo "  up       Start the lab environment"
    echo "  halt     Stop all VMs gracefully"
    echo "  destroy  Destroy all VMs and data"
    echo "  status   Show current VM status"
    echo ""
    echo "Lab Configuration:"
    echo "  • control1  (192.168.4.200) - 2GB RAM, 2 CPU - Ansible control node"
    echo "  • ansible1  (192.168.4.201) - 1GB RAM, 1 CPU - Web server"
    echo "  • ansible2  (192.168.4.202) - 1GB RAM, 1 CPU - Web server"
    echo "  • ansible3  (192.168.4.203) - 1GB RAM, 1 CPU - Database server"
    echo "  • ansible4  (192.168.4.204) - 1GB RAM, 1 CPU - Development server"
}

check_credentials() {
    if [ ! -f ".rhel-credentials" ]; then
        echo -e "${RED}❌ Error: .rhel-credentials file not found${NC}"
        echo "   Create it first: cp .rhel-credentials.template .rhel-credentials"
        echo "   Then edit with your Red Hat Developer credentials"
        exit 1
    fi

    echo -e "${BLUE}🔑 Loading Red Hat Developer credentials...${NC}"
    source .rhel-credentials

    if [ -z "$RHS_USERNAME" ] || [ -z "$RHS_PASSWORD" ]; then
        echo -e "${RED}❌ Error: Credentials not properly loaded${NC}"
        exit 1
    fi
}

check_plugins() {
    echo -e "${BLUE}🔍 Checking Vagrant plugins...${NC}"
    if ! vagrant plugin list | grep -q vagrant-registration; then
        echo -e "${YELLOW}📦 Installing vagrant-registration plugin...${NC}"
        vagrant plugin install vagrant-registration
    fi
}

lab_up() {
    echo -e "${BLUE}🔧 RHCE Ansible Lab Startup${NC}"
    echo "============================"

    check_credentials
    check_plugins

    echo ""
    echo -e "${BLUE}🚀 Starting RHEL 9 VMs for RHCE lab...${NC}"
    echo "   This will create 5 VMs: 1 control node + 4 managed nodes"
    echo "   Initial startup may take 10-15 minutes..."
    echo ""

    vagrant up

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ RHCE Lab environment ready!${NC}"
        echo ""
        echo -e "${BLUE}🎯 Quick Access:${NC}"
        echo "   vagrant ssh control1   # SSH to control node"
        echo "   vagrant ssh ansible1   # SSH to managed node 1"
        echo ""
        echo -e "${BLUE}🎓 Getting Started:${NC}"
        echo "   1. vagrant ssh control1"
        echo "   2. sudo su - ansible"
        echo "   3. ansible all -m ping"
        echo ""
        echo -e "${BLUE}💡 Lab Management:${NC}"
        echo "   ./lab.sh halt     # Stop all VMs"
        echo "   ./lab.sh destroy  # Destroy all VMs"
    else
        echo -e "${RED}❌ Lab startup encountered errors${NC}"
        exit 1
    fi
}

lab_halt() {
    echo -e "${YELLOW}🛑 Stopping RHCE Ansible Lab${NC}"
    echo "============================"
    echo "🔄 Stopping all lab VMs gracefully..."

    vagrant halt

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ All RHCE lab VMs stopped successfully${NC}"
        echo ""
        echo -e "${BLUE}💡 Next Steps:${NC}"
        echo "   ./lab.sh up       # Start lab again"
        echo "   ./lab.sh destroy  # Destroy all VMs"
    else
        echo -e "${RED}❌ Error stopping VMs${NC}"
        echo "   Try: vagrant halt --force"
        exit 1
    fi
}

lab_destroy() {
    echo -e "${YELLOW}🗑️  Destroying RHCE Ansible Lab${NC}"
    echo "================================"
    echo -e "${YELLOW}⚠️  WARNING: This will destroy all VMs and data${NC}"
    echo ""

    read -p "Are you sure you want to destroy the lab? (yes/no): " confirm

    case $confirm in
        yes|YES|y|Y)
            echo ""
            echo -e "${YELLOW}🗑️  Destroying lab environment...${NC}"
            vagrant destroy --force
            echo ""
            echo -e "${GREEN}✅ Lab environment destroyed${NC}"
            echo ""
            echo -e "${BLUE}💡 To recreate: ./lab.sh up${NC}"
            ;;
        *)
            echo ""
            echo -e "${RED}❌ Destroy cancelled${NC}"
            exit 1
            ;;
    esac
}

lab_status() {
    echo -e "${BLUE}📊 RHCE Lab Status${NC}"
    echo "=================="
    vagrant status
}

# Main script logic
case "${1:-}" in
    up)
        lab_up
        ;;
    halt|stop)
        lab_halt
        ;;
    destroy)
        lab_destroy
        ;;
    status)
        lab_status
        ;;
    ""|help|--help|-h)
        print_usage
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
