# Post Instalation for Debian with KDE Plasma
# Autor: cristhiandevgo

# Check updates first
sudo apt-get update && sudo apt-get upgrade

# apt - Plasma DE and Softwares
sudo apt-get install kde-plasma-desktop ark kate kcalc kde-spectacle okular gwenview qbittorrent fonts-liberation firefox-esr libreoffice libreoffice-l10n-pt-br libreoffice-plasma vlc curl libdbus-glib-1-2 plasma-widgets-addons nodejs npm

# Configs
# Network Manager: Enabling Interface Management
sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.backup
sudo sed -i "s/managed=false/managed=true/g" /etc/NetworkManager/NetworkManager.conf

echo "\nFinished!\n";