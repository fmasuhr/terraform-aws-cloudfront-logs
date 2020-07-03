TERRAFORM ?= terraform
MODULES   ?= $(shell find . -type f -name "*.tf" -print0 | xargs -0 -n1 dirname | sort --unique)

.DEFAULT_GOAL := validate

.PHONY: clear
clear:
	@rm -rf .terraform

.PHONY: fmt
fmt: clear
	$(TERRAFORM) fmt

.PHONY: init
init: clear
	$(TERRAFORM) init

.PHONY: tflint
tflint: TARGET=tflint_module
tflint: $(MODULES)

.PHONY: tflint_module
tflint_module: init
	tflint -c $(PWD)/.tflint.hcl

.PHONY: validate
validate: TARGET=validate_module
validate: validate_fmt $(MODULES)

.PHONY: validate_module
validate_module: init
	$(TERRAFORM) validate

.PHONY: validate_fmt
validate_fmt: clear
	$(TERRAFORM) fmt -diff=true -check -recursive

.PHONY: $(MODULES)
$(MODULES):
	@$(MAKE) -C $@ -f $(PWD)/Makefile $(TARGET)
