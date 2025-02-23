#!/bin/bash

echo "======================================"
echo "       Running vsh Bootstrap          "
echo "======================================"

# Log function for better debugging
log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Ensure this script runs only once per user
ZSH_BOOTSTRAP_FLAG="$HOME/.zsh_bootstrap_done"

if [ -f "$ZSH_BOOTSTRAP_FLAG" ]; then
    log "Bootstrap already completed. Skipping."
    exit 0
fi

# Check if Poetry is installed
if command -v poetry &>/dev/null; then
    log "Poetry is already installed. Skipping installation."
else
    log "Poetry not found. Installing..."
    curl -sSL https://install.python-poetry.org | python3 - 2>&1 | tee ~/poetry_install.log
    if [ $? -ne 0 ]; then
        error "Failed to install Poetry. Check ~/poetry_install.log for details."
    fi
    log "Poetry installed successfully."
fi

# Ensure Poetry is in PATH
POETRY_BIN="$HOME/.local/bin/poetry"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    log "Adding Poetry to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    log "Poetry path added. Run 'source ~/.zshrc' to apply changes."
fi

# Reload shell environment to apply PATH changes
export PATH="$HOME/.local/bin:$PATH"

# Check if Valthera is installed
if poetry run valthera --help &>/dev/null; then
    log "Valthera CLI is already installed. Skipping installation."
else
    log "Installing Valthera CLI..."
    
    poetry self add valthera 2>&1 | tee ~/valthera_install.log
    if [ $? -ne 0 ]; then
        error "Failed to install Valthera CLI. Check ~/valthera_install.log for details."
    fi

    # Verify installation
    if ! poetry run valthera --help &>/dev/null; then
        error "Valthera installation failed. Check ~/valthera_install.log."
    fi

    log "Valthera CLI installed successfully."
fi

# Ensure Poetry's bin directory is in PATH
POETRY_GLOBAL_BIN="$HOME/.local/share/pypoetry/venv/bin"
if [[ ":$PATH:" != *":$POETRY_GLOBAL_BIN:"* ]]; then
    log "Adding Poetry global bin to PATH..."
    echo "export PATH=\"$POETRY_GLOBAL_BIN:\$PATH\"" >> ~/.zshrc
    echo "export PATH=\"$POETRY_GLOBAL_BIN:\$PATH\"" >> ~/.bashrc
    log "Poetry global bin added to PATH. Run 'source ~/.zshrc' to apply changes."
fi

# Reload shell environment to apply PATH changes
export PATH="$POETRY_GLOBAL_BIN:$PATH"

# Mark the bootstrap as done
touch "$ZSH_BOOTSTRAP_FLAG"

log "Bootstrap complete!"
echo "======================================"
