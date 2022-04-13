# Post Instalation for Debian with KDE Plasma
# Autor: cristhiandevgo

# Check updates first
sudo apt-get update && sudo apt-get upgrade

# apt - Plasma DE and Softwares
sudo apt-get install kde-plasma-desktop ark kate kcalc kde-spectacle okular gwenview ktorrent fonts-liberation firefox-esr libreoffice libreoffice-l10n-pt-br libreoffice-plasma vlc curl libdbus-glib-1-2

# Fonts - Emoji
sudo apt install fonts-noto-color-emoji

echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n<fontconfig>\n  <alias>\n    <family>serif</family>\n    <prefer>\n      <family>Noto Color Emoji</family>\n    </prefer>\n  </alias>\n  <alias>\n    <family>sans-serif</family>\n    <prefer>\n      <family>Noto Color Emoji</family>\n    </prefer>\n  </alias>\n  <alias>\n    <family>monospace</family>\n    <prefer>\n      <family>Noto Color Emoji</family>\n    </prefer>\n  </alias>\n</fontconfig>' > /home/"$USER"/.config/fontconfig/fonts.conf

sudo fc-cache -f

# Nodejs - LTS
cd ~/Downloads
sudo cp ~/.profile ~/.profile_backup
sudo cp ~/.bashrc ~/.bashrc_backup
curl https://nodejs.org/dist/v16.14.2/node-v16.14.2-linux-x64.tar.xz --output node-v16.14.2-linux-x64.tar.xz
sudo tar -xf node-v16.14.2-linux-x64.tar.xz -C /opt

echo -n '
#Node
export NODEJS_HOME=/opt/node-v16.14.2-linux-x64/bin
export PATH=$NODEJS_HOME:$PATH
' | tee -a ~/.profile ~/.bashrc

. ~/.profile ~/.bashrc


echo "\nFinished!\n";