#!/bin/bash

###############################
## Functions
###############################

show_credits() {
    echo -e '
    \e[32m
        ___
       |_ _|_    ____ _ _ __
        | |\ \ / / _` |  _ \
        | | \ V / (_| | | | |
       |___| \_/ \__,_|_| |_|

      Distribution: openSUSE Tumbleweed
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

enable_opensuse_repos(){
    show_title_message "Configuring Packman codecs and refreshing repositories..."

    # Install OPI (openSUSE Package Installer) to safely fetch codecs
    sudo zypper install -y opi
    
    # Automatically accept and switch system packages to Packman vendor
    opi packman
}

pre_install(){
    show_title_message "Installing script dependencies..."
    sudo zypper install -y wget gpg2 curl
}

refresh_packages(){
    show_title_message "Refreshing package metadata and updating packages..."
    # 'zypper dup' is the official and correct way to upgrade openSUSE Tumbleweed
    sudo zypper refresh && sudo zypper dup -y
}

enable_vscode_repo(){
    show_title_message "Enabling Visual Studio Code repository..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
}

enable_flathub(){
    show_title_message "Enabling Flatpak..."
    sudo zypper install -y flatpak
    
    if [ "$de_option" -eq 1 ]; then
        sudo zypper install -y discover-backend-flatpak
    else
        sudo zypper install -y gnome-software-plugin-flatpak
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
    sudo systemctl enable gdm
}

enable_splashscreen() {
    show_title_message "Enabling Splash Screen..."
    sudo zypper install -y plymouth plymouth-dracut plymouth-branding-openSUSE
    
    show_message "Rebuilding initramfs with dracut..."
    # openSUSE uses dracut instead of initramfs-tools
    sudo dracut -f --regenerate-all
}

enable_zram() {
    show_title_message "Installing and configuring zRAM (True Fedora-style)..."
    
    # Install the official system generator
    sudo zypper install -y systemd-zram-generator
    
    # Create the native configuration file
    # Use 'zram-size = ram' for 100% or 'zram-size = ram / 2' for 50%
    sudo mkdir -p /etc/systemd
    sudo tee /etc/systemd/zram-generator.conf > /dev/null <<EOF
[zram0]
zram-size = ram
compression-algorithm = zstd
EOF
    
    # Reload systemd to activate the device immediately without a reboot
    sudo systemctl daemon-reload
    sudo systemctl start /dev/zram0
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
    
    # Initialize repositories first to ensure connectivity
    enable_opensuse_repos
    pre_install

    ###############################
    ## Read vars
    ###############################
    show_title_message "Options Selection"

    de_options=("KDE Plasma [STABLE]" "GNOME [BETA]")
    
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
            # KDE Plasma Minimal (Patterns + Core elements)
            desktop_environment=(
                patterns-kde-kde_plasma
                plasma-nm
                plasma-pa
                plasma5-addons
                sddm
                breeze5-style
            )

            applications=(
                ark
                bluedevil
                dolphin
                gwenview
                kcalc
                kde-gtk-config
                kinfocenter
                kolourpaint
                konsole
                kscreen
                kwalletmanager
                kate
                okular
                plasma5-pk-updates
                spectacle
                systemsettings
            )
            ;;
        2)
            # GNOME Minimal Setup
            desktop_environment=(
                patterns-gnome-gnome_basic
                gdm
                gnome-session
            )

            applications=(
                eog
                evince
                file-roller
                gedit
                gnome-calculator
                gnome-characters
                gnome-clocks
                gnome-contacts
                gnome-disk-utility
                gnome-font-viewer
                gnome-maps
                gnome-music
                gnome-screenshot
                gnome-system-monitor
                gnome-terminal
                gnome-tweaks
                gnome-weather
                nautilus
                totem
            )
            ;;
    esac

    ###############################
    ## General Packages
    ###############################
    general_packages=(
        curl
        git
        vlc
        vulkan-tools
        wget
    )

    # Office Suite
    general_packages+=(
        libreoffice
        libreoffice-l10n-pt
    )

    # Compression packages
    general_packages+=(
        bzip2
        gzip
        p7zip
        tar
        unzip
        xz
        zip
    )

    # Firmware and graphics packages (AMD RX 6600)
    general_packages+=(
        kernel-firmware-all
        kernel-firmware-amdgpu
        Mesa-va-drivers
        libva-vdpau-driver
        libvulkan_radeon
    )

    # 32-bit compatibility libraries (openSUSE native gaming runtime)
    general_packages+=(
        Mesa-dri-32bit
        libstdc++6-32bit
        glibc-32bit
        libvulkan_radeon-32bit
        libz1-32bit
    )

    dev_packages=(
        code
    )

    # Flatpak packages
    flatpak_packages=(
        org.mozilla.firefox
    )

    ###############################
    ## Package Installation
    ###############################
    refresh_packages
    show_title_message "Installing selected packages..."
    
    sudo zypper install -y --no-recommends \
        "${desktop_environment[@]}" \
        "${applications[@]}" \
        "${general_packages[@]}" \
        "${dev_packages[@]}"
        
    flatpak install -y flathub "${flatpak_packages[@]}"

    ###############################
    ## Last Configurations
    ###############################
    enable_splashscreen
    enable_zram

    show_title_message "Applying $chosen_de post configurations..."
    case $de_option in
        1) 
            enable_sddm
            ;;
        2)
            enable_gdm
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