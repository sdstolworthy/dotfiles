# Stolworthy Dotfiles

## Getting Started

### Install ansible

See [Ansible's Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip).

### Running the playbook

To run the playbook against localhost, ensure that the inventory file is set up correctly

```
# ansible/inventory.ini
[localhost]
127.0.0.1
```

To install workspace dependencies and configurations,
run the `configure_all.yaml` playbook.

```
ansible-playbook configure_all.yaml -i inventory.ini --connection=local -K
```
