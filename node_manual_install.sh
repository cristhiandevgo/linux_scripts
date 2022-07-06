## Nodejs - LTS
cp "$HOME/.bashrc" "$HOME/.bashrc_backup_$(date)"
cp "$HOME/.profile" "$HOME/.profile_backup_$(date)"
mkdir $HOME/.node
curl https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz --output node-v16.15.1-linux-x64.tar.xz
tar -xf node-v16.15.1-linux-x64.tar.xz -C $HOME/.node/

echo -n '
# Node
export NODEJS_HOME=$HOME/.node/node-v16.15.1-linux-x64/bin
export PATH=$NODEJS_HOME:$PATH
' | tee -a ~/.profile ~/.bashrc

. ~/.profile ~/.bashrc
## End Node - LTS