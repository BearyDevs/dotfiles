#!/bin/bash

# Install xCode cli tools
if [[ "$(uname)" == "Darwin" ]]; then
  echo "macOS deteted..."

  if xcode-select -p &>/dev/null; then
    echo "Xcode already installed"
  else
    echo "Installing commandline tools..."
    xcode-select --install
  fi
fi

# Homebrew
## Install
echo "Installing Brew..."
cd ~ && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Configuring Brew..."
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc
sleep 1
eval "$(/opt/homebrew/bin/brew shellenv)"
sleep 1
brew analytics off

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install powerlevel10k
echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

# Install bun
curl -fsSL https://bun.sh/install | bash

## Taps
echo "Tapping Brew..."
brew tap homebrew/cask-fonts # fonts
brew tap FelixKratz/formulae # qmk
brew tap fwartner/tap        # mac-cleanup
brew tap bwya77/tap          # Dock Anchor

## Formulae
echo "Installing Brew Formulae..."
### Must Have things
brew install wget
brew install curl
brew install zsh
brew install zsh-autosuggestions
brew install zsh-completions
brew install zsh-syntax-highlighting
brew install zsh-history-substring-search
brew install stow
brew install fzf
brew install bat
brew install fd
brew install zoxide
brew install lua
brew install luajit
brew install luarocks
brew install prettier
brew install make
brew install qmk
brew install ripgrep
brew install eza
brew install tlrc
brew install unzip
brew install zip
brew install grep
brew install yazi
brew install git-secrets
brew install neofetch

### Terminal
brew install git
brew install lazygit
brew install neovim
brew install starship
brew install tree-sitter
brew install tree
brew install borders
brew install gdu
brew install gx
brew install pfetch
brew install htop
brew install bottom
brew install mx-power-gadget
brew install imagemagick
brew install ffmpeg
brew install only-switch
brew install supabase/tap/supabase
brew install cocoapods
brew install mas
brew install httpie
brew install git-delta
brew install mermaid-cli
brew install minio/stable/minio
brew install fwartner/tap/mac-cleanup
brew install imagemagick ffmpeg
brew install poppler
brew install p7zip jq
brew install uv
brew install switchaudio-osx

### dev things
brew install node
brew install nvm
brew install sqlite
brew install zig
brew install python
brew install python-tk@3.11
brew install python-gdbm@3.11
brew install docker
brew install rust
brew install docker-compose
brew install nginx
brew install dotnet
brew install asitop
brew install k6
brew install pyenv
brew install go
brew install gh
brew install glab
brew install mongosh
brew install mongodb-atlas-cli
brew install pnpm
brew install dmenu
brew install tmux
brew install composer
brew install javacc
brew install glow
brew install jq
brew install java
brew install redis
brew install gemini-cli
brew install opencode
brew install gopls
brew install plantuml
brew install graphviz
brew install amazon-q
brew install postgresql

## Casks
brew install --cask raycast
brew install --cask iterm2
brew install --cask warp
brew install --cask ghostty
brew install --cask karabiner-elements
brew install --cask keycastr
brew install --cask betterdisplay
brew install --cask linearmouse
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-sf-pro
brew install --cask font-comic-shanns-mono-nerd-font
brew install --cask font-caskaydia-cove-nerd-font
brew install --cask font-inter
brew install --cask font-hurmit-nerd-font
brew install --cask font-noto-sans
brew install --cask font-poppins
brew install --cask font-noto-sans-thai
brew install --cask font-noto-sans-thai-ui
brew install --cask font-bai-jamjuree
brew install --cask font-chakra-petch
brew install --cask font-sarabun
brew install --cask font-srisakdi
brew install --cask font-niramit
brew install --cask dbeaver-community
brew install --cask lookaway
brew install --cask pearcleaner
brew install --cask dockanchor

# Rust
brew install rustup-init && sleep 1 && rustup-init -y

# Python
python3 -m venv myenv && source myenv/bin/activate
pip install bitbucket-cli

## MacOS settings
echo "Changing macOS defaults..."
defaults write com.apple.Dock autohide -bool TRUE
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write InitialKeyRepeat -int 10
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 80

csrutil status
echo "Installation complete..."

echo "Installation config from dotfile..."
cp -rvf ~/dotfile/nvim/ ~/.config/nvim/ && echo "\033[1;36m **nvim config installed success\033[0m"
cp -rvf ~/dotfile/iterm2/ ~/.config/iterm2/ && echo "\033[1;36m **iterm2 folder copy success\033[0m"
cp -rvf ~/dotfile/ghostty/ ~/.config/ghostty/ && echo "\033[1;36m **ghostty config installed success\033[0m"
cp -rvf ~/dotfile/alacritty/ ~/.config/alacritty/ && echo "\033[1;36m **alacritty config installed success\033[0m"
cp -rvf ~/dotfile/.wakatime/ ~/.config/ && echo "\033[1;36m **wakatime config installed success\033[0m"
cp -rvf ~/dotfile/yazi/ ~/.config/yazi/ && echo "\033[1;36m **yazi config installed success\033[0m"
cp -rvf ~/dotfile/.tmux ~/.tmux && echo "\033[1;36m **.tmux folder installed success\033[0m"
cp ~/dotfile/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist && echo "\033[1;36m **iterm2-config installed success\033[0m"
cp ~/dotfile/.tmux.conf ~/ && echo "\033[1;36m **tmux config installed success\033[0m"
cp ~/dotfile/.zshrc ~/ && echo "\033[1;36m **zsh config installed success\033[0m"
cp ~/dotfile/.zshenv ~/ && echo "\033[1;36m **zshenv config installed success\033[0m"
cp ~/dotfile/.gitconfig ~/ && echo "\033[1;36m **git config installed success\033[0m"
cp ~/dotfile/install.sh ~/.config/ && echo "\033[1;36m **install.sh backup success\033[0m"
cp ~/dotfile/fzf-git.sh ~/.config/ && chmod +x ~/.config/fzf-git.sh && echo "\033[1;36m **fzf-git.sh installed success\033[0m"
cp ~/dotfile/fzf_listoldfiles.sh ~/.config/ && chmod +x ~/.config/fzf_listoldfiles.sh && echo "\033[1;36m **fzf_listoldfiles.sh installed success\033[0m"
cp ~/dotfile/zoxide_openfiles_nvim.sh ~/.config/ && chmod +x ~/.config/zoxide_openfiles_nvim.sh && echo "\033[1;36m **zoxide_openfiles_nvim installed success\033[0m"
cp ~/dotfile/.ssh ~/. && echo "\033[1;36m **ssh folder backup success\033[0m"
chmod +x ~/.tmux/ && echo "\033[1;36m **permission .tmux folder success\033[0m"

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
sleep 1
chmod +x ~/.tmux/plugins/tpm/tpm

# --- iTerm2 Configuration ---
echo "Configuring iTerm2..."

# Define paths for clarity
IT2_PREFS_DIR="$HOME/Library/Preferences"
DOTFILE_IT2_CONFIG="$HOME/dotfile/com.googlecode.iterm2.plist"
TARGET_IT2_CONFIG="$IT2_PREFS_DIR/com.googlecode.iterm2.plist"

# Check if the source config file exists
if [ -f "$DOTFILE_IT2_CONFIG" ]; then
  echo "  -> Found iTerm2 config in dotfile."

  # IMPORTANT: Quit iTerm2 before changing settings to prevent overwrites
  # Using 'pkill -f' is a reliable way to find and kill the process.
  # The '|| true' part ensures the script doesn't fail if iTerm2 wasn't running.
  echo "  -> Ensuring iTerm2 is not running..."
  pkill -f "iTerm2" || true
  sleep 1 # Give the process a moment to terminate

  # Copy the new config file
  echo "  -> Copying preferences file..."
  cp "$DOTFILE_IT2_CONFIG" "$TARGET_IT2_CONFIG"

  # IMPORTANT: Force macOS to reload preferences from disk
  echo "  -> Reloading macOS preferences cache..."
  killall cfprefsd

  echo "\033[1;36m  -> **iTerm2 configuration successfully installed.\033[0m"
else
  echo "\033[1;33m  -> **WARNING: iTerm2 config not found at $DOTFILE_IT2_CONFIG. Skipping.\033[0m"
fi
# --- End of iTerm2 Configuration ---

echo "NVM install latest stable"
nvm install stable

echo "Install Yarn"
npm i -g yarn

echo "Install npm-check-updates"
npm i -g npm-check-updates

echo "Install claude-code"
npm i -g @anthropic-ai/claude-code

echo "Install Bun"
curl -fsSL https://bun.sh/install | bash

echo "Install PNPM"
curl -fsSL https://get.pnpm.io/install.sh | sh -

echo "Install mermaid-cli"
npm install -g @mermaid-js/mermaid-cli

echo "Install live-server"
npm install -g live-server

echo "Install snyk" # Check for vulnerabilities of npm packages
npm install -g snyk

echo "Config from dotfile complete!"
