# Stolworthy Dotfiles

## Getting Started

### Install ansible

See [Ansible's Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip).

## Run plays
### Running the playbook

To run the playbook against localhost, ensure that the inventory file is set up correctly

```
# inventory/local.ini
[localhost]
127.0.0.1
```

To install workspace dependencies and configurations,
run the `configure_all.yaml` playbook.

```
ansible-playbook playbooks/configure_all.yaml -i inventory.ini --connection=local -K
```

Alternatively, run `make install` to run the `configure_all` play.

### Running specific roles

A generic `configure` playbook is configured that accepts a role name. 
The configure playbook will run only that role.

This play can also be run from the Makefile using `make configure config=$ROLE_NAME`.

For example:
```bash
make configure config=neovim
```
