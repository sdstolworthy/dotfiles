# Dotfiles Repository Improvement Plan

## Overview

This document provides a detailed, step-by-step implementation plan to simplify, consolidate, and improve the reliability of the Ansible dotfiles repository. Changes are organized by priority and can be implemented incrementally.

---

## Phase 1: Critical Fixes (High Priority)

These changes address duplication, conflicts, and dead code. Should be completed first.

### 1.1 Merge `profile` and `profiled` Roles

**Problem**: Two roles do nearly identical work creating `~/.profile.d` directory.

**Current State**:
- `roles/profile/` - Creates `~/.profile.d`, sets fact, copies `.profile`
- `roles/profiled/` - Creates `~/.profile.d`, sets fact, copies files (only `go.sh`)

**Implementation Steps**:

1. **Move `go.sh` to profile role**:
   ```bash
   mv roles/profiled/files/go.sh roles/profile/files/
   ```

2. **Update `roles/profile/tasks/main.yaml`**:
   ```yaml
   - name: create profile.d directory
     file: 
       path: "{{ profiled_directory }}"
       state: directory
       mode: '0700'
   
   - name: set profile.d directory fact
     set_fact:
       profiled_directory: "{{ profiled_directory }}"
   
   - name: copy profile
     copy:
       src: ./profile
       dest: "{{ home }}/.profile"
   
   - name: copy profile.d scripts
     copy:
       src: "{{ item }}"
       dest: "{{ profiled_directory }}/"
     with_fileglob:
       - "files/*.sh"
   ```

3. **Remove profiled role**:
   ```bash
   rm -rf roles/profiled/
   ```

4. **Update documentation**: Note that profile role now handles all profile.d scripts.

**Testing**:
- Verify `~/.profile.d/go.sh` is created
- Verify `~/.profile` is created
- Run `make configure config=profile` to test

**Estimated Time**: 30 minutes

---

### 1.2 Resolve Node.js Version Manager Conflict

**Problem**: Both `asdf` and `nvm` install and manage Node.js, creating conflicts.

**Decision Required**: Choose one approach:
- **Option A**: Keep `asdf` (recommended - more flexible, multi-language)
- **Option B**: Keep `nvm` (simpler, Node.js focused)

**Recommended: Option A - Keep asdf, remove nvm**

**Implementation Steps**:

1. **Document the decision**:
   ```bash
   # Add to README.md under a "Technology Choices" section
   ```
   ```markdown
   ## Technology Choices
   
   ### Version Managers
   - **asdf**: Used for Node.js, Deno, and other language version management
   - **rustup**: Used specifically for Rust toolchain management
   ```

2. **Remove nvm role**:
   ```bash
   rm -rf roles/nvm/
   ```

3. **Update `playbooks/configure_all.yaml`**:
   ```yaml
   # Remove this line:
   # - { role: ../roles/nvm }
   ```

4. **Verify asdf nodejs configuration** in `roles/asdf/tasks/main.yaml`:
   - Ensure latest Node.js is installed
   - Ensure npm global directory is configured
   - Add npm global directory to PATH in profile script

5. **Update asdf profile script** (`roles/asdf/files/asdf_profile.sh`):
   ```bash
   # Add npm global bin to PATH if not present
   export PATH="$HOME/.npm-global/bin:$PATH"
   ```

6. **Add npm global directory setup** to `roles/asdf/tasks/main.yaml`:
   ```yaml
   - name: Create npm global install directory
     ansible.builtin.file:
       path: "{{ ansible_env.HOME }}/.npm-global"
       state: directory
       mode: '0755'
   
   - name: Configure npm global prefix
     ansible.builtin.shell: |
       . {{ ansible_env.HOME }}/.asdf/asdf.sh
       npm config set prefix "{{ ansible_env.HOME }}/.npm-global"
     args:
       executable: /bin/bash
       creates: "{{ ansible_env.HOME }}/.npmrc"
   ```

**Alternative: Option B - Keep nvm, remove Node.js from asdf**

If choosing this option instead:

1. Remove nodejs plugin tasks from `roles/asdf/tasks/main.yaml` (lines 12-30)
2. Keep nvm role as-is
3. Document why nvm was chosen over asdf

**Testing**:
- Verify `node --version` works
- Verify `npm --version` works
- Verify `asdf list nodejs` shows installed version
- Verify global npm packages install to `~/.npm-global`

**Estimated Time**: 45 minutes

---

### 1.3 Remove Unused `vim` Role

**Problem**: Empty role with no tasks, not used in playbooks.

**Implementation Steps**:

1. **Verify it's truly unused**:
   ```bash
   grep -r "vim" playbooks/
   grep -r "role.*vim" roles/*/meta/
   ```

2. **Archive the vimrc if needed**:
   ```bash
   # If you want to keep the vimrc for reference:
   mkdir -p archive/
   cp roles/vim/files/vimrc archive/vimrc.backup
   ```

3. **Remove the role**:
   ```bash
   rm -rf roles/vim/
   ```

4. **Update documentation**: Note that neovim is the primary editor.

**Testing**:
- Run `make install` - should complete without errors
- Verify neovim still works

**Estimated Time**: 10 minutes

---

### 1.4 Consolidate Variable Definitions

**Problem**: Variables like `is_mac`, `should_become`, and `home` defined in multiple places.

**Implementation Steps**:

1. **Keep only group_vars definitions**:
   - `inventory/group_vars/localhost/main.yaml` is the source of truth

2. **Remove duplicate definitions**:
   
   **File: `roles/install_software/vars/main.yaml`**
   ```bash
   # Delete this file entirely:
   rm roles/install_software/vars/main.yaml
   ```

   **File: `roles/asdf/vars/main.yaml`**
   ```bash
   # Delete this file:
   rm roles/asdf/vars/main.yaml
   ```

   **File: `roles/nvm/vars/main.yaml`**
   ```bash
   # Delete if keeping asdf, or remove 'home' definition if keeping nvm
   rm roles/nvm/vars/main.yaml  # if removing nvm
   ```

3. **Update playbooks to set `home` once**:
   
   Keep as-is in playbooks (already correct):
   ```yaml
   vars:
     home: "{{ ansible_env.HOME }}"
   ```

4. **Update any other role vars files**:
   ```bash
   # Check for other vars files with duplicates
   grep -r "is_mac\|should_become\|home:" roles/*/vars/
   ```

5. **Document variable precedence** in README:
   ```markdown
   ## Variable Configuration
   
   Global variables are defined in `inventory/group_vars/localhost/main.yaml`:
   - `is_mac`: Boolean indicating macOS
   - `should_become`: Whether to use sudo (false on Mac)
   - `full_name`: From FULL_NAME environment variable
   - `email_address`: From EMAIL environment variable
   ```

**Testing**:
- Run `ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local --check`
- Verify no undefined variable errors
- Test on both Mac and Linux if possible

**Estimated Time**: 20 minutes

---

## Phase 2: Reliability Improvements (Medium Priority)

These changes improve error handling, idempotency, and maintainability.

### 2.1 Replace `ignore_errors: true` with Proper Error Handling

**Problem**: 11 instances of `ignore_errors: true` hide real failures.

**Implementation by File**:

#### `roles/install_software/tasks/main.yaml`

**Lines 5-9 (Ripgrep install)**:
```yaml
# Current:
- name: Install Ripgrep
  become: "{{ should_become }}"
  ignore_errors: true
  ansible.builtin.package:
    name: ripgrep
    state: present

# Replace with:
- name: Check if ripgrep is available in package manager
  ansible.builtin.shell: |
    {% if is_mac %}
    brew info ripgrep > /dev/null 2>&1 && echo "available" || echo "unavailable"
    {% else %}
    {{ 'apt-cache show ripgrep' if ansible_facts['os_family'] == 'Debian' 
       else 'dnf info ripgrep' if ansible_facts['os_family'] == 'RedHat' 
       else 'pacman -Si ripgrep' }} > /dev/null 2>&1 && echo "available" || echo "unavailable"
    {% endif %}
  register: ripgrep_check
  changed_when: false
  failed_when: false

- name: Install Ripgrep
  when: ripgrep_check.stdout == "available"
  become: "{{ should_become }}"
  ansible.builtin.package:
    name: ripgrep
    state: present

- name: Warn if ripgrep not available
  when: ripgrep_check.stdout != "available"
  ansible.builtin.debug:
    msg: "WARNING: ripgrep not available in package manager. Please install manually."
```

**Lines 10-15 (FiraCode on Mac)**:
```yaml
# Current:
- name: Install FiraCode Nerd Font (Mac)
  when: is_mac
  ignore_errors: true
  community.general.homebrew_cask:
    name: font-fira-code-nerd-font
    state: present

# Replace with:
- name: Install FiraCode Nerd Font (Mac)
  when: is_mac
  community.general.homebrew_cask:
    name: font-fira-code-nerd-font
    state: present
  register: font_install_mac
  failed_when: 
    - font_install_mac.failed
    - "'already installed' not in font_install_mac.msg | default('')"
```

**Lines 17-62 (FiraCode on Linux)**:
```yaml
# Current: Multiple tasks with ignore_errors: true

# Replace with: Add overall error handling
- name: Install FiraCode Nerd Font (Linux)
  when: not is_mac
  block:
    - name: Install unzip
      become: "{{ should_become }}"
      ansible.builtin.package:
        name: unzip
        state: present
    
    - name: Create fonts directory
      become: "{{ should_become }}"
      file:
        path: /usr/local/share/fonts/FiraCodeNerdFont
        state: directory
        mode: '0755'
    
    - name: Check if font already installed
      ansible.builtin.stat:
        path: /usr/local/share/fonts/FiraCodeNerdFont/FiraCodeNerdFont-Regular.ttf
      register: font_check
    
    - name: Download and install FiraCode font
      when: not font_check.stat.exists
      block:
        - name: Download FiraCode Nerd Font
          get_url:
            url: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
            dest: /tmp/FiraCode.zip
            mode: '0644'
        
        - name: Extract FiraCode Nerd Font
          become: "{{ should_become }}"
          unarchive:
            src: /tmp/FiraCode.zip
            dest: /usr/local/share/fonts/FiraCodeNerdFont
            remote_src: yes
        
        - name: Refresh font cache
          become: "{{ should_become }}"
          command: fc-cache -fv
          changed_when: true
        
        - name: Cleanup downloaded zip
          file:
            path: /tmp/FiraCode.zip
            state: absent
  
  rescue:
    - name: Warn about font installation failure
      ansible.builtin.debug:
        msg: "WARNING: FiraCode font installation failed. Terminal may not display correctly."
    
    - name: Cleanup on failure
      file:
        path: /tmp/FiraCode.zip
        state: absent
      failed_when: false
```

**Lines 63-68 (Neovim install)**:
```yaml
# Current:
- name: Install Neovim
  ignore_errors: true
  become: "{{ should_become }}"
  ansible.builtin.package:
    name: neovim
    state: present

# Replace with:
- name: Install Neovim
  become: "{{ should_become }}"
  ansible.builtin.package:
    name: neovim
    state: present
  register: neovim_install
  failed_when:
    - neovim_install.failed
    - "'nothing provides' not in neovim_install.msg | default('')"
    - "'No package matching' not in neovim_install.msg | default('')"
```

#### `roles/zellij/tasks/main.yaml`

**Lines 1-5, 6-16 (Zellij checks)**:
```yaml
# These are correct - they use ignore_errors appropriately for checks
# But should add changed_when: false for cleanliness

- name: Check if zellij is already installed
  ansible.builtin.shell: command -v zellij
  register: zellij_check
  changed_when: false  # Add this
  failed_when: false   # Better than ignore_errors
```

**Testing Plan**:
- Test each role individually: `make configure config=<role>`
- Test full playbook on fresh VM
- Intentionally break package manager to verify error messages
- Verify warnings appear but don't stop execution where appropriate

**Estimated Time**: 2 hours

---

### 2.2 Add Idempotency Checks to Shell Commands

**Problem**: Shell commands run every time, even when not needed (slow, brittle).

**Implementation by Role**:

#### `roles/asdf/tasks/main.yaml`

```yaml
# Current lines 12-23:
- name: Add nodejs plugin
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git || true
  args:
    executable: /bin/bash

- name: Add deno plugin
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf plugin add deno https://github.com/asdf-community/asdf-deno.git || true
  args:
    executable: /bin/bash

# Replace with:
- name: Check if nodejs plugin exists
  ansible.builtin.stat:
    path: "{{ ansible_env.HOME }}/.asdf/plugins/nodejs"
  register: nodejs_plugin

- name: Add nodejs plugin
  when: not nodejs_plugin.stat.exists
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  args:
    executable: /bin/bash

- name: Check if deno plugin exists
  ansible.builtin.stat:
    path: "{{ ansible_env.HOME }}/.asdf/plugins/deno"
  register: deno_plugin

- name: Add deno plugin
  when: not deno_plugin.stat.exists
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf plugin add deno https://github.com/asdf-community/asdf-deno.git
  args:
    executable: /bin/bash

# Current lines 24-37:
- name: Install latest Node.js
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf install nodejs latest
    asdf global nodejs latest
  args:
    executable: /bin/bash

- name: Install latest Deno
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf install deno latest
    asdf global deno latest
  args:
    executable: /bin/bash

# Replace with:
- name: Get current nodejs version
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf current nodejs 2>/dev/null | awk '{print $2}' || echo "none"
  args:
    executable: /bin/bash
  register: current_nodejs
  changed_when: false

- name: Install latest Node.js
  when: current_nodejs.stdout == "none" or current_nodejs.stdout == ""
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf install nodejs latest
    asdf global nodejs latest
  args:
    executable: /bin/bash

- name: Get current deno version
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf current deno 2>/dev/null | awk '{print $2}' || echo "none"
  args:
    executable: /bin/bash
  register: current_deno
  changed_when: false

- name: Install latest Deno
  when: current_deno.stdout == "none" or current_deno.stdout == ""
  ansible.builtin.shell: |
    . {{ ansible_env.HOME }}/.asdf/asdf.sh
    asdf install deno latest
    asdf global deno latest
  args:
    executable: /bin/bash
```

#### `roles/rust/tasks/main.yaml`

```yaml
# Current:
- name: Install rustup
  ansible.builtin.shell: |
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  args:
    creates: "{{ ansible_env.HOME }}/.cargo/bin/rustup"
    executable: /bin/bash

- name: Install stable Rust toolchain
  ansible.builtin.shell: |
    . "{{ ansible_env.HOME }}/.cargo/env"
    rustup toolchain install stable
    rustup default stable
  args:
    executable: /bin/bash

# Replace second task with:
- name: Check if stable toolchain is installed
  ansible.builtin.shell: |
    . "{{ ansible_env.HOME }}/.cargo/env"
    rustup toolchain list | grep -q "^stable" && echo "installed" || echo "not_installed"
  args:
    executable: /bin/bash
  register: stable_toolchain
  changed_when: false

- name: Install stable Rust toolchain
  when: stable_toolchain.stdout == "not_installed"
  ansible.builtin.shell: |
    . "{{ ansible_env.HOME }}/.cargo/env"
    rustup toolchain install stable
    rustup default stable
  args:
    executable: /bin/bash
```

#### `roles/nvm/tasks/main.yaml` (if keeping nvm)

```yaml
# Line 16-20:
- name: Set npm global install directory
  ansible.builtin.shell: >
    npm config set prefix "{{ ansible_env.HOME }}/.npm-global"
  args:
    creates: "{{ ansible_env.HOME }}/.npm-global"

# Fix - creates checks wrong path:
- name: Check npm prefix configuration
  ansible.builtin.shell: npm config get prefix
  register: npm_prefix
  changed_when: false
  failed_when: false

- name: Set npm global install directory
  when: npm_prefix.stdout != ansible_env.HOME + "/.npm-global"
  ansible.builtin.shell: >
    npm config set prefix "{{ ansible_env.HOME }}/.npm-global"
```

**Testing**:
- Run playbook twice - second run should show minimal changes
- Time both runs - second should be significantly faster
- Verify tools still work after idempotent run

**Estimated Time**: 1.5 hours

---

### 2.3 Fix Makefile Environment Variable Guards

**Problem**: Guard for FULL_NAME and EMAIL doesn't work; actual check is commented out.

**Current State** (`Makefile` lines 1-11):
```makefile
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
```

**Implementation**:

```makefile
# Replace with working version:
install: guard-FULL_NAME guard-EMAIL
	ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local -K

remote:
	ansible-playbook playbooks/configure_all.yaml -i inventory/remote.ini 

configure:
	ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local -e config=${config} --ask-become-pass

guard-%:
	@if [ -z '${${*}}' ]; then \
		echo 'Error: Environment variable $* is not set'; \
		echo 'Please set it before running make install:'; \
		echo '  export FULL_NAME="Your Name"'; \
		echo '  export EMAIL="your.email@example.com"'; \
		exit 1; \
	fi
```

**Update README.md** with clear instructions:

```markdown
## Setup

### Required Environment Variables

Before running `make install`, set the following environment variables:

```bash
export FULL_NAME="Your Full Name"
export EMAIL="your.email@example.com"
```

### Installation

```bash
# Option 1: Export variables then run make
export FULL_NAME="John Doe"
export EMAIL="john@example.com"
make install

# Option 2: Set inline
FULL_NAME="John Doe" EMAIL="john@example.com" make install
```
```

**Testing**:
- Run `make install` without variables - should fail with clear message
- Run `FULL_NAME="Test" EMAIL="test@test.com" make install` - should work
- Verify git config gets correct values

**Estimated Time**: 15 minutes

---

## Phase 3: Code Quality Improvements (Lower Priority)

These changes improve maintainability but are not critical.

### 3.1 Extract Hard-coded Versions to Variables

**Problem**: Version numbers scattered throughout code, hard to update.

**Implementation**:

1. **Create `roles/install_software/vars/main.yaml`**:
   ```yaml
   ---
   firacode_version: "v3.4.0"
   firacode_url: "https://github.com/ryanoasis/nerd-fonts/releases/download/{{ firacode_version }}/FiraCode.zip"
   ```

2. **Create `roles/asdf/vars/main.yaml`**:
   ```yaml
   ---
   asdf_version: "v0.14.1"
   ```

3. **Create `roles/nvm/vars/main.yaml`** (if keeping nvm):
   ```yaml
   ---
   nvm_version: "v0.40.1"
   nvm_install_url: "https://raw.githubusercontent.com/nvm-sh/nvm/{{ nvm_version }}/install.sh"
   ```

4. **Update task files to use variables**:

   **`roles/install_software/tasks/main.yaml`**:
   ```yaml
   - name: Download FiraCode Nerd Font (Linux)
     when: not is_mac
     get_url:
       url: "{{ firacode_url }}"  # Instead of hardcoded URL
       dest: /tmp/FiraCode.zip
       mode: '0644'
   ```

   **`roles/asdf/tasks/main.yaml`**:
   ```yaml
   - name: Clone asdf
     ansible.builtin.git:
       repo: https://github.com/asdf-vm/asdf.git
       dest: "{{ ansible_env.HOME }}/.asdf"
       version: "{{ asdf_version }}"  # Instead of v0.14.1
       update: no
   ```

   **`roles/nvm/tasks/main.yaml`**:
   ```yaml
   - name: Install nvm
     ansible.builtin.shell: >
       curl -o- {{ nvm_install_url }} | bash
     args:
       creates: "{{ ansible_env.HOME }}/.nvm/nvm.sh"
   ```

5. **Document in README**:
   ```markdown
   ## Updating Tool Versions
   
   Tool versions are defined in role variable files:
   - asdf: `roles/asdf/vars/main.yaml`
   - nvm: `roles/nvm/vars/main.yaml` (if using)
   - FiraCode font: `roles/install_software/vars/main.yaml`
   ```

**Testing**:
- Change a version number and verify it's used
- Run playbook and check installed versions

**Estimated Time**: 30 minutes

---

### 3.2 Simplify Zellij Installation Role

**Problem**: 72 lines of complex logic for single tool.

**Current Approach**:
1. Check if installed
2. Check package manager availability  
3. Install from package manager OR
4. Download from GitHub releases with architecture detection

**Simplified Approach**:

**Option A: Prefer package manager, simple fallback**:

```yaml
---
- name: Check if zellij is already installed
  ansible.builtin.command: which zellij
  register: zellij_exists
  changed_when: false
  failed_when: false

- name: Install zellij from package manager
  when: zellij_exists.rc != 0
  become: "{{ should_become }}"
  ansible.builtin.package:
    name: zellij
    state: present
  register: zellij_pkg_install
  failed_when: false

- name: Install zellij from GitHub releases
  when: 
    - zellij_exists.rc != 0
    - zellij_pkg_install.failed or zellij_pkg_install.skipped
  block:
    - name: Set architecture facts
      set_fact:
        zellij_arch: "{{ 'x86_64' if ansible_architecture == 'x86_64' else 'aarch64' }}"
        zellij_os: "{{ 'apple-darwin' if ansible_system == 'Darwin' else 'unknown-linux-musl' }}"
    
    - name: Create .local/bin directory
      ansible.builtin.file:
        path: "{{ ansible_env.HOME }}/.local/bin"
        state: directory
        mode: '0755'
    
    - name: Download and extract zellij
      ansible.builtin.unarchive:
        src: "https://github.com/zellij-org/zellij/releases/latest/download/zellij-{{ zellij_arch }}-{{ zellij_os }}.tar.gz"
        dest: "{{ ansible_env.HOME }}/.local/bin"
        remote_src: yes
        mode: '0755'

- name: Create zellij config directory
  file:
    path: "{{ ansible_env.HOME }}/.config/zellij"
    state: directory
    mode: '0755'

- name: Copy config.kdl
  copy:
    src: "config.kdl"
    dest: "{{ ansible_env.HOME }}/.config/zellij/config.kdl"
```

**Reduction**: 72 lines → ~45 lines

**Option B: GitHub releases only** (if package manager versions are too old):

```yaml
---
- name: Check if zellij is already installed
  ansible.builtin.command: which zellij
  register: zellij_exists
  changed_when: false
  failed_when: false

- name: Install zellij
  when: zellij_exists.rc != 0
  block:
    - name: Set architecture facts
      set_fact:
        zellij_arch: "{{ 'x86_64' if ansible_architecture == 'x86_64' else 'aarch64' }}"
        zellij_os: "{{ 'apple-darwin' if ansible_system == 'Darwin' else 'unknown-linux-musl' }}"
    
    - name: Create .local/bin directory
      ansible.builtin.file:
        path: "{{ ansible_env.HOME }}/.local/bin"
        state: directory
        mode: '0755'
    
    - name: Download and extract zellij
      ansible.builtin.unarchive:
        src: "https://github.com/zellij-org/zellij/releases/latest/download/zellij-{{ zellij_arch }}-{{ zellij_os }}.tar.gz"
        dest: "{{ ansible_env.HOME }}/.local/bin"
        remote_src: yes
        mode: '0755'

- name: Create zellij config directory
  file:
    path: "{{ ansible_env.HOME }}/.config/zellij"
    state: directory
    mode: '0755'

- name: Copy config.kdl
  copy:
    src: "config.kdl"
    dest: "{{ ansible_env.HOME }}/.config/zellij/config.kdl"
```

**Reduction**: 72 lines → ~35 lines

**Testing**:
- Test on system without zellij
- Test on system with zellij already installed
- Verify config is copied correctly
- Test `zellij` command works

**Estimated Time**: 45 minutes

---

### 3.3 Use Standard Role Names in Playbooks

**Problem**: Playbooks use `role: ../roles/rolename` which is fragile.

**Current** (`playbooks/configure_all.yaml`):
```yaml
roles:
  - { role: ../roles/install_software }
  - { role: ../roles/zsh }
  - { role: ../roles/profile }
  # ... etc
```

**Implementation**:

```yaml
roles:
  - role: install_software
  - role: zsh
  - role: profile
  - role: neovim
  - role: tmux
  - role: alacritty
  - role: workplace_directory
  - role: asdf
  - role: rust
  - role: zellij
  - role: gitconfig
```

**Update both files**:
- `playbooks/configure_all.yaml`
- `playbooks/configure.yaml`

**Testing**:
- Run `make install --check` (dry run)
- Verify roles are found and loaded correctly

**Estimated Time**: 10 minutes

---

### 3.4 Clean Up Meta Dependencies

**Problem**: Roles specify `profile` dependency in meta, but playbook already orders them correctly.

**Decision Required**: Choose one approach:
- **Option A**: Remove meta dependencies, rely on playbook ordering
- **Option B**: Remove from playbook, rely on meta dependencies (better for role reusability)

**Recommended: Option B - Use meta dependencies**

**Implementation**:

1. **Keep meta files as-is**:
   - `roles/asdf/meta/main.yaml`
   - `roles/neovim/meta/main.yaml`
   - `roles/nvm/meta/main.yaml` (if keeping)

2. **Update `playbooks/configure_all.yaml`**:
   ```yaml
   - name: Install Software
     hosts: all
     roles:
       - role: install_software
   
   - name: Configure dotfiles
     hosts: all
     vars:
       home: "{{ ansible_env.HOME }}"
     roles:
       - role: zsh
       # Remove: - { role: profile }  # Handled by meta dependencies
       - role: neovim
       - role: tmux
       - role: alacritty
       - role: workplace_directory
       - role: asdf
       # Remove: - { role: nvm }  # If removing
       - role: rust
       - role: zellij
       - role: gitconfig
   ```

3. **Add meta dependencies to rust role**:
   
   **Create `roles/rust/meta/main.yaml`**:
   ```yaml
   ---
   dependencies:
     - role: profile
   ```

4. **Document the pattern**:
   ```markdown
   ## Role Dependencies
   
   Some roles depend on the `profile` role to set up `~/.profile.d`:
   - asdf
   - neovim
   - rust
   
   These dependencies are declared in `meta/main.yaml` and don't need to be 
   explicitly ordered in playbooks.
   ```

**Testing**:
- Run playbook and verify profile runs before dependent roles
- Check `~/.profile.d` contains expected scripts

**Estimated Time**: 20 minutes

---

## Phase 4: Advanced Consolidation (Optional)

These are larger refactoring efforts - only do if you have time and want further simplification.

### 4.1 Create Reusable Binary Installer Role

**Benefit**: DRY principle for tools installed from GitHub releases.

**Create `roles/binary_installer/` with parameterization**:

**Structure**:
```
roles/binary_installer/
├── tasks/
│   └── main.yaml
└── defaults/
    └── main.yaml
```

**`roles/binary_installer/defaults/main.yaml`**:
```yaml
---
binary_name: ""
github_repo: ""
archive_format: "tar.gz"  # or "zip"
install_path: "{{ ansible_env.HOME }}/.local/bin"
version: "latest"
architecture_map:
  x86_64: "x86_64"
  aarch64: "aarch64"
  arm64: "aarch64"
os_map:
  Darwin: "apple-darwin"
  Linux: "unknown-linux-musl"
```

**`roles/binary_installer/tasks/main.yaml`**:
```yaml
---
- name: "Check if {{ binary_name }} is already installed"
  ansible.builtin.command: "which {{ binary_name }}"
  register: binary_exists
  changed_when: false
  failed_when: false

- name: "Install {{ binary_name }}"
  when: binary_exists.rc != 0
  block:
    - name: Set architecture and OS facts
      set_fact:
        detected_arch: "{{ architecture_map[ansible_architecture] | default(ansible_architecture) }}"
        detected_os: "{{ os_map[ansible_system] | default('unknown-linux-musl') }}"
    
    - name: Create install directory
      ansible.builtin.file:
        path: "{{ install_path }}"
        state: directory
        mode: '0755'
    
    - name: "Download and extract {{ binary_name }}"
      ansible.builtin.unarchive:
        src: "https://github.com/{{ github_repo }}/releases/{{ version }}/download/{{ binary_name }}-{{ detected_arch }}-{{ detected_os }}.{{ archive_format }}"
        dest: "{{ install_path }}"
        remote_src: yes
        mode: '0755'
```

**Usage in zellij role**:

**`roles/zellij/meta/main.yaml`**:
```yaml
---
dependencies:
  - role: binary_installer
    vars:
      binary_name: zellij
      github_repo: zellij-org/zellij
      version: latest
```

**`roles/zellij/tasks/main.yaml`** (reduced to just config):
```yaml
---
- name: Create zellij config directory
  file:
    path: "{{ ansible_env.HOME }}/.config/zellij"
    state: directory
    mode: '0755'

- name: Copy config.kdl
  copy:
    src: "config.kdl"
    dest: "{{ ansible_env.HOME }}/.config/zellij/config.kdl"
```

**Future use cases**: Can be reused for other binaries like `bat`, `fd`, `delta`, etc.

**Estimated Time**: 2 hours

---

### 4.2 Consolidate Language Version Managers

**Benefit**: Single source of truth for all language version management.

**Create `roles/language_managers/`**:

**Structure**:
```
roles/language_managers/
├── tasks/
│   ├── main.yaml
│   ├── asdf.yaml
│   └── rust.yaml
├── files/
│   ├── asdf_profile.sh
│   └── rust_profile.sh
├── meta/
│   └── main.yaml
└── vars/
    └── main.yaml
```

**`roles/language_managers/meta/main.yaml`**:
```yaml
---
dependencies:
  - role: profile
```

**`roles/language_managers/vars/main.yaml`**:
```yaml
---
asdf_version: "v0.14.1"
asdf_plugins:
  - name: nodejs
    repo: https://github.com/asdf-vm/asdf-nodejs.git
    install_latest: true
  - name: deno
    repo: https://github.com/asdf-community/asdf-deno.git
    install_latest: true
```

**`roles/language_managers/tasks/main.yaml`**:
```yaml
---
- name: Include asdf tasks
  include_tasks: asdf.yaml
  tags: [asdf, nodejs, deno]

- name: Include rust tasks
  include_tasks: rust.yaml
  tags: [rust]
```

**Move task content from individual roles into these files.**

**Update `playbooks/configure_all.yaml`**:
```yaml
roles:
  # ...
  - role: language_managers
  # Remove: asdf, rust roles
  # ...
```

**Usage**:
```bash
# Install all language managers
make configure config=language_managers

# Install only asdf
ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local -e config=language_managers --tags asdf -K

# Install only rust
ansible-playbook playbooks/configure.yaml -i inventory/local.ini --connection=local -e config=language_managers --tags rust -K
```

**Estimated Time**: 3 hours

---

### 4.3 Create Reusable Config Deployment Tasks

**Benefit**: Consistent pattern for copying config files.

**Create `roles/common/tasks/deploy_config.yaml`**:

```yaml
---
# Parameters:
#   config_name: Name of the application
#   config_dir: Target directory (e.g., "{{ home }}/.config/{{ config_name }}")
#   config_files: List of files to copy from role's files/
#   config_templates: List of templates to process (optional)

- name: "Create {{ config_name }} config directory"
  file:
    path: "{{ config_dir }}"
    state: directory
    mode: '0755'

- name: "Copy {{ config_name }} config files"
  when: config_files is defined
  copy:
    src: "{{ item }}"
    dest: "{{ config_dir }}/{{ item | basename }}"
  loop: "{{ config_files }}"

- name: "Template {{ config_name }} config files"
  when: config_templates is defined
  template:
    src: "{{ item }}"
    dest: "{{ config_dir }}/{{ item | basename | regex_replace('\\.j2$', '') }}"
  loop: "{{ config_templates }}"
```

**Usage in roles like neovim**:

```yaml
---
- name: Deploy neovim configuration
  include_role:
    name: common
    tasks_from: deploy_config
  vars:
    config_name: neovim
    config_dir: "{{ home }}/.config/nvim"
    config_files:
      - init.lua
      - lua
      - ftplugin
      - after

- name: Add neovim profile file
  when: profiled_directory is defined
  copy:
    src: "profile"
    dest: "{{ profiled_directory }}/neovim.sh"
```

**Estimated Time**: 1.5 hours

---

## Implementation Order

### Week 1: Critical Fixes
1. Day 1: Merge profile/profiled (1.1) - 30 min
2. Day 2: Resolve Node.js conflict (1.2) - 45 min
3. Day 2: Remove vim role (1.3) - 10 min
4. Day 3: Consolidate variables (1.4) - 20 min
5. Day 4: Fix Makefile guards (2.3) - 15 min
6. Day 5: Test all changes on fresh system - 1 hour

**Total: ~3 hours**

### Week 2: Reliability
1. Replace ignore_errors (2.1) - 2 hours
2. Add idempotency checks (2.2) - 1.5 hours
3. Test on multiple systems - 1 hour

**Total: ~4.5 hours**

### Week 3: Code Quality (Optional)
1. Extract versions (3.1) - 30 min
2. Simplify zellij (3.2) - 45 min
3. Standard role names (3.3) - 10 min
4. Clean up meta dependencies (3.4) - 20 min

**Total: ~2 hours**

### Future: Advanced Consolidation (Optional)
- Do only if needed and time permits
- Each item is independent
- Total: ~6.5 hours if doing all

---

## Testing Strategy

### Per-Change Testing
After each change:
```bash
# Syntax check
ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local --syntax-check

# Dry run
ansible-playbook playbooks/configure_all.yaml -i inventory/local.ini --connection=local --check -K

# Test specific role
make configure config=<role_name>
```

### Full Integration Testing

**Before starting**:
```bash
# Create backup branch
git checkout -b backup-pre-improvements
git checkout -b feature/improvements

# Document current state
make install --check > /tmp/before.txt 2>&1
```

**After Phase 1**:
```bash
# Test on current system (idempotency)
make install

# Test on fresh VM/container
docker run -it --rm -v $(pwd):/dotfiles ubuntu:22.04
# Install ansible, then run playbook
```

**After Phase 2**:
```bash
# Measure speed improvement
time make install  # Should be faster on second run

# Verify all tools work
command -v nvim zellij tmux zsh node cargo
```

**After Phase 3**:
```bash
# Verify playbooks still work
ansible-playbook playbooks/configure_all.yaml --list-tasks
```

### Cross-Platform Testing

Test on:
- [ ] Ubuntu 22.04 (fresh install)
- [ ] macOS (if available)
- [ ] Existing configured system (idempotency)

---

## Rollback Plan

If issues arise:

1. **Per-role rollback**:
   ```bash
   git checkout main -- roles/<role_name>
   ```

2. **Full rollback**:
   ```bash
   git checkout backup-pre-improvements
   ```

3. **Partial rollback**:
   ```bash
   git revert <commit-hash>
   ```

---

## Success Metrics

After implementation:

- [ ] Reduced roles: 15 → 13 (or fewer)
- [ ] Reduced lines of code: ~150 lines
- [ ] Zero `ignore_errors: true` (or <3 with justification)
- [ ] All shell commands idempotent
- [ ] Second `make install` run <30 seconds
- [ ] Clear error messages when things fail
- [ ] All tests pass on fresh system
- [ ] Documentation updated

---

## Notes

- All changes should be committed incrementally
- Each phase should have its own branch/commits
- Document decisions in commit messages
- Update README after each phase
- Keep backup branch until confident in changes

---

## Questions to Resolve Before Starting

1. **asdf vs nvm**: Which Node.js manager to keep? (Recommend: asdf)
2. **Error handling philosophy**: Fail fast or continue with warnings? (Recommend: fail on critical, warn on optional)
3. **Testing resources**: Do you have access to both Mac and Linux? (Affects testing strategy)
4. **Time commitment**: Which phases are priority? (Recommend: at least Phases 1-2)
5. **Advanced consolidation**: Worth the effort? (Recommend: only if actively adding new tools)

---

*Last updated: 2026-01-02*
