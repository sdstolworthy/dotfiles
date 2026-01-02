if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
fi

# Add npm global bin to PATH
export PATH="$HOME/.npm-global/bin:$PATH"
