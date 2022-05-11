# Browser
read -p '
Choose the browser(s) to install (Default: None):

1 Mozilla Firefox
2 Chromium
3 Both
4 None
' browser_option

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

sudo apt-get install ${browser[@]}