# Nodejs - LTS
cd ~/Downloads
cp ~/.bashrc ~/.bashrc_backup_$RANDOM
cp ~/.profile ~/.profile_backup_$RANDOM
curl https://nodejs.org/dist/v16.14.2/node-v16.14.2-linux-x64.tar.xz --output node-v16.14.2-linux-x64.tar.xz
sudo tar -xf node-v16.14.2-linux-x64.tar.xz -C /opt

echo -n '
#Node
export NODEJS_HOME=/opt/node-v16.14.2-linux-x64/bin
export PATH=$NODEJS_HOME:$PATH
' | tee -a ~/.profile ~/.bashrc

. ~/.profile ~/.bashrc