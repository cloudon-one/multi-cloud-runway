# Multi-Cloud Runway Infrastructure Makefile
.PHONY: help init validate plan apply destroy fmt security docs clean all

# Default target
help: ## Show this help message
	@echo "Multi-Cloud Runway Infrastructure Management"
	@echo "==========================================="
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# Prerequisites verification
verify-setup: ## Verify all required tools are installed
	@echo "Verifying prerequisites..."
	@terraform version | head -n1
	@terragrunt --version
	@aws --version | head -n1
	@gcloud version | grep "Google Cloud SDK"
	@echo "✅ All prerequisites verified"

# AWS targets
aws-init: ## Initialize AWS Terragrunt configurations
	@echo "Initializing AWS configurations..."
	@cd aws-terragrunt-configuration/aws && terragrunt run --all --non-interactive -- init

aws-validate: ## Validate AWS Terragrunt configurations
	@echo "Validating AWS configurations..."
	@cd aws-terragrunt-configuration/aws && terragrunt run --all --non-interactive -- validate

aws-plan: ## Generate AWS infrastructure plan
	@echo "Planning AWS infrastructure..."
	@cd aws-terragrunt-configuration/aws && terragrunt run --all --non-interactive -- plan

aws-apply: ## Apply AWS infrastructure changes
	@echo "Applying AWS infrastructure..."
	@cd aws-terragrunt-configuration/aws && terragrunt run --all --non-interactive -- apply

aws-destroy: ## Destroy AWS infrastructure
	@echo "⚠️  Destroying AWS infrastructure..."
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@cd aws-terragrunt-configuration/aws && terragrunt run --all --non-interactive -- destroy

# GCP targets
gcp-init: ## Initialize GCP Terragrunt configurations
	@echo "Initializing GCP configurations..."
	@cd gcp-terragrunt-configuration/terragrunt/envs && terragrunt run --all --non-interactive -- init

gcp-validate: ## Validate GCP Terragrunt configurations
	@echo "Validating GCP configurations..."
	@cd gcp-terragrunt-configuration/terragrunt/envs && terragrunt run --all --non-interactive -- validate

gcp-plan: ## Generate GCP infrastructure plan
	@echo "Planning GCP infrastructure..."
	@cd gcp-terragrunt-configuration/terragrunt/envs && terragrunt run --all --non-interactive -- plan

gcp-apply: ## Apply GCP infrastructure changes
	@echo "Applying GCP infrastructure..."
	@cd gcp-terragrunt-configuration/terragrunt/envs && terragrunt run --all --non-interactive -- apply

gcp-destroy: ## Destroy GCP infrastructure
	@echo "⚠️  Destroying GCP infrastructure..."
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@cd gcp-terragrunt-configuration/terragrunt/envs && terragrunt run --all --non-interactive -- destroy

# Combined targets
init: aws-init gcp-init ## Initialize all cloud configurations

validate: aws-validate gcp-validate ## Validate all configurations

plan: aws-plan gcp-plan ## Generate infrastructure plans for all clouds

# Format code
fmt: ## Format Terraform and Terragrunt code
	@echo "Formatting code..."
	@find . -name "*.hcl" -exec terraform fmt {} \;
	@find . -name "*.tf" -exec terraform fmt {} \;
	@echo "✅ Code formatting completed"

# Security scanning
security: ## Run security scans on infrastructure code
	@echo "Running security scans..."
	@if command -v tfsec >/dev/null 2>&1; then \
		echo "Running tfsec..."; \
		tfsec . --format json --out tfsec-results.json; \
		echo "✅ tfsec scan completed"; \
	else \
		echo "⚠️  tfsec not installed - skipping"; \
	fi
	@if command -v checkov >/dev/null 2>&1; then \
		echo "Running checkov..."; \
		checkov -d . --framework terraform --output json --output-file checkov-results.json; \
		echo "✅ checkov scan completed"; \
	else \
		echo "⚠️  checkov not installed - skipping"; \
	fi

# Cost estimation
cost: ## Generate cost estimation for infrastructure
	@echo "Generating cost estimation..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path . --format json --out-file infracost-results.json; \
		infracost output --path infracost-results.json --format table; \
		echo "✅ Cost estimation completed"; \
	else \
		echo "⚠️  infracost not installed - skipping"; \
		echo "Install with: curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh"; \
	fi

# Documentation
docs: ## Generate documentation
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do \
			if [ -f "$$dir/main.tf" ] || [ -f "$$dir/terragrunt.hcl" ]; then \
				echo "Generating docs for $$dir"; \
				terraform-docs markdown "$$dir" > "$$dir/README.md"; \
			fi \
		done; \
		echo "✅ Documentation generation completed"; \
	else \
		echo "⚠️  terraform-docs not installed - skipping"; \
		echo "Install with: go install github.com/terraform-docs/terraform-docs@latest"; \
	fi

# Linting
lint: ## Run linting on Terraform code
	@echo "Running linting..."
	@if command -v tflint >/dev/null 2>&1; then \
		find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do \
			echo "Linting $$dir"; \
			(cd "$$dir" && tflint); \
		done; \
		echo "✅ Linting completed"; \
	else \
		echo "⚠️  tflint not installed - skipping"; \
		echo "Install with: curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"; \
	fi

# Pre-commit hooks
pre-commit: ## Install and run pre-commit hooks
	@echo "Setting up pre-commit hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		pre-commit run --all-files; \
		echo "✅ Pre-commit hooks setup completed"; \
	else \
		echo "⚠️  pre-commit not installed"; \
		echo "Install with: pip install pre-commit"; \
	fi

# Environment-specific targets
dev-plan: ## Plan development environment changes
	@echo "Planning development environment..."
	@find . -path "*/dev/terragrunt.hcl" -exec dirname {} \; | while read dir; do \
		echo "Planning $$dir"; \
		(cd "$$dir" && terragrunt plan); \
	done

staging-plan: ## Plan staging environment changes
	@echo "Planning staging environment..."
	@find . -path "*/stg/terragrunt.hcl" -exec dirname {} \; | while read dir; do \
		echo "Planning $$dir"; \
		(cd "$$dir" && terragrunt plan); \
	done

prod-plan: ## Plan production environment changes
	@echo "Planning production environment..."
	@find . -path "*/prod/terragrunt.hcl" -exec dirname {} \; | while read dir; do \
		echo "Planning $$dir"; \
		(cd "$$dir" && terragrunt plan); \
	done

# Cleanup
clean: ## Clean temporary files and caches
	@echo "Cleaning temporary files..."
	@find . -name ".terragrunt-cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tfstate.backup" -delete 2>/dev/null || true
	@find . -name "*.tfplan" -delete 2>/dev/null || true
	@rm -f tfsec-results.json checkov-results.json infracost-results.json 2>/dev/null || true
	@echo "✅ Cleanup completed"

# Full workflow
all: init validate security lint fmt plan ## Run complete validation workflow

# Emergency targets
emergency-stop: ## Emergency stop of all running operations
	@echo "🚨 Emergency stop initiated..."
	@pkill -f terragrunt || true
	@pkill -f terraform || true
	@echo "✅ All operations stopped"

# Health check
health-check: ## Perform health check of deployed infrastructure
	@echo "Performing infrastructure health check..."
	@if command -v aws >/dev/null 2>&1; then \
		echo "Checking AWS health..."; \
		aws sts get-caller-identity > /dev/null && echo "✅ AWS credentials valid" || echo "❌ AWS credentials invalid"; \
	fi
	@if command -v gcloud >/dev/null 2>&1; then \
		echo "Checking GCP health..."; \
		gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 > /dev/null && echo "✅ GCP credentials valid" || echo "❌ GCP credentials invalid"; \
	fi

# Backup state
backup-state: ## Backup Terraform state files
	@echo "Backing up Terraform state files..."
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@find . -name "terraform.tfstate" -exec cp {} backups/$(shell date +%Y%m%d_%H%M%S)/ \; 2>/dev/null || true
	@echo "✅ State backup completed"

# Version information
version: ## Show version information for all tools
	@echo "Tool Versions:"
	@echo "=============="
	@echo -n "Terraform: "; terraform version | head -n1 | awk '{print $$2}'
	@echo -n "Terragrunt: "; terragrunt --version
	@echo -n "AWS CLI: "; aws --version | cut -d' ' -f1
	@echo -n "GCloud: "; gcloud version | grep "Google Cloud SDK" | awk '{print $$4}'
# ---------------------------------------------------------------------------
# Pre-production readiness gates (G1+ evidence spine)
# ---------------------------------------------------------------------------
.PHONY: score score-strict placeholders placeholder-gate assertions topology

score: ## Architecture scorecard + JSON report (ARCHITECTURE_REPORT.json / _SCORECARD.md)
	@python3 scripts/architecture-score.py

score-strict: ## Same as score, but fails below threshold / on FAIL checks
	@python3 scripts/architecture-score.py --min-score 85 --fail-on FAIL

placeholders: ## Regenerate PLACEHOLDERS.md (GR-4 register)
	@python3 scripts/placeholder-scan.py

placeholder-gate: ## Fail if any PLACEHOLDER_ token remains (pre-apply gate)
	@python3 scripts/placeholder-scan.py --gate

assertions: ## Intent -> output assertions (INPUT_ASSERTIONS.md)
	@python3 scripts/input-assertions.py
	@python3 scripts/input-assertions.py --check

topology: ## Regenerate NETWORK_TOPOLOGY.md + architecture.mmd from vars.yaml
	@python3 scripts/render-topology.py

# ---------------------------------------------------------------------------
# Pre-production gates: stg-scoped terragrunt + local CI-equivalent (G2)
# ---------------------------------------------------------------------------
.PHONY: preprod-validate preprod-plan preprod-gates-local

preprod-validate: ## run --all validate across stg trees only (both clouds)
	@echo "Validating AWS stg (us + eu)..."
	@cd aws-terragrunt-configuration/aws && terragrunt run --all --non-interactive \
		--queue-include-dir "*/us/stg" --queue-include-dir "*/eu/stg" -- validate
	@echo "Validating GCP stg..."
	@cd gcp-terragrunt-configuration/terragrunt/envs && terragrunt run --all --non-interactive \
		--queue-include-dir "stg/*/*" -- validate

preprod-plan: ## run --all plan across stg trees only; JSON plans to plans/
	@mkdir -p plans
	@echo "Planning AWS stg (us + eu)..."
	@cd aws-terragrunt-configuration/aws && terragrunt run --all --non-interactive \
		--queue-include-dir "*/us/stg" --queue-include-dir "*/eu/stg" -- plan -out=tfplan.binary
	@echo "Planning GCP stg..."
	@cd gcp-terragrunt-configuration/terragrunt/envs && terragrunt run --all --non-interactive \
		--queue-include-dir "stg/*/*" -- plan -out=tfplan.binary
	@echo "Collecting JSON plans..."
	@find aws-terragrunt-configuration gcp-terragrunt-configuration -name tfplan.binary | while read f; do \
		d=$$(dirname $$f); n=$$(echo $$d | tr '/' '_'); \
		(cd $$d && terragrunt show -json tfplan.binary > $(CURDIR)/plans/$$n.json) || exit 1; \
	done
	@echo "✅ Plans in plans/"

preprod-gates-local: ## Local equivalent of .github/workflows/preprod-gates.yml (CI billing-locked)
	@echo "== architecture-score (threshold from .github/gate-thresholds.yaml)"
	@MIN=$$(python3 -c "import yaml;print(yaml.safe_load(open('.github/gate-thresholds.yaml'))['min_architecture_score'])"); \
		python3 scripts/architecture-score.py --min-score $$MIN
	@echo "== placeholder-gate"
	@python3 scripts/placeholder-scan.py --gate
	@echo "== input-assertions (advisory until G5)"
	@python3 scripts/input-assertions.py --check || echo "  (advisory: non-blocking until G5)"
	@echo "== doc-freshness"
	@python3 scripts/validate-docs.py --check-staleness
	@echo "== security-scan (thresholds)"
	@python3 scripts/security-gate.py
	@echo "== policy-as-code (SCP fixture simulation, G3-15)"
	@python3 scripts/validate-scp.py
	@echo "✅ local gates pass"

cmek-wiring: ## Regenerate CMEK_WIRING.md (post-apply service-agent grants)
	@python3 scripts/render-cmek-wiring.py
