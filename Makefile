# Detect if we need sudo (Linux) or not (macOS)
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	ASK_BECOME =
else
	ASK_BECOME = -K
endif

install: guard-FULL_NAME guard-EMAIL
	ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local $(ASK_BECOME)

install-remote: guard-FULL_NAME guard-EMAIL
	ansible-playbook playbooks/configure_all.yaml -i inventory/remote.ini -K

install-remote-host: guard-FULL_NAME guard-EMAIL guard-REMOTE_HOST guard-REMOTE_USER
	ansible-playbook playbooks/configure_all.yaml -i "$(REMOTE_HOST)," -e "ansible_user=$(REMOTE_USER)" -K

configure:
	ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local -e config=${config} $(ASK_BECOME)

configure-remote:
	ansible-playbook playbooks/configure.yaml -i inventory/remote.ini -e config=${config} -K

configure-remote-host: guard-REMOTE_HOST guard-REMOTE_USER
	ansible-playbook playbooks/configure.yaml -i "$(REMOTE_HOST)," -e "ansible_user=$(REMOTE_USER)" -e config=${config} -K
guard-%:
	@if [ -z '${${*}}' ]; then \
		echo 'Error: Environment variable $* is not set'; \
		echo 'Please set it before running make install:'; \
		echo '  export FULL_NAME="Your Name"'; \
		echo '  export EMAIL="your.email@example.com"'; \
		exit 1; \
	fi
