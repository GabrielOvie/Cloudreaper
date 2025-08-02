# Top-level files
touch README.md LICENSE CONTRIBUTING.md CHANGELOG.md requirements.txt requirements.yml Dockerfile

# GitHub workflows and templates
mkdir -p .github/workflows .github/ISSUE_TEMPLATE
touch .github/workflows/ci.yml .github/workflows/release.yml
touch .github/ISSUE_TEMPLATE/bug_report.md .github/ISSUE_TEMPLATE/feature_request.md
touch .github/pull_request_template.md

# Documentation
mkdir docs
touch docs/installation.md docs/quick-start.md docs/architecture.md docs/policy-reference.md

# Ansible structure
mkdir -p ansible/{inventory,playbooks,roles,group_vars}
touch ansible/ansible.cfg ansible/inventory/aws_ec2.yml ansible/group_vars/all.yml
touch ansible/playbooks/{cost-audit.yml,resource-cleanup.yml,report-generation.yml}

# Ansible roles (initial files)
mkdir -p ansible/roles/aws-cost-analyzer/{tasks,vars,templates}
mkdir -p ansible/roles/resource-manager/{tasks,handlers}
mkdir -p ansible/roles/policy-enforcer/{tasks,vars}
touch ansible/roles/aws-cost-analyzer/tasks/main.yml
touch ansible/roles/aws-cost-analyzer/vars/main.yml
touch ansible/roles/aws-cost-analyzer/templates/cost-report.html.j2
touch ansible/roles/resource-manager/tasks/main.yml ansible/roles/resource-manager/handlers/main.yml
touch ansible/roles/policy-enforcer/tasks/main.yml ansible/roles/policy-enforcer/vars/main.yml

# Policy templates and examples
mkdir -p policies/{templates,examples}
touch policies/templates/{lean-startup.yml,scale-up.yml,enterprise.yml}
touch policies/examples/{edtech-startup.yml,saas-company.yml}

# Scripts
mkdir scripts
touch scripts/{install.sh,setup-aws.sh,demo.sh}

# Tests
mkdir -p tests/{unit,integration}
touch tests/unit/test_cost_calculator.py
touch tests/integration/test_aws_integration.py

# Examples
mkdir -p examples/{basic-usage,advanced/multi-account-setup}
touch examples/basic-usage/{inventory.ini,run-audit.yml}

