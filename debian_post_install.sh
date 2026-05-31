#!/bin/bash

###############################
## Functions
###############################

show_credits() {
    echo -e '
    \e[34m
        ___
       |_ _|_    ____ _ _ __
        | |\ \ / / _` |  _ \
        | | \ V / (_| | | | |
       |___| \_/ \__,_|_| |_|

      Distribution: Debian 14 (Forky)
      Desktop Environment: KDE Plasma / GNOME
      Info: Minimalist Post-Installation Script
      Version: 1.0.0
      GitHub: cristhiandevgo
    \e[0m
    '
}

show_title_message(){
    echo -e "\n${COLOR_BLUE}###################################################### \n# $1\n######################################################${COLOR_RESET}\n"
}

show_title_message_success(){
    echo -e "\n${COLOR_GREEN}###################################################### \n# $1\n######################################################${COLOR_RESET}\n"
}

show_message(){
    echo -e "$1\n"
}

show_warning_message(){
    echo -e "${COLOR_YELLOW}$1${COLOR_RESET}"
}

show_info_message(){
    echo -e "${COLOR_BLUE}$1${COLOR_RESET}"
}

pre_install(){
    show_title_message "Installing script dependencies..."
    sudo apt install -y wget gpg curl apt-transport-https
}

refresh_packages(){
    show_title_message "Refreshing package metadata and updating packages..."
    sudo apt update && sudo apt upgrade -y
}

enable_vscode_repo(){
    show_title_message "Enabling Visual Studio Code repository..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
}

enable_flathub(){
    show_title_message "Enabling Flatpak..."
    sudo apt install -y flatpak
    
    if [ "$de_option" -eq 1 ]; then
        sudo apt install -y plasma-discover-backend-flatpak
    else
        sudo apt install -y gnome-software-plugin-flatpak
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak update --appstream
}

enable_sddm(){
    show_message "Configuring SDDM as the default display manager..."
    sudo systemctl enable sddm
}

enable_gdm(){
    show_message "Configuring GDM as the default display manager..."
    sudo systemctl enable gdm3
}

enable_splashscreen() {
    show_title_message "Enabling Plymouth Splash Screen..."

    sudo apt install -y plymouth plymouth-themes

    show_message "Configuring GRUB via drop-in directory..."
    sudo mkdir -p /etc/default/grub.d

    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' \
        | sudo tee /etc/default/grub.d/99-plymouth.cfg > /dev/null

    show_message "Updating GRUB..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    show_message "Setting Debian theme and rebuilding initramfs..."
    sudo plymouth-set-default-theme -R spinner
}

enable_debian_repos(){
    if [ -f /etc/apt/sources.list.d/debian.sources ] && \
       grep -q "non-free-firmware" /etc/apt/sources.list.d/debian.sources; then
        show_info_message "Modern DEB822 repositories with non-free components already active. Skipping setup."
        return 0
    fi

    show_title_message "Configuring modern DEB822 repositories for Debian 14..."

    if [ -f /etc/apt/sources.list.d/debian.sources ]; then
        sudo cp /etc/apt/sources.list.d/debian.sources \
                 /etc/apt/sources.list.d/debian.sources.bak
    fi

    # Inject the new DEB822 structure enabling 'contrib', 'non-free' and 'non-free-firmware'
    sudo tee /etc/apt/sources.list.d/debian.sources > /dev/null <<EOF
Types: deb
URIs: http://deb.debian.org/debian/
Suites: testing testing-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://security.debian.org/debian-security
Suites: testing-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

    # Remove the old sources.list if it exists to prevent conflicts with the new DEB822 format.
    if [ -f /etc/apt/sources.list ]; then
        sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
    fi

    sudo apt update
}

enable_zram() {
    show_title_message "Installing and configuring zRAM..."

    sudo apt install -y systemd-zram-generator

    sudo tee /etc/systemd/zram-generator.conf > /dev/null <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

    sudo systemctl daemon-reload

    sudo systemctl restart systemd-zram-setup@zram0.service || true

    show_message "zRAM configured successfully."
}

enable_networkmanager_kde(){
    show_title_message "Setting NetworkManager as the default network manager..."
    sudo cp /etc/network/interfaces /etc/network/interfaces.bak
    sudo tee /etc/network/interfaces > /dev/null <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
    sudo systemctl enable NetworkManager
    sudo systemctl restart NetworkManager
}

enable_networkmanager_gnome(){
    show_title_message "Setting NetworkManager as the default network manager..."

    sudo apt install -y network-manager
    sudo systemctl enable --now NetworkManager

    sudo cp /etc/network/interfaces /etc/network/interfaces.bak

    # Keep only loopback
    sudo tee /etc/network/interfaces > /dev/null <<EOF
auto lo
iface lo inet loopback
EOF

    # Force NetworkManager to manage all devices
    sudo mkdir -p /etc/NetworkManager/conf.d

    sudo tee /etc/NetworkManager/conf.d/10-globally-managed-devices.conf > /dev/null <<EOF
[keyfile]
unmanaged-devices=none
EOF

    sudo systemctl restart NetworkManager
}

enable_gnome_extensions() {
    show_title_message "Installing GNOME extensions (AppIndicator + Dash to Panel)..."

    sudo apt update
    sudo apt install -y \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-dash-to-panel

    # Enable AppIndicator extension
    gnome-extensions enable ubuntu-appindicators@ubuntu.com || true

    # Enable Dash to Panel extension
    gnome-extensions enable dash-to-panel@jderose9.github.com || true

    show_message "Done. The extensions should be active immediately, but you may need to log out and back in for all features to work properly."
}

enable_mozilla_repo() {
    # Mozilla's official APT repository using modern DEB822 format.

    local MOZILLA_SOURCE_FILE="/etc/apt/sources.list.d/mozilla.sources"
    local MOZILLA_KEYRING="/etc/apt/keyrings/packages.mozilla.org.asc"

    if [ -f "$MOZILLA_SOURCE_FILE" ] && \
       grep -q "packages.mozilla.org" "$MOZILLA_SOURCE_FILE"; then
        show_info_message "Mozilla repository already configured. Skipping setup."
        return 0
    fi

    show_title_message "Configuring official Mozilla APT repository..."

    # Ensure keyring directory exists with correct permissions
    sudo install -d -m 0755 /etc/apt/keyrings

    # Download the official Mozilla signing key
    wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg \
        | sudo tee "$MOZILLA_KEYRING" > /dev/null

    # Configure the DEB822 source file for Mozilla packages
    sudo tee "$MOZILLA_SOURCE_FILE" > /dev/null <<EOF
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: $MOZILLA_KEYRING
EOF

    # Configure APT pinning for Mozilla packages
    sudo tee /etc/apt/preferences.d/mozilla > /dev/null <<EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

    sudo apt update
}

disable_kdeconnect(){
    show_title_message "Disabling KDE Connect autostart..."
    # Not best practice, but KDE Connect doesn't have a simple way to disable autostart without removing the package
    sudo purge kdeconnect -y
}

show_reboot_countdown(){
    seconds=$1
    while [ $seconds -gt 0 ]; do
        echo -en "${COLOR_YELLOW}System will reboot in $seconds seconds...${COLOR_RESET}\r"
        sleep 1
        : $((seconds--))
    done
    echo -e "\n"
}

script_setup_colors() {
    COLOR_BLUE='\033[0;34m'
    COLOR_GREEN='\033[0;32m'
    COLOR_RED='\033[0;31m'
    COLOR_RESET='\033[0m'
    COLOR_YELLOW='\033[0;33m'
}

script_setup() {
    script_setup_colors
}

## Main
main() {
    script_setup
    show_credits
    pre_install

    ###############################
    ## Read vars
    ###############################
    show_title_message "Options Selection"

    de_options=("KDE Plasma" "GNOME")
    
    echo "Desktop Environments available to install: "
    for i in "${!de_options[@]}"; do
        echo "$((i+1))) ${de_options[$i]}"
    done
    
    read -p "Choose one option: " de_option
    
    if ! [[ "$de_option" =~ ^[1-2]$ ]]; then
        show_warning_message "Invalid option. Defaulting to KDE Plasma..."
        de_option=1
    fi

    chosen_de="${de_options[$((de_option-1))]}"
    read -p "Reboot after install? (Default: no) [y/n]: " reboot_option

    ###############################
    ## Repositories & Third Party
    ###############################
    enable_vscode_repo
    enable_flathub

    ###############################
    ## Desktop Environment
    ###############################

    show_info_message "\nInstalling $chosen_de desktop environment and applications..."
    case $de_option in
        1) 
            # KDE Plasma
            desktop_environment=(
                plasma-desktop
                plasma-workspace
                plasma-nm
                plasma-pa
                plasma-widgets-addons
                sddm
                sddm-theme-breeze
            )

            applications=(
                ark
                bluedevil
                dolphin
                gwenview
                kcalc
                kde-config-gtk-style
                kde-spectacle
                kinfocenter
                kolourpaint
                konsole
                kscreen
                kwalletmanager
                kwrite
                okular
                partitionmanager
                systemsettings
            )
            ;;
        2)
            # GNOME
            desktop_environment=(
                gnome-shell
                gdm3
                gnome-session
            )

            applications=(
                file-roller
                gnome-calculator
                gnome-characters
                gnome-clocks
                gnome-contacts
                gnome-disk-utility
                gnome-extensions-app
                gnome-font-viewer
                gnome-maps
                gnome-music
                gnome-system-monitor
                gnome-terminal
                gnome-text-editor
                gnome-tweaks
                gnome-weather
                loupe
                nautilus
                network-manager-gnome
                papers
                showtime
            )
            ;;
    esac

    ###############################
    ## General Packages
    ###############################
    general_packages=(
        build-essential
        curl
        git
        libreoffice-calc
        libreoffice-impress
        libreoffice-l10n-pt-br
        libreoffice-writer
        vulkan-tools
        wget
    )

    # Compression packages
    general_packages+=(
        bzip2
        gzip
        7zip
        tar
        unzip
        xz-utils
        zip
        zstd
    )

    show_title_message "Applying $chosen_de pre configurations..."
    case $de_option in
        1) 
            # KDE Plasma specific packages
            general_packages+=(
                vlc
            )
            ;;
        2)
            # GNOME specific packages
            general_packages+=(
                celluloid
                libreoffice-gtk3
            )
            ;;
    esac

    # Firmware and graphics packages
    general_packages+=(
        firmware-linux
        firmware-linux-nonfree
        firmware-amd-graphics
        mesa-libgallium
        mesa-vulkan-drivers
        vulkan-tools
    )

    # Keep for 32-bit compatibility documentation
    # 32-bit compatibility libraries (Requires: dpkg --add-architecture i386)
    general_packages_i386=(
        libgl1-mesa-dri:i386
        libstdc++6:i386
        libc6:i386
        mesa-vulkan-drivers:i386
        zlib1g:i386
    )

    dev_packages=(
        code
    )

    # Flatpak packages
    flatpak_packages=(
        org.mozilla.firefox
    )

    # Themes packages
    themes_packages=(
        bibata-cursor-theme
        papirus-icon-theme
    )

    ###############################
    ## Package Installation
    ###############################
    enable_debian_repos
    refresh_packages
    show_title_message "Installing selected packages..."
    sudo apt install -y "${desktop_environment[@]}" "${applications[@]}" "${general_packages[@]}" "${dev_packages[@]}" "${themes_packages[@]}"
    if [ ${#flatpak_packages[@]} -gt 0 ]; then
        flatpak install -y flathub "${flatpak_packages[@]}"
    else
        show_info_message "No Flatpak applications to install. Skipping..."
    fi

    ###############################
    ## Last Configurations
    ###############################
    enable_zram
    enable_splashscreen

    show_title_message "Applying $chosen_de post configurations..."
    case $de_option in
        1) 
            enable_sddm
            enable_networkmanager_kde
            disable_kdeconnect
            ;;
        2)
            enable_gdm
            enable_networkmanager_gnome
            enable_gnome_extensions
            ;;
    esac

    show_title_message_success "Script finished!"

    if [[ ! $reboot_option ]] || [[ $reboot_option != 'y' ]]; then
        show_warning_message "Reboot skipped. Please reboot your system later."
    else
        reboot_timeout=5
        show_reboot_countdown $reboot_timeout
        sudo reboot
    fi
}

main