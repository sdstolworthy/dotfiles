install:
	ansible-playbook playbooks/configure_all.yaml -i inventory.ini -K --connection=local
configure:
	ansible-playbook playbooks/configure.yaml -i inventory.ini --connection=local -e config=${config}


