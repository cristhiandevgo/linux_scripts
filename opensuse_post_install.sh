#!/bin/bash
# Post Instalation for OpenSuse with minimal packages options
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



                    Post Install OpenSuse Script



'

###############################
## Functions
###############################

pre_install(){
    sudo zypper install -y wget curl gpg2
}

refresh_packages(){
    sudo zypper refresh && sudo zypper update -y
}

## End Functions

# Install Script Dependencies
pre_install

###############################
## Add opi codecs
###############################
sudo zypper install -y opi
opi packman

###############################
## Check updates
###############################
refresh_packages

###############################
## Read vars
###############################

# Desktop Environment
read -p "
Choose your Desktop Environment (Default: KDE Plasma):

1 KDE Plasma
2 Gnome
3 Mate
4 XFCE
5 Cinnamon
" de_option

# Browser
source browser.sh
echo "
Choose wich browser(s) do you want to install (Default: none)
"

browser_setup "Vivaldi" "OpenSuse"
browser_setup "Chromium" "OpenSuse"
browser_setup "Mozilla Firefox (tar.bz2)" "OpenSuse"

read -p "
Reboot after install? (Default: no) [y/n]: " reboot_option

## End Read vars

###############################
## Desktop Environment
###############################

if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -ge 6 ]
then
    # KDE Plasma
    desktop_environment=(
		patterns-kde-kde_plasma
		dolphin
		ark
		discover
		gwenview5
        kamoso
		kate
		kcalc
		kget
		kolourpaint
		konsole
		kompare
		libreoffice-qt5
		okular
		qbittorrent
		spectacle
	)

    themes=(
    )
elif [ $de_option -eq 2 ]
then
    # Gnome
    desktop_environment=(
    )

    themes=(
    )
elif [ $de_option -eq 3 ]
then
    # Mate
    desktop_environment=(
    )

    themes=(
    )
elif [ $de_option -eq 4 ]
then
     # XFCE
    desktop_environment=(
    )

    themes=(
    )
elif [ $de_option -eq 5 ]
then
     # Cinnamon
    desktop_environment=(
    )

    themes=(
    )
fi
## End Desktop Environment

###############################
## Common packages
###############################
common_packages=(
    curl
    kernel-firmware-all
    liberation-fonts
    noto-sans-fonts
    gnome-keyring
    gcc-c++
    gimp
    git
    inkscape
    dbus-1-glib
    libreoffice
    libreoffice-l10n-pt_BR
    vlc
    wget
)
## End Common packages

###############################
## Dev Tools
###############################

# Nodejs - LTS
source node_lts_install.sh

# Visual Studio Code - vscode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
refresh_packages

dev_packages+=(
    code
)

## End Dev Tools

###############################
## sudo install packages
###############################
sudo zypper install -y ${desktop_environment[@]} ${common_packages[@]} ${themes[@]} ${browser[@]} ${dev_packages[@]}

###############################
## Last Configurations
###############################

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