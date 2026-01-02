# Stolworthy Dotfiles

## Getting Started

### Install ansible

See [Ansible's Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip).

### Required Environment Variables

Before running the playbook, set the following environment variables:

```bash
export FULL_NAME="Your Full Name"
export EMAIL="your.email@example.com"
```

These are used to configure git user settings.

## Run plays

### Running on localhost

To run the playbook against localhost:

```bash
# Export environment variables first
export FULL_NAME="Your Name"
export EMAIL="your.email@example.com"

# Run the playbook
ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local -K

# Or use make
make install
```

### Running on remote machines

There are two ways to run the playbook on remote machines:

#### Option 1: Using inventory file (recommended for multiple VMs)

1. Set up your inventory file:
```bash
# Copy the example
cp inventory/remote.ini.example inventory/remote.ini

# Edit with your VM details
# inventory/remote.ini
[remote]
192.168.1.100 ansible_user=spencer
my-vm.local ansible_user=spencer
```

2. Ensure SSH access is configured (password or key-based)

3. Run the playbook:
```bash
export FULL_NAME="Your Name"
export EMAIL="your.email@example.com"

# Install all configurations
make install-remote

# Or run specific role
make configure-remote config=neovim
```

#### Option 2: Ad-hoc remote host (quick one-off setup)

For quickly setting up a single VM without editing inventory files:

```bash
export FULL_NAME="Your Name"
export EMAIL="your.email@example.com"
export REMOTE_HOST="192.168.1.100"  # or hostname
export REMOTE_USER="spencer"

# Install all configurations
make install-remote-host

# Or run specific role
make configure-remote-host config=neovim
```

### SSH Requirements for Remote Execution

- SSH access to the remote machine (password or key-based)
- Python installed on the remote machine
- User must have sudo privileges (will prompt for sudo password with -K flag)

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
