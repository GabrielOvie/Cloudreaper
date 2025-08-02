#!/bin/bash

# CloudReaper Installation Script
# Infrastructure Cost Governance as Code
# Version: 1.0

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# CloudReaper ASCII Art
print_banner() {
    echo -e "${PURPLE}"
    cat << "EOF"
   _____ _                 _ _____                            
  / ____| |               | |  __ \                           
 | |    | | ___  _   _  __| | |__) |___  __ _ _ __   ___ _ __  
 | |    | |/ _ \| | | |/ _` |  _  // _ \/ _` | '_ \ / _ \ '__| 
 | |____| | (_) | |_| | (_| | | \ \  __/ (_| | |_) |  __/ |    
  \_____|_|\___/ \__,_|\__,_|_|  \_\___|\__,_| .__/ \___|_|    
                                            | |               
                                            |_|               
                                            
       Infrastructure Cost Governance as Code
                    Version 1.0
EOF
    echo -e "${NC}"
}

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system requirements
# Check system requirements
check_requirements() {
    log "Checking system requirements..."

    # Detect python binary (prefer python3.8 if available)
    if command_exists python3.8; then
        PYTHON_BIN=python3.8
    elif command_exists python3; then
        PYTHON_BIN=python3
    else
        error "Python 3.8+ is required but python3 or python3.8 not found."
    fi

    # Check Python version
    python_version=$($PYTHON_BIN -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
    required_version="3.8"
    if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
        error "Python 3.8+ is required. Found version: $python_version"
    fi

    info "✓ Python $python_version detected at $PYTHON_BIN"

    # Check pip
    if ! command_exists pip3; then
        error "pip3 is required but not installed."
    fi
    info "✓ pip3 detected"

    # Check Git
    if ! command_exists git; then
        error "Git is required but not installed."
    fi
    info "✓ Git detected"

    # Check AWS CLI (optional but recommended)
    if command_exists aws; then
        info "✓ AWS CLI detected"
    else
        warn "AWS CLI not found. It's recommended for easier AWS configuration."
    fi
}


# Install Python dependencies
install_python_deps() {
    log "Installing Python dependencies..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        info "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install requirements
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    else
        # Install core dependencies if requirements.txt doesn't exist
        info "Installing core dependencies..."
        pip install ansible>=6.0.0 boto3 botocore jinja2 PyYAML
    fi
    
    info "✓ Python dependencies installed"
}

# Install Ansible collections
install_ansible_collections() {
    log "Installing Ansible collections..."
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install required Ansible collections
    if [ -f "requirements.yml" ]; then
        ansible-galaxy install -r requirements.yml
    else
        # Install core collections
        ansible-galaxy collection install amazon.aws
        ansible-galaxy collection install community.aws
        ansible-galaxy collection install ansible.posix
    fi
    
    info "✓ Ansible collections installed"
}

# Setup AWS configuration
setup_aws_config() {
    log "Setting up AWS configuration..."
    
    if [ ! -f "$HOME/.aws/credentials" ] && [ ! -f "$HOME/.aws/config" ]; then
        warn "AWS credentials not found."
        echo
        echo "Please configure AWS credentials using one of these methods:"
        echo "1. Run 'aws configure' (if AWS CLI is installed)"
        echo "2. Set environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
        echo "3. Use IAM roles (if running on EC2)"
        echo "4. Configure ~/.aws/credentials manually"
        echo
        read -p "Do you want to configure AWS credentials now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if command_exists aws; then
                aws configure
            else
                error "AWS CLI not installed. Please install it first or configure credentials manually."
            fi
        else
            warn "Skipping AWS configuration. You'll need to configure it before running CloudReaper."
        fi
    else
        info "✓ AWS credentials found"
    fi
}

# Create directory structure
create_directories() {
    log "Creating directory structure..."
    
    # Create required directories
    mkdir -p reports
    mkdir -p logs
    mkdir -p vault
    mkdir -p backup
    
    # Set appropriate permissions
    chmod 700 vault  # Secure vault directory
    
    info "✓ Directory structure created"
}

# Setup configuration files
setup_config() {
    log "Setting up configuration files..."
    
    # Create ansible.cfg if it doesn't exist
    if [ ! -f "ansible/ansible.cfg" ]; then
        cat > ansible/ansible.cfg << EOF
[defaults]
inventory = inventory/
host_key_checking = False
timeout = 30
gathering = smart
fact_caching = memory
stdout_callback = yaml
bin_ansible_callbacks = True

[inventory]
enable_plugins = aws_ec2, yaml, ini

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
EOF
        info "✓ Created ansible.cfg"
    fi
    
    # Create basic inventory if it doesn't exist
    if [ ! -f "ansible/inventory/aws_ec2.yml" ]; then
        mkdir -p ansible/inventory
        cat > ansible/inventory/aws_ec2.yml << EOF
---
plugin: aws_ec2
regions:
  - us-east-1
  - eu-west-1
keyed_groups:
  - key: tags
    prefix: tag
  - key: instance_type
    prefix: instance_type
  - key: placement.availability_zone
    prefix: az
compose:
  ansible_host: public_ip_address
EOF
        info "✓ Created AWS EC2 dynamic inventory"
    fi
}

# Setup demo environment
setup_demo() {
    log "Setting up demo environment..."
    
    # Create demo script
    cat > scripts/demo.sh << 'EOF'
#!/bin/bash

# CloudReaper Demo Script
echo "🌍 CloudReaper Demo - Infrastructure Cost Governance as Code"
echo "=========================================================="

# Activate virtual environment
source venv/bin/activate

echo
echo "📊 Running cost audit..."
ansible-playbook ansible/playbooks/cost-audit.yml

echo
echo "📋 Demo complete! Check the reports/ directory for results."
echo "🚀 Next steps:"
echo "   1. Review the generated HTML report"
echo "   2. Customize policies in policies/ directory"
echo "   3. Run resource cleanup (dry-run): ansible-playbook ansible/playbooks/resource-cleanup.yml --check"
EOF
    
    chmod +x scripts/demo.sh
    info "✓ Demo script created"
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Test Ansible
    if ansible --version > /dev/null 2>&1; then
        info "✓ Ansible is working"
    else
        error "Ansible installation failed"
    fi
    
    # Test AWS connectivity (if credentials are configured)
    if ansible localhost -m amazon.aws.aws_caller_info > /dev/null 2>&1; then
        info "✓ AWS connectivity verified"
    else
        warn "Could not verify AWS connectivity. Please check your credentials."
    fi
    
    # Test playbook syntax
    if [ -f "ansible/playbooks/cost-audit.yml" ]; then
        if ansible-playbook ansible/playbooks/cost-audit.yml --syntax-check > /dev/null 2>&1; then
            info "✓ Playbook syntax is valid"
        else
            warn "Playbook syntax check failed"
        fi
    fi
}

# Print success message
print_success() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}🎉 CloudReaper Installation Complete! 🎉${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo "📚 Quick Start Commands:"
    echo "   source venv/bin/activate              # Activate environment"
    echo "   ./scripts/demo.sh                     # Run demo"
    echo "   ansible-playbook ansible/playbooks/cost-audit.yml  # Full audit"
    echo
    echo "📁 Important Files:"
    echo "   📊 reports/                           # Generated reports"
    echo "   📋 policies/templates/                # Policy templates"
    echo "   🔧 ansible/playbooks/                # Automation playbooks"
    echo
    echo "🔗 Resources:"
    echo "   📖 Documentation: docs/"
    echo "   🐛 Issues: https://github.com/yourusername/cloudreaper/issues"
    echo "   💬 Discussions: https://github.com/yourusername/cloudreaper/discussions"
    echo
    echo -e "${YELLOW}💡 Pro Tip: Start with './scripts/demo.sh' to see CloudReaper in action!${NC}"
    echo
}

# Main installation function
main() {
    print_banner
    
    log "Starting CloudReaper installation..."
    
    # Run installation steps
    check_requirements
    install_python_deps
    install_ansible_collections
    create_directories
    setup_config
    setup_aws_config
    setup_demo
    verify_installation
    
    print_success
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "CloudReaper Installation Script"
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --check        Check requirements only"
        echo "  --skip-aws     Skip AWS configuration"
        echo
        exit 0
        ;;
    --check)
        print_banner
        check_requirements
        echo -e "${GREEN}✓ System requirements check complete${NC}"
        exit 0
        ;;
    --skip-aws)
        print_banner
        log "Installing CloudReaper (skipping AWS configuration)..."
        check_requirements
        install_python_deps
        install_ansible_collections
        create_directories
        setup_config
        setup_demo
        verify_installation
        print_success
        ;;
    *)
        main
        ;;
esac


