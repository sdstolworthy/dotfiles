# Stolworthy Dotfiles

## Getting Started

### Install ansible

See [Ansible's Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip).

### Configure Personal Details

Create a secrets file with your git identity:

```bash
cat > inventory/group_vars/all/secrets.yaml << 'EOF'
---
_full_name: "Your Name"
_email_address: "your.email@example.com"
EOF
```

This file is gitignored. Alternatively, set `FULL_NAME` and `EMAIL` environment variables.

## Run plays

### Running on localhost

```bash
# Run all configurations
make install

# Dry-run to preview changes
make test

# Run specific role
make configure config=neovim

# Run specific tags
make install tags=fonts,neovim
```

### Running on remote machines

#### Option 1: Using inventory file (recommended for multiple VMs)

1. Set up your inventory file:
```bash
cp inventory/remote.ini.example inventory/remote.ini
# Edit with your VM details
```

2. Run the playbook:
```bash
make install-remote
make configure-remote config=neovim
```

#### Option 2: Ad-hoc remote host

```bash
export REMOTE_HOST="192.168.1.100"
export REMOTE_USER="spencer"

make install-remote-host
make configure-remote-host config=neovim
```

### SSH Requirements for Remote Execution

- SSH access to the remote machine (password or key-based)
- Python installed on the remote machine
- User must have sudo privileges

## Configuration

### Variable Configuration

Global variables are defined in `inventory/group_vars/all/main.yaml`:
- `is_mac`: Boolean indicating macOS
- `should_become`: Whether to use sudo (false on Mac)
- `full_name`: From secrets.yaml or FULL_NAME env var
- `email_address`: From secrets.yaml or EMAIL env var

Role-specific defaults are in each role's `defaults/main.yaml` (overridable) or `vars/main.yaml` (fixed).

### Updating Tool Versions

- **Nerd Fonts**: `roles/fonts/defaults/main.yaml` - `nerd_fonts_version`

### Role Dependencies

Some roles have automatic dependencies declared in `meta/main.yaml`:
- **alacritty** depends on **fonts**
- **language_managers** and **neovim** depend on **profile**

### Available Make Targets

| Target | Description |
|--------|-------------|
| `make install` | Install all configs locally |
| `make test` | Dry-run all configs |
| `make configure config=<role>` | Install specific role |
| `make install tags=<t1,t2>` | Install only tagged roles |
| `make install-remote` | Install to remote.ini hosts |

### Available Roles

- `install_software` - CLI tools (ripgrep, fzf, bat, eza, delta, etc.)
- `fonts` - Nerd Fonts (FiraCode, Monaspace)
- `zsh` - Zsh with zinit plugins
- `neovim` - Neovim configuration
- `alacritty` - Alacritty terminal
- `starship` - Starship prompt
- `zellij` - Zellij terminal multiplexer
- `gitconfig` - Git configuration
- `language_managers` - rustup
- `workplace_directory` - Create workspace directory
- `profile` - Shell profile setup
