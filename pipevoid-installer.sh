#!/bin/bash

# pipevoid - PipeWire install script for Void Linux by Nicklas Rudolfsson

# Function to prompt the user for reboot
prompt_reboot() {
    read -r -p "It's recommended to reboot your system, do you want to do it now? Y/n: " response
    case "$response" in
        [Yy]* | "" )
            echo "Rebooting system..."
            sudo reboot
            ;;
        [Nn]* )
            echo "Please remember to reboot your system later to apply changes."
            ;;
        * )
            echo "Invalid input. Please enter Y or n."
            prompt_reboot
            ;;
    esac
}

# Function to set up PipeWire cleanup service with runit
setup_pipewire_cleanup_service() {
    echo "Setting up PipeWire cleanup service..."

    # Create the cleanup script
    sudo mkdir -p /etc/sv/pipewire-cleanup
    echo '#!/bin/sh
rm -f /run/user/1000/*.lock
' | sudo tee /etc/sv/pipewire-cleanup/run > /dev/null
    sudo chmod +x /etc/sv/pipewire-cleanup/run

    # Create the log directory and script (optional but recommended)
    sudo mkdir -p /etc/sv/pipewire-cleanup/log
    echo '#!/bin/sh
exec svlogd -tt /var/log/pipewire-cleanup
' | sudo tee /etc/sv/pipewire-cleanup/log/run > /dev/null
    sudo chmod +x /etc/sv/pipewire-cleanup/log/run

    # Enable the service
    sudo ln -s /etc/sv/pipewire-cleanup /var/service/

    echo "PipeWire cleanup service set up successfully."
}

# Check if figlet is installed
if command -v figlet &> /dev/null; then
    figlet pipevoid
else
    echo "---------------------------"
    echo "       pipevoid            "
    echo "---------------------------"
fi

echo "Updating system and installing necessary packages..."
sudo xbps-install -S dumb_runtime_dir pipewire wireplumber pavucontrol qpwgraph

echo "Creating directories and symbolic links for PipeWire and WirePlumber configuration..."
sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

echo "Creating symbolic links for autostarting WirePlumber and PipeWire..."
sudo ln -s /usr/share/applications/wireplumber.desktop /etc/xdg/autostart/
sudo ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/

echo "Checking for existing .xinitrc file and making a backup if it exists..."
if [ -f ~/.xinitrc ]; then
    cp ~/.xinitrc ~/.xinitrc.bak
    echo "Backup of existing .xinitrc created as .xinitrc.bak."
fi

echo "Inserting PipeWire start commands into .xinitrc..."
grep -qxF '# PipeWire start' ~/.xinitrc || echo -e "\n# PipeWire start\npipewire &\npipewire-pulse &\nwireplumber &" >> ~/.xinitrc

# Ensure dbus launch command is at the end of .xinitrc
echo "Appending dbus launch command at the end of .xinitrc..."
grep -qxF '# Void dbus' ~/.xinitrc || echo -e "\n# Void dbus\nexec dbus-launch --sh-syntax --exit-with-session dwm" >> ~/.xinitrc

echo "Installation and configuration completed."

# Set up PipeWire cleanup service
setup_pipewire_cleanup_service

# Prompt the user to reboot
prompt_reboot
