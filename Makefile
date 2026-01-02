# Only ask for sudo password on Linux
ifeq ($(shell uname -s),Darwin)
	ASK_BECOME =
else
	ASK_BECOME = -K
endif

# Common ansible-playbook command
ANSIBLE = ansible-playbook $(ASK_BECOME)
TAGS = $(if $(tags),--tags $(tags),)

# Inventory and connection settings
LOCAL = -i inventory/local.ini --connection=local
REMOTE = -i inventory/remote.ini -K
REMOTE_HOST_INV = -i "$(REMOTE_HOST)," -e "ansible_user=$(REMOTE_USER)" -K

.DEFAULT_GOAL := help

help:
	@echo "Usage: make <target> [config=<role>] [tags=<tags>]"
	@echo ""
	@echo "Targets:"
	@echo "  install              Install all configs locally"
	@echo "  configure            Install specific role (config=<role>)"
	@echo "  test                 Dry-run all configs locally"
	@echo "  lint                 Run ansible-lint"
	@echo "  install-remote       Install all configs to remote.ini hosts"
	@echo "  configure-remote     Install specific role to remote.ini hosts"
	@echo ""
	@echo "Options:"
	@echo "  tags=<t1,t2>         Run only tasks with specified tags"
	@echo ""
	@echo "Available roles:"
	@ls -1 roles | sed 's/^/  /'

# Targets
lint:
	ansible-lint

test:
	$(ANSIBLE) playbooks/configure_all.yaml $(LOCAL) $(TAGS) --check

install:
	$(ANSIBLE) playbooks/configure_all.yaml $(LOCAL) $(TAGS)

install-remote:
	$(ANSIBLE) playbooks/configure_all.yaml $(REMOTE) $(TAGS)

install-remote-host: guard-REMOTE_HOST guard-REMOTE_USER
	$(ANSIBLE) playbooks/configure_all.yaml $(REMOTE_HOST_INV) $(TAGS)

configure: guard-config
	$(ANSIBLE) playbooks/configure.yaml $(LOCAL) $(TAGS) -e config=$(config)

configure-remote: guard-config
	$(ANSIBLE) playbooks/configure.yaml $(REMOTE) $(TAGS) -e config=$(config)

configure-remote-host: guard-config guard-REMOTE_HOST guard-REMOTE_USER
	$(ANSIBLE) playbooks/configure.yaml $(REMOTE_HOST_INV) $(TAGS) -e config=$(config)

guard-%:
	@if [ -z '${${*}}' ]; then \
		echo 'Error: $* is not set'; \
		exit 1; \
	fi

.PHONY: install install-remote install-remote-host configure configure-remote configure-remote-host test lint
