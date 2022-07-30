firefox_install(){
    ## Mozilla Firefox
    # Install Firefox from Mozilla builds
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

browser_setup(){
	read -p "$1? [y/n]: " browser_option
	
	# Default no
	if [[ ! $browser_option ]] || [[ $browser_option != 'y' ]]
	then
		browser_option='n'
	else
		if [[ $1 == "Vivaldi" && $2 == "OpenSuse" ]]
		then
			sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
			browser+=(
				vivaldi-stable
			)
		elif [[ $1 == "Chromium" && $2 == "OpenSuse" ]]
		then
			browser+=(
				chromium
				chromium-ffmpeg-extra
			)
		elif [[ $1 == "Vivaldi" && $2 == "Debian" ]]
		then
            wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
			echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list
			browser+=(
				vivaldi-stable
			)
		elif [[ $1 == "Chromium" && $2 == "Debian" ]]
		then
			browser+=(
				chromium
        		chromium-l10n
			)
		fi
		
		if [[ $1 == "Mozilla Firefox (tar.bz2)" ]]
		then
			firefox_install
		fi
	fi
}