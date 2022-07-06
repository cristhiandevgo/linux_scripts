# Drivers
read -p '
Search for extra drivers? (Default: No)

1 Yes
2 No
' drivers_option

driver=()

# None
if [ ! $drivers_option ] || [ $drivers_option -eq 0 ] || [ $drivers_option -ge 3 ]
then
    drivers_option=0
fi

if [ $drivers_option -eq 1 ]
then
    driver=(
        isenkram-cli
    )
fi

sudo apt-get install ${driver[@]}

if [ $drivers_option -eq 1 ]
then
    # Search Drivers
    echo "Searching for drivers..."
    sudo isenkram-autoinstall-firmware
fi

