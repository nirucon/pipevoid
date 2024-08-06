#!/bin/bash

# WORK IN PROGRESS!!! //Nicklas Rudolfsson
# sudo xbps-install pipewire pipewire-devel alsa-pipewire wireplumber
# sudo mkdir /etc/alfa/conf.d
# sudo ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alfa/conf.d
# sudo ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alfa/conf.d
# cd /etc/pulse
# sudo -e client.conf
# uncomment the line with: autospawn = no (if yes, change to no and save the file)
# insert lines in ~/.xinitrc or ~/.dwmo/autoshart.sh
# pipewire &
# pipewire pluse &
# wireplumber
# reboot the system and check pactl info

# Function to print in color
print_color() {
    echo -e "\033[$1m$2\033[0m"
}

# Check if figlet is installed
if command -v figlet &> /dev/null; then
    figlet pipevoid
else
    echo "---------------------------"
    echo "       pipevoid            "
    echo "---------------------------"
fi

print_color "1;32" "Welcome to the pipevoid!"
print_color "1;34" "A script that helps you install and enable PipeWire for you to enjoy some nice music and sound without hassle."

# Confirm installation
read -p "Do you want to start the installer? (Y/n) " -r response
response=${response,,} # convert to lowercase
if [[ ! $response =~ ^(yes|y| ) ]] && [[ -n $response ]]; then
    print_color "1;31" "Goodbye!"
    exit 0
fi

print_color "1;33" "Starting the installation..."

# Update the system and install PipeWire and Bluetooth support
print_color "1;34" "Updating the system and installing PipeWire..."
sudo xbps-install -Syu
sudo xbps-install -S pipewire libspa-bluetooth

# Enable PipeWire and PipeWire Pulse services
print_color "1;34" "Enabling PipeWire services..."
sudo ln -s /etc/sv/pipewire /var/service/
sudo ln -s /etc/sv/pipewire-pulse /var/service/

# Check and create necessary groups
print_color "1;34" "Checking and creating necessary groups..."
if ! getent group pulse > /dev/null; then
    sudo groupadd pulse
    print_color "1;32" "Created 'pulse' group."
fi
if ! getent group pulse-access > /dev/null; then
    sudo groupadd pulse-access
    print_color "1;32" "Created 'pulse-access' group."
fi

# Add user to necessary groups
print_color "1;34" "Adding user to PipeWire and Pulse groups..."
sudo usermod -aG _pipewire,pulse,pulse-access $USER

print_color "1;32" "Installation complete. Please log out and log back in to apply the group changes."

# Prompt for logout
read -p "Do you want to log out now? (Y/n) " -r logout_response
logout_response=${logout_response,,} # convert to lowercase
if [[ $logout_response =~ ^(yes|y| ) ]] || [[ -z $logout_response ]]; then
    print_color "1;33" "Logging out..."
    gnome-session-quit --logout --no-prompt || kill -9 -1
else
    print_color "1;31" "Remember to log out and log back in to activate PipeWire. Bye!"
    exit 0
fi
