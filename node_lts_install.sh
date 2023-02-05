# Nodejs - LTS - v18.14.0
cp "$HOME/.bashrc" "$HOME/.bashrc_backup_$(date)"
cp "$HOME/.profile" "$HOME/.profile_backup_$(date)"
mkdir $HOME/.node
curl https://nodejs.org/dist/v18.14.0/node-v18.14.0-linux-x64.tar.xz --output node-v18.14.0-linux-x64.tar.xz
tar -xf node-v18.14.0-linux-x64.tar.xz -C $HOME/.node/

echo -n '
# Node
export NODEJS_HOME=$HOME/.node/node-v18.14.0-linux-x64/bin
export PATH=$NODEJS_HOME:$PATH
' | tee -a ~/.profile ~/.bashrc

. ~/.profile ~/.bashrc
## End Node - LTS
