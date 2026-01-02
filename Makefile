# Only ask for sudo password on Linux
ifeq ($(shell uname -s),Darwin)
	ASK_BECOME =
else
	ASK_BECOME = -K
endif

# Common ansible-playbook command
ANSIBLE = ansible-playbook $(ASK_BECOME)

# Inventory and connection settings
LOCAL = -i inventory/local.ini --connection=local
REMOTE = -i inventory/remote.ini -K
REMOTE_HOST_INV = -i "$(REMOTE_HOST)," -e "ansible_user=$(REMOTE_USER)" -K

# Targets
install: guard-FULL_NAME guard-EMAIL
	$(ANSIBLE) playbooks/configure_all.yaml $(LOCAL)

install-remote: guard-FULL_NAME guard-EMAIL
	$(ANSIBLE) playbooks/configure_all.yaml $(REMOTE)

install-remote-host: guard-FULL_NAME guard-EMAIL guard-REMOTE_HOST guard-REMOTE_USER
	$(ANSIBLE) playbooks/configure_all.yaml $(REMOTE_HOST_INV)

configure: guard-config
	$(ANSIBLE) playbooks/configure.yaml $(LOCAL) -e config=$(config)

configure-remote: guard-config
	$(ANSIBLE) playbooks/configure.yaml $(REMOTE) -e config=$(config)

configure-remote-host: guard-config guard-REMOTE_HOST guard-REMOTE_USER
	$(ANSIBLE) playbooks/configure.yaml $(REMOTE_HOST_INV) -e config=$(config)

guard-%:
	@if [ -z '${${*}}' ]; then \
		echo 'Error: $* is not set'; \
		exit 1; \
	fi

.PHONY: install install-remote install-remote-host configure configure-remote configure-remote-host
