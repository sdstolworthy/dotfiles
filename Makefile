install:
	ansible-playbook playbooks/configure_all.yaml -i inventory.ini -K --connection=local
