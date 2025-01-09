#!/bin/env bash

##
 #
 # Author : Willow P. (drizzy)
 # Github : @drizzy
 #
 # Script - Setup BarOS
 ##

set -e

if [[ $EUID -eq 0 ]]; then
    echo "¡This script cannot be run as administrator!" >&2
    exit 1
fi

PACKAGES=("xorg-server" "xorg-xinit" "xorg-xrandr" "xorg-xsetroot" "xorg-xrdb" \
          "xf86-input-libinput" "xf86-video-vesa" "unzip" "curl" "bspwm" "sxhkd" \
          "polybar" "git" "neovim" "rofi" "picom" "zsh" "kitty" "neofetch" "flameshot" \
          "feh" "pipewire" "pipewire-alsa" "pipewire-audio" "pipewire-jack" \
          "pipewire-pulse" "playerctl" "lsd" "coreutils" "libnotify" "networkmanager" \
          "systemd" "brightnessctl")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_THEMES=""

function log() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

function warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

function msg() {
  echo -e ${RED}$1${NC}
}

function success() {
  echo -e "${CYAN}$1${NC}"
}

function install_dependencies() {
  msg "\tINSTALLING DEPENDENCIES"
  
  for package in "${PACKAGES[@]}"; do
    if ! pacman -Q "$package" &>/dev/null; then
      log "Installing $package..."
      sudo pacman -Sy --noconfirm
      sudo pacman -S --noconfirm --needed "$package"
    else
      echo -e $package ${PURPLE}installed${NC}
    fi
  done

  success "Installation complete.\n"

}

function theme_configuration() {

  echo -e "\e[1;34mInstall Theme and icons Dracula gtk? Y/N:\e[0m"
  read -p "> " INSTALL_THEMES

  if [[ "$INSTALL_THEMES" =~ ^[Yy]$ ]]; then
    msg "\tTHEME CONFIGURATION"

    log "Installing Themes and Icons..."

    THEME_DIR="$HOME/.themes/Dracula"
    ICON_DIR="$HOME/.icons/Dracula"
    CURSOR_DIR="$HOME/.icons/Dracula-cursors"

    if [[ ! -d "$THEME_DIR" ]]; then
      git clone --quiet https://github.com/dracula/gtk.git "$THEME_DIR"
    fi

    if [[ ! -d "$ICON_DIR" ]]; then
      git clone --quiet https://github.com/m4thewz/dracula-icons.git "$ICON_DIR"
    fi

    if [[ ! -d "$CURSOR_DIR" ]]; then
      cp -r "$THEME_DIR/kde/cursors/Dracula-cursors"/* "$CURSOR_DIR"
    fi

    success "Installation complete. Themes and icons configured correctly.\n"
  fi

}

function copy_configurations() {
  msg "\tCOPYING CONFIGURATION"

  PROJECT_DIR="$PWD/configs"
  CONFIG_DIR="$HOME/.config"
  MISC_DIR="$PWD/misc"

  log "Copying settings to $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"

  for dir in "$PROJECT_DIR"/*; do
    BASENAME=$(basename "$dir")
    TARGET="$CONFIG_DIR/$BASENAME"

    if [[ "$BASENAME" == "gtk-3.0" && "$INSTALL_THEMES" != [Yy] ]]; then    
      log "Skipping $BASENAME (themes not selected)."
      continue
    fi

    if [ -e "$TARGET" ]; then
      BACKUP="$TARGET.bk_$(date +%Y%m%d%H%M%S)"
      mv "$TARGET" "$BACKUP"
    fi

    cp -r "$dir" "$TARGET"

    chmod +x "$PROJECT_DIR/polybar/launch.sh"
    chmod +x "$PROJECT_DIR/polybar/scripts/"*
  done

  log "Copying files to $HOME/"

  for file in "$MISC_DIR"/.*; do
    BASENAME=$(basename "$file")
    TARGET="$HOME/$BASENAME"

    if [[ "$BASENAME" == ".gtkrc-2.0" && "$INSTALL_THEMES" != [Yy] ]]; then
      log "Skipping $BASENAME (themes not selected)."
      continue
    fi

    if [ -e "$TARGET" ]; then
      BACKUP="$TARGET.bk_$(date +%Y%m%d%H%M%S)"
      mv "$TARGET" "$BACKUP"
    fi

    cp -r "$file" "$TARGET"
  done

  success "¡Copy completed successfully!\n"
}

function fonts_configuration() {
  msg "\tFONTS CONFIGURATION"

  urls=(
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/NerdFontsSymbolsOnly.zip"
  )
  FONTS_DIR="$HOME/.fonts/nerd-fonts"

  mkdir -p "$FONTS_DIR"

  for url in "${urls[@]}"; do
    tmp_file="/tmp/$(basename "$url")"

    log "Downloading Fonts from $url..."
    curl -L --progress-bar -o "$tmp_file" "$url"

    if [[ $? -ne 0 ]]; then
      warn "Error: Failed to download fonts from $url."
      exit 1
    fi

    log "Extracting Fonts from $tmp_file..."
    unzip -o "$tmp_file" -d "$FONTS_DIR" > /dev/null

    rm -f "$tmp_file"
  done

  log "Rebuilding font cache..."
  fc-cache -f -v > /dev/null 2>&1

  success "Fonts successfully installed in local directory.\n"
}

function others_configuration() {
  msg "\tOTHERS CONFIGURATION"

  PLUGIN_SUDO="$HOME/.plugins/zsh/zsh-sudo"
  PLUGIN_SYNTAX="$HOME/.plugins/zsh/zsh-syntax-highlighting"
  PLUGIN_AUTO="$HOME/.plugins/zsh/zsh-autosuggestions"

  # Powerlevel10k
  if [ -d "$HOME/powerlevel10k" ]; then
    echo -e ${PURPLE}Powerlevel10k${NC} "is already installed."
  else
    log "Installing Powerlevel10k"
    git clone --quiet https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
  fi

  # NvChad
  if [ -d "$HOME/.config/nvim" ]; then
    echo -e ${PURPLE}NvChad${NC} "is already installed."
  else
    log "Installing NvChad"
    git clone --quiet https://github.com/NvChad/starter "$HOME/.config/nvim"
    nvim --headless +qall
  fi

  # ZSH Plugin SUDO
  if [ -d "$PLUGIN_SUDO" ]; then
    echo -e ${PURPLE}zsh-sudo-plugin${NC} "is already installed."
  else
    log "Installing plugin sudo"
    wget -q -P "$PLUGIN_SUDO" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh
  fi

  # ZSH Plugin Syntax highlighting
  if [ -d "$PLUGIN_SYNTAX/.git" ]; then
    echo -e ${PURPLE}zsh-syntax-highlighting${NC} "is already installed."
  else
    log "Installing plugin Syntax highlighting"
    git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_SYNTAX"
  fi  

  # ZSH Plugin Autosuggestions
  if [ -d "$PLUGIN_AUTO/.git" ]; then
    echo -e ${PURPLE}zsh-autosuggestions${NC} "is already installed."
  else
    log "Installing plugin Autosuggestions"
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGIN_AUTO"
  fi  

  success "Installation complete. Powerlevel10k, NvChad and Plugins configured correctly.\n"

}

function main() {
  
  install_dependencies

  sleep 1
  theme_configuration

  sleep 1
  copy_configurations

  sleep 1
  fonts_configuration

  sleep 1
  others_configuration

  success "\tCOMPLETE CONFIGURATION"

}

main