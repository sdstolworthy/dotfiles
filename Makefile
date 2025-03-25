
install: check-env
	ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local -K
remote:
	ansible-playbook playbooks/configure_all.yaml -i inventory/remote.ini 
configure:
	ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local -e config=${config} --ask-become-pass
check-env:
ifndef FULL_NAME
	$(error FULL_NAME is undefined)
endif
ifndef EMAIL
	$(error EMAIL is undefined)
endif

