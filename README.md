# Stolworthy Dotfiles

## Getting Started

### Install ansible

See [Ansible's Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip).

### Required Environment Variables

Before running `make install`, set the following environment variables:

```bash
export FULL_NAME="Your Full Name"
export EMAIL="your.email@example.com"
```

These are used to configure git user settings.

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

```bash
# Export environment variables first
export FULL_NAME="Your Name"
export EMAIL="your.email@example.com"

# Run the playbook
ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local -K

# Or use make
make install
```

### Running specific roles

A generic `configure` playbook is configured that accepts a role name. 
The configure playbook will run only that role.

This play can also be run from the Makefile using `make configure config=$ROLE_NAME`.

For example:
```bash
make configure config=neovim
```

## Configuration

### Variable Configuration

Global variables are defined in `inventory/group_vars/localhost/main.yaml`:
- `is_mac`: Boolean indicating macOS
- `should_become`: Whether to use sudo (false on Mac)
- `full_name`: From FULL_NAME environment variable
- `email_address`: From EMAIL environment variable

Role-specific variables are defined in each role's `vars/main.yaml` file.

### Updating Tool Versions

Tool versions are defined in role variable files:
- **Language managers**: `roles/language_managers/vars/main.yaml` - `asdf_version` and plugin configurations
- **FiraCode font**: `roles/install_software/vars/main.yaml` - `firacode_version`

To update a tool version, edit the corresponding vars file and re-run the playbook.

### Role Dependencies

Some roles automatically depend on the `profile` role to set up `~/.profile.d`:
- **language_managers** - For asdf and cargo/rustup shell integration
- **neovim** - For neovim PATH configuration

These dependencies are declared in each role's `meta/main.yaml` file. The profile role will run automatically before any role that depends on it, without needing to be explicitly listed in playbooks.

### Technology Choices

**Version Managers**:
- `asdf`: Used for Node.js, Deno, and other language version management
- `rustup`: Used specifically for Rust toolchain management

Both are managed through the `language_managers` role.

### Using the Language Managers Role

The `language_managers` role supports tags for selective installation:

```bash
# Install all language managers
make configure config=language_managers

# Install only asdf (Node.js, Deno)
ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local \
  -e config=language_managers --tags asdf -K

# Install only rust
ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local \
  -e config=language_managers --tags rust -K
```

Available tags: `asdf`, `nodejs`, `deno`, `rust`, `cargo`
