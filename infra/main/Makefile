.PHONY: init-tf plan-tf apply-tf

init-tf:
	terraform init -backend-config="backend.tfvars"

plan-tf:
	terraform plan -var-file="terraform.tfvars"

apply-tf:
	terraform apply -var-file="terraform.tfvars"
