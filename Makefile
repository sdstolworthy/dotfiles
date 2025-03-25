install: guard-FULL_NAME guard-EMAIL
	ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local -K
remote:
	ansible-playbook playbooks/configure_all.yaml -i inventory/remote.ini 
configure:
	ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local -e config=${config} --ask-become-pass
guard-%:
	@#$(or ${$*}, $(error $* is not set))
# guard-%:
# 	if [ -z '${${*}}' ]; then echo 'Environment variable $* not set' && exit 1; fi
