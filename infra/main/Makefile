.PHONY: init-tf plan-tf apply-tf

init-tf:
	terraform init -backend-config="backend.tfvars"

plan-tf:
	terraform plan -var-file="terraform.local.tfvars"

apply-tf:
	terraform apply -var-file="terraform.local.tfvars"
