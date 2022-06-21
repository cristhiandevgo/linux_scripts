#!/bin/bash
# Post Instalation for OpenSuse with minimal option
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



                    Post Install OpenSuse Script



'

##############################
## Add opi codecs
###############################
sudo zypper install -y opi
opi packman

###############################
## Check updates
###############################
sudo zypper refresh && sudo zypper update -y

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
Choose extra browser(s) to install (Default: None):

1 Vivaldi
2 Chromium
3 Mozilla Firefox
4 All
5 None
' browser_option

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
        patterns-kde-kde_plasma
        dolphin
        ark
        discover
        gwenview5
        kate
        kcalc
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
    desktop_enviroment=(
        gnome-session
        gnome-disk-utility
        fonts-cantarell
        gnome-maps
        gnome-music
        gnome-photos
        gnome-software
        gnome-terminal
        gnome-text-editor
        gnome-tweaks
        gnome-weather
        libreoffice-gnome
        nautilus
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
    kernel-firmware-all
    liberation-fonts
    noto-sans-fonts
    gcc-c++
    gimp
    git
    inkscape
    libdbus-glib-1-2
    libreoffice
    libreoffice-l10n-pt_BR
    vlc
    wget
)
## End Common packages

###############################
## Browser
###############################

# Initialize browser var
browser=()

firefox_install(){
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

# Default None
if [ ! $browser_option ] || [ $browser_option -eq 0 ] || [ $browser_option -eq 5 ] || [ $browser_option -ge 6 ]
then
    browser_option=0
fi

# Vivaldi
if [ $browser_option -eq 1 ] || [ $browser_option -eq 4 ]
then
    sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
	browser+=(
		vivaldi-stable
	)
fi

# Chromium
if [ $browser_option -eq 2 ] || [ $browser_option -eq 4 ]
then
    browser+=(
        chromium
        chromium-ffmpeg-extra
    )
fi

# Mozilla Firefox
if [ $browser_option -eq 3 ] || [ $browser_option -eq 4 ]
then
    firefox_install
fi

## End browser

###############################
## sudo install packages
###############################
sudo zypper install -y ${desktop_enviroment[@]} ${common_packages[@]} ${themes[@]} ${browser[@]}

###############################
## Dev Tools
###############################

# Nodejs - LTS
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

# Visual Studio Code - vscode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh
sudo zypper install -y code

## End Dev Tools

###############################
## Last Configurations
###############################

# Network Manager: Enabling Interface Management
# DEs: KDE, Cinnamon
#if [ ! $de_option ] || [ $de_option -eq 1 ] || [ $de_option -ge 6 ] || [ $de_option -eq 5 ]
#then
#    sudo cp /etc/NetworkManager/NetworkManager.conf "/etc/NetworkManager/NetworkManager.conf_backup_$(date)"
#    sudo sed -i "s/managed=false/managed=true/g" /etc/NetworkManager/NetworkManager.conf
#fi

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