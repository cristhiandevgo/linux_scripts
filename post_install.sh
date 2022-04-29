#!/bin/bash
# Post Instalation for Debian with minimal option
# Autor: cristhiandevgo

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
## Add contrib and non-free to sources.list
sudo cp "/etc/apt/sources.list" "/etc/apt/sources.list_backup_$(date)"

sudo sed -i "s/.*deb http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" /etc/apt/sources.list
sudo sed -i "s/.*deb-src http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb-src http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" /etc/apt/sources.list

sudo sed -i "s/.*deb http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" /etc/apt/sources.list
sudo sed -i "s/.*deb-src http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb-src http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" /etc/apt/sources.list

## Check updates
sudo apt-get update && sudo apt-get upgrade -y

## Configs
# Configure the packages
read -p '
Choose your Desktop Enviroment (Default: KDE Plasma)
1 KDE Plasma
2 Gnome
3 Mate
4 XFCE
' de_option

if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -ge 6 ]
then
    # KDE Plasma
    desktop_enviroment=(
        kde-plasma-desktop
        kde-spectacle
        ark
        dolphin
        firefox-esr
        fonts-liberation
        gwenview
        kate
        kcalc
        kompare
        ktorrent
        libreoffice-plasma
        okular
        plasma-widgets-addons
    )
elif [ $de_option -eq 2 ]
then
    # Gnome
    desktop_enviroment=(
        gnome-session
    )
elif [ $de_option -eq 3 ]
then
    # Mate
    desktop_enviroment=(
        mate-desktop-environment
        mate-desktop-environment-extras
    )
elif [ $de_option -eq 4 ]
then
     # XFCE
    desktop_enviroment=(
        xfce4
        xfce4-goodies
    )
fi

# Common packages
common_packages=(
    curl
    firmware-linux
    firmware-linux-free
    firmware-linux-nonfree
    gimp
    git
    inkscape
    isenkram-cli
    libdbus-glib-1-2
    libreoffice
    libreoffice-l10n-pt-br
    vlc
)

sudo apt-get install ${desktop_enviroment[@]} ${common_packages[@]}

# Nodejs - LTS
cp "$HOME/.bashrc" "$HOME/.bashrc_backup_$(date)"
cp "$HOME/.profile" "$HOME/.profile_backup_$(date)"
curl https://nodejs.org/dist/v16.14.2/node-v16.14.2-linux-x64.tar.xz --output node-v16.14.2-linux-x64.tar.xz
sudo tar -xf node-v16.14.2-linux-x64.tar.xz -C /opt

echo -n '
#Node
export NODEJS_HOME=/opt/node-v16.14.2-linux-x64/bin
export PATH=$NODEJS_HOME:$PATH
' | tee -a ~/.profile ~/.bashrc

. ~/.profile ~/.bashrc


## Last Configurations
# Search Drivers
sudo isenkram-autoinstall-firmware
# Network Manager: Enabling Interface Management
sudo cp /etc/NetworkManager/NetworkManager.conf "/etc/NetworkManager/NetworkManager.conf_backup_$(date)"
sudo sed -i "s/managed=false/managed=true/g" /etc/NetworkManager/NetworkManager.conf

echo '

Finished!
Reboot Your System!

'