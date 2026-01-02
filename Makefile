install: guard-FULL_NAME guard-EMAIL
	ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local -K
remote:
	ansible-playbook playbooks/configure_all.yaml -i inventory/remote.ini 
configure:
	ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local -e config=${config} --ask-become-pass
guard-%:
	@if [ -z '${${*}}' ]; then \
		echo 'Error: Environment variable $* is not set'; \
		echo 'Please set it before running make install:'; \
		echo '  export FULL_NAME="Your Name"'; \
		echo '  export EMAIL="your.email@example.com"'; \
		exit 1; \
	fi
