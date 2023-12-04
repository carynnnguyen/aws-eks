# Define variables
TF_CMD := terraform
TF_PLAN_FILE := terraform.tfplan

# Targets
.PHONY: all init plan apply destroy

all: init plan apply

fmt:
	$(TF_CMD) fmt

init:
	$(TF_CMD) init

plan:
	$(TF_CMD) plan -out=$(TF_PLAN_FILE)

apply:
	$(TF_CMD) apply $(TF_PLAN_FILE)

destroy:
	$(TF_CMD) destroy
