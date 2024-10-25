install:
	ansible-playbook playbooks/configure_all.yaml -i inventory.ini -K --connection=local
configure:
	ansible-playbook playbooks/${config}.yaml -i inventory.ini --connection=local


