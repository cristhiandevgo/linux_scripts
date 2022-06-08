#!/bin/bash
# Post Instalation for Debian with minimal option
# Author: Ivan Cristhian (Call me Cristhian)
# GitHub: cristhiandevgo
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

##############################
## Add contrib and non-free to sources.list
###############################
sudo cp "/etc/apt/sources.list" "/etc/apt/sources.list_backup_$(date)"

sudo sed -i "s/.*deb http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" /etc/apt/sources.list
sudo sed -i "s/.*deb-src http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb-src http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" /etc/apt/sources.list

sudo sed -i "s/.*deb http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" /etc/apt/sources.list
sudo sed -i "s/.*deb-src http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb-src http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" /etc/apt/sources.list

###############################
## Check updates
###############################
sudo apt-get update && sudo apt-get upgrade -y

###############################
## Read vars
###############################
read -p '
Choose your Desktop Enviroment (Default: KDE Plasma):

1 KDE Plasma
2 Gnome
3 Mate
4 XFCE
5 Cinnamon
' de_option

read -p '
Choose the browser(s) to install (Default: None):

1 Mozilla Firefox
2 Chromium
3 Both
4 None
' browser_option

read -p '
Search for extra drivers? (Default: No):

1 Yes
2 No
' drivers_option

read -p '
Reboot after install? (Default: Yes):

1 Yes
2 No
' reboot_option

## End Read vars

###############################
## Desktop Enviroment
###############################

if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -ge 6 ]
then
    # KDE Plasma
    desktop_enviroment=(
        kde-plasma-desktop
        kde-spectacle
        ark
        gwenview
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

    themes=(
    )
elif [ $de_option -eq 2 ]
then
    # Gnome
    desktop_enviroment=(
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

    themes=(
    )
elif [ $de_option -eq 3 ]
then
    # Mate
    desktop_enviroment=(
        mate-desktop-environment
        mate-desktop-environment-extras
        libreoffice-gtk3
        lightdm
        network-manager-gnome
        synaptic
    )

    themes=(
    )
elif [ $de_option -eq 4 ]
then
     # XFCE
    desktop_enviroment=(
        xfce4
        xfce4-goodies
        libreoffice-gtk3
        menulibre
        synaptic
        thunderbird
    )

    themes=(
    )
elif [ $de_option -eq 5 ]
then
     # Cinnamon
    desktop_enviroment=(
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

    themes=(
        arc-theme
        mate-themes
        papirus-icon-theme
    )
fi
## End Desktop Enviroment

###############################
## Common packages
###############################
common_packages=(
    curl
    firmware-linux
    firmware-linux-free
    firmware-linux-nonfree
    fonts-liberation
    fonts-noto
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
## Browser
###############################

# Initialize browser var
browser=()

firefox(){
    ## Mozilla Firefox
    # Install Firefox from Mozilla builds
    cd /tmp/
    wget 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=pt-BR' -O firefox.tar.bz2
    tar -xjf firefox.tar.bz2
    sudo mv -f firefox /opt/

    mkdir -p $HOME/.local/share/applications/

    echo -e '[Desktop Entry]
    Version=1.0
    Name=Firefox Web Browser
    Comment=Browse the World Wide Web
    Exec=/opt/firefox/firefox %u
    GenericName=Web Browser
    Icon=/opt/firefox/browser/chrome/icons/default/default128.png
    MimeType=
    Name=Firefox Web Browser
    NoDisplay=false
    Path=
    StartupNotify=true
    Terminal=false
    TerminalOptions=
    Type=Application
    X-DBUS-ServiceName=
    X-DBUS-StartupType=
    X-KDE-SubstituteUID=false
    X-KDE-Username=
    Categories=GNOME;GTK;Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;' > $HOME/.local/share/applications/Firefox.desktop
}

# None
if [ ! $browser_option ] || [ $browser_option -eq 0 ] || [ $browser_option -eq 4 ] || [ $browser_option -ge 5 ]
then
    browser_option=0
fi

# Mozilla Firefox
if [ $browser_option -eq 1 ] || [ $browser_option -eq 3 ]
then
    firefox
fi

# Chromium
if [ $browser_option -eq 2 ] || [ $browser_option -eq 3 ]
then
    browser=(
        chromium
        chromium-l10n
    )
fi

## End browser

###############################
## Drivers
###############################

# Initialize drivers var
drivers=()

# None
if [ ! $drivers_option ] || [ $drivers_option -eq 0 ] || [ $drivers_option -ge 3 ]
then
    drivers_option=0
fi

if [ $drivers_option -eq 1 ]
then
    drivers=(
        isenkram-cli
    )
fi

## End Drivers

###############################
## sudo install packages
###############################
sudo apt-get install ${desktop_enviroment[@]} ${common_packages[@]} ${themes[@]} ${browser[@]} ${drivers[@]} -y

###############################
## Nodejs - LTS
###############################
cp "$HOME/.bashrc" "$HOME/.bashrc_backup_$(date)"
cp "$HOME/.profile" "$HOME/.profile_backup_$(date)"
mkdir $HOME/.node
curl https://nodejs.org/dist/v16.15.0/node-v16.15.0-linux-x64.tar.xz --output node-v16.15.0-linux-x64.tar.xz
tar -xf node-v16.15.0-linux-x64.tar.xz -C $HOME/.node/

echo -n '
# Node
export NODEJS_HOME=$HOME/.node/node-v16.15.0-linux-x64/bin
export PATH=$NODEJS_HOME:$PATH
' | tee -a ~/.profile ~/.bashrc

. ~/.profile ~/.bashrc
## End Node - LTS

###############################
## Last Configurations
###############################

# Search Drivers
if [ $drivers_option -eq 1 ]
then
    sudo isenkram-autoinstall-firmware
fi

# Network Manager: Enabling Interface Management
# DEs: KDE, Gnome, Cinnamon
if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -eq 2 ] || [ $de_option -ge 6 ] || [ $de_option -eq 5 ]
then
    sudo cp /etc/NetworkManager/NetworkManager.conf "/etc/NetworkManager/NetworkManager.conf_backup_$(date)"
    sudo sed -i "s/managed=false/managed=true/g" /etc/NetworkManager/NetworkManager.conf
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

# Reboot Option
if [ ! $reboot_option ] || [ $reboot_option -eq 0 ] || [ $reboot_option -eq 1 ] || [ $reboot_option -ge 3 ]
then
    sudo reboot
fi