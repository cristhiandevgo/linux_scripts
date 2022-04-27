# Post Instalation for Debian with KDE Plasma
# Autor: cristhiandevgo

## Add contrib and non-free to sources.list
sudo cp "/etc/apt/sources.list" "/etc/apt/sources.list_backup_$(date)"

sed -i "s/.*deb http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" src.txt
sed -i "s/.*deb-src http:\/\/deb.debian.org\/debian\/ bookworm main.*/deb-src http:\/\/deb.debian.org\/debian\/ bookworm main contrib non-free/g" src.txt

sed -i "s/.*deb http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" src.txt
sed -i "s/.*deb-src http:\/\/security.debian.org\/debian-security bookworm-security main.*/deb-src http:\/\/security.debian.org\/debian-security bookworm-security main contrib non-free/g" src.txt

## Check updates
sudo apt-get update && sudo apt-get upgrade -y

## apt - Plasma DE and Softwares
sudo apt-get install kde-plasma-desktop ark kate kcalc kde-spectacle okular gwenview kompare qbittorrent fonts-liberation firefox-esr libreoffice libreoffice-l10n-pt-br libreoffice-plasma vlc curl libdbus-glib-1-2 plasma-widgets-addons isenkram-cli -y

## Configs
# Network Manager: Enabling Interface Management
sudo cp /etc/NetworkManager/NetworkManager.conf "/etc/NetworkManager/NetworkManager.conf_backup_$(date)"
sudo sed -i "s/managed=false/managed=true/g" /etc/NetworkManager/NetworkManager.conf

# Search Drivers
sudo isenkram-autoinstall-firmware

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

echo "\n\nFinished!\nReboot your system!\n\n"