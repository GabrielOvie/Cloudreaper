#!/bin/bash
set -e

echo "🌍 CloudReaper Installation Script"
echo "---------------------------------"

# Check for Python 3.8+
if command -v python3 &>/dev/null; then
  PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
  echo "✅ Found Python version $PYTHON_VERSION"
else
  echo "❌ Python 3.8+ is required but not found. Please install Python 3.8 or higher."
  exit 1
fi

# Create and activate virtual environment (optional but recommended)
if [ ! -d ".venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv .venv
fi
source .venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install required Python packages (boto3 is required for AWS modules)
echo "Installing Python dependencies..."
pip install boto3 jinja2 ansible

# Install Ansible collections
echo "Installing Ansible collections..."
ansible-galaxy collection install amazon.aws community.aws

# Verify AWS CLI installation
if ! command -v aws &>/dev/null; then
  echo "❌ AWS CLI not found. Please install AWS CLI version 2:"
  echo "   https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
  exit 1
else
  AWS_CLI_VERSION=$(aws --version 2>&1)
  echo "✅ Found AWS CLI: $AWS_CLI_VERSION"
fi

echo "---------------------------------"
echo "✅ CloudReaper installation complete!"
echo "Next steps:"
echo "1. Run './scripts/setup-aws.sh' to configure AWS credentials."
echo "2. Run 'ansible-playbook ansible/playbooks/cost-audit.yml' to start your first cost audit."
echo "3. Activate the virtual environment before running Ansible commands:"
echo "   source .venv/bin/activate"

