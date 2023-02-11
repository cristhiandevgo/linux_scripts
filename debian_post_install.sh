#!/bin/bash
# Post Instalation for Debian with minimal packages options
# Author: Ivan Cristhian (Call me Cristhian)
# GitHub: cristhiandevgo
# Mail: ivancristhian@hotmail.com
# Site: https://ivan-cristhian.web.app
# All rights reserved

echo '
 _____________________________________________________________________
   ___                     ____      _     _   _     _             
  |_ _|_   ____ _ _ __    / ___|_ __(_)___| |_| |__ (_) __ _ _ __  
   | |\ \ / / _` |  _ \  | |   |  __| / __| __|  _ \| |/ _` |  _ \ 
   | | \ V / (_| | | | | | |___| |  | \__ \ |_| | | | | (_| | | | |
  |___| \_/ \__,_|_| |_|  \____|_|  |_|___/\__|_| |_|_|\__,_|_| |_|
 _____________________________________________________________________



                    Post Install Debian Script



'

###############################
## Functions
###############################

pre_install(){
	sudo apt-get install wget gpg curl -y
}

refresh_packages(){
	sudo apt-get update && sudo apt-get upgrade -y
}

## End Functions

# Install Script Dependencies
pre_install

###############################
## Config packages
###############################

# Add contrib and non-free to sources.list
sudo cp "/etc/apt/sources.list" "/etc/apt/sources.list_backup_$(date)"

sudo sed -i "s/.*deb http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" /etc/apt/sources.list
sudo sed -i "s/.*deb-src http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb-src http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" /etc/apt/sources.list

sudo sed -i "s/.*deb http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" /etc/apt/sources.list
sudo sed -i "s/.*deb-src http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb-src http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" /etc/apt/sources.list

# Update Packages
refresh_packages

## End Config packages

###############################
## Read vars
###############################
read -p '
Choose your Desktop Environment (Default: KDE Plasma):

1 KDE Plasma
2 Gnome
3 Mate
4 XFCE
5 Cinnamon
' de_option

# Browser
source browser.sh
echo "
Choose wich browser(s) do you want to install (Default: none)
"

browser_setup "Vivaldi" "Debian"
browser_setup "Chromium" "Debian"
browser_setup "Mozilla Firefox (tar.bz2)" "Debian"

read -p "
Install all drivers? (Default: no) [y/n]: " drivers_option

read -p "
Reboot after install? (Default: no) [y/n]: " reboot_option

## End Read vars

###############################
## Desktop Environment
###############################

if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -ge 6 ]
then
    # KDE Plasma
    desktop_environment+=(
        kde-plasma-desktop
        kde-spectacle
        ark
        gwenview
        kamoso
        kate
        kcalc
        kget
        kolourpaint
        kompare
        libreoffice-plasma
        okular
        plasma-wallpapers-addons
        plasma-wayland-protocols
        plasma-widgets-addons
        plasma-workspace-wayland
        qbittorrent
    )

    themes+=(
        sddm-theme-breeze
        sddm-theme-debian-breeze
    )
elif [ $de_option -eq 2 ]
then
    # Gnome
    desktop_environment+=(
        gnome-session
        eog
        evince
        gnome-disk-utility
        gnome-calculator
        gnome-calendar
        gnome-contacts
        fonts-cantarell
        gnome-maps
        gnome-music
        gnome-photos
        gnome-shell-extensions
        gnome-software
        gnome-system-monitor 
        gnome-terminal
        gnome-text-editor
        gnome-tweaks
        gnome-weather
        libreoffice-gnome
        nautilus
        simple-scan
    )

    themes+=(
    )
elif [ $de_option -eq 3 ]
then
    # Mate
    desktop_environment+=(
        mate-desktop-environment
        mate-desktop-environment-extras
        libreoffice-gtk3
        lightdm
        network-manager-gnome
        synaptic
    )

    themes+=(
    )
elif [ $de_option -eq 4 ]
then
     # XFCE
    desktop_environment+=(
        xfce4
        xfce4-goodies
        libreoffice-gtk3
        menulibre
        synaptic
        thunderbird
    )

    themes+=(
    )
elif [ $de_option -eq 5 ]
then
     # Cinnamon
    desktop_environment+=(
        cinnamon
        blueman
        brasero
        cheese
        cups
        deja-dup
        eog
        evince
        gdebi
        gedit
        gnome-font-viewer
        gnome-screenshot
        gnome-software
        gnome-system-monitor
        gnome-terminal
        gnome-user-share
        gnote
        gdebi
        libreoffice-gnome
        mate-calc
        simple-scan
        synaptic
        sound-juicer
        thunderbird
    )

    themes+=(
        arc-theme
        mate-themes
        papirus-icon-theme
    )
fi
## End Desktop Environment

###############################
## Common packages
###############################
common_packages+=(
    curl
    firmware-linux-free
    fonts-liberation
    fonts-noto
    gnome-keyring
    g++
    gimp
    git
    inkscape
    libdbus-glib-1-2
    libreoffice
    libreoffice-l10n-pt-br
    vlc
    wget
)
## End Common packages

###############################
## Drivers
###############################

# Initialize drivers var
drivers=()

# All drivers Option (Default no)
if [[ ! $drivers_option ]] || [[ $drivers_option != 'y' ]]
then
    drivers_option="n"
else
    drivers+=(
        firmware-*
    )
fi

## End Drivers

###############################
## Dev Tools
###############################

# Nodejs - LTS
source node_lts_install.sh

# Visual Studio Code - vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

dev_packages+=(
    code
)

# End Dev Tools

###############################
## sudo install packages
###############################
refresh_packages
sudo apt-get install ${desktop_environment[@]} ${common_packages[@]} ${themes[@]} ${browser[@]} ${drivers[@]} ${dev_packages[@]} -y

###############################
## Last Configurations
###############################

# Network Manager: Enabling Interface Management
# DEs: KDE, Gnome, Cinnamon
if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -eq 2 ] || [ $de_option -ge 6 ] || [ $de_option -eq 5 ]
then
    sudo cp /etc/NetworkManager/NetworkManager.conf "/etc/NetworkManager/NetworkManager.conf_backup_$(date)"
    sudo sed -i "s/managed=false/managed=true/g" /etc/NetworkManager/NetworkManager.conf
fi

# User dir folders
# Info: Latest versions of Debian (KDE Plasma) are not automatically generating the Home user folders. So, let's force this task for now.
if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -ge 6 ]
then
    xdg-user-dirs-update --force
fi

# Cinnamon Themes
if [ $de_option -eq 5 ]
then
    gsettings set org.cinnamon.theme name "Arc"
    gsettings set org.cinnamon.desktop.interface gtk-theme "Arc"
    gsettings set org.cinnamon.desktop.wm.preferences theme "Arc"
    gsettings set org.cinnamon.desktop.interface icon-theme "Papirus"
    gsettings set org.cinnamon.desktop.interface cursor-theme "mate"
fi


echo '



Finished!

'

# Reboot Option (Default no)
if [[ ! $reboot_option ]] || [[ $reboot_option != 'y' ]]
then
    reboot_option="n"
else
    sudo reboot
fi
