# Copilot Instructions

## Build & Lint Commands

```bash
make install                    # Run all roles locally
make test                       # Dry-run (--check) all roles locally
make configure config=<role>    # Run a single role (e.g., config=neovim)
make install tags=<t1,t2>       # Run only specific tagged roles
make lint                       # Run ansible-lint
```

## Architecture

This is an Ansible-based dotfiles manager. Two playbooks drive everything:

- `playbooks/configure_all.yaml` — runs all roles in sequence (install_software and fonts first, then config roles)
- `playbooks/configure.yaml` — runs a single role specified via `-e config=<role>`

### How config files are deployed

Roles use one of three strategies:

1. **Symlinks** (most common) — static config files live in `roles/<role>/files/` and are symlinked to `~/.config/` or `~` via `ansible.builtin.file` with `state: link`. The link source uses `{{ playbook_dir }}/../roles/<role>/files/<file>`.
2. **Templates** — user-specific configs (e.g., `.zshrc`) use Jinja2 templates in `roles/<role>/templates/`.
3. **Direct module config** — some roles (e.g., `gitconfig`) use Ansible modules like `community.general.git_config` to set values directly.

### Shell integration via profile.d

The `profile` role creates `~/.profile.d/`. Other roles drop shell scripts there to extend PATH and environment. Roles that need this declare a dependency on `profile` in their `meta/main.yaml`.

### OS abstraction

- `is_mac` (global fact) switches between Homebrew (macOS) and direct downloads/package managers (Linux)
- `should_become: "{{ not is_mac }}"` — sudo is used on Linux but not macOS
- `has_display` gates GUI-only roles like `alacritty`

### Role dependencies

Declared in `meta/main.yaml`. Key chains: `neovim` → `profile`, `language_managers` → `profile`, `alacritty` → `fonts`.

## Conventions

- **Role structure is minimal**: most roles have only `tasks/` and `files/` or `templates/`. Handlers and tests are not used.
- **Variables**: overridable settings go in `defaults/main.yaml`; fixed values go in `vars/main.yaml`; OS-derived globals live in `inventory/group_vars/all/main.yaml`.
- **Secrets** (`inventory/group_vars/all/secrets.yaml`) are gitignored. They provide `_full_name`, `_email_address`, and optionally `gpg_signing_key`.
- **Idempotency patterns**: shell tasks use `creates:` to skip re-runs; optional installs use `failed_when: false` with debug warnings.
- **Complex roles** split tasks into included files (e.g., `language_managers` includes `mise.yaml`, `rust.yaml`).
- **Tags** match role names — each role is tagged with its own name in `configure_all.yaml`.
