install:
	ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local -K
remote:
	ansible-playbook playbooks/configure_all.yaml -i inventory/remote.ini 
configure:
	ansible-playbook playbooks/configure.yaml -i inventory.ini --connection=local -e config=${config}


