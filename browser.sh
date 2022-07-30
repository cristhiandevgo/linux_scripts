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