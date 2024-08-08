#!/bin/bash

# Function to print messages
print_message() {
  echo "========================================"
  echo "$1"
  echo "========================================"
}

# Update the system and install necessary packages
print_message "Updating the system and installing necessary packages"
sudo xbps-install -Syu
sudo xbps-install -Sy pipewire alsa-utils alsa-plugins alsa-firmware alsa-pipewire pipewire-pulse wireplumber pavucontrol volumeicon

# Enable pipewire services
print_message "Enabling Pipewire and WirePlumber services"
sudo ln -s /etc/sv/pipewire /var/service/
sudo ln -s /etc/sv/wireplumber /var/service/

# Configure ALSA to use Pipewire
print_message "Configuring ALSA to use Pipewire"
sudo mkdir -p /etc/alsa/conf.d
sudo bash -c 'cat <<EOF > /etc/alsa/conf.d/99-pipewire-default.conf
pcm.!default {
    type plug
    slave.pcm {
        type pipewire
    }
}

ctl.!default {
    type pipewire
}
EOF'

# Reload ALSA
print_message "Reloading ALSA"
sudo alsa force-reload

# Add instructions for starting services and enabling audio on login
print_message "Adding instructions for starting services on login"
sudo bash -c 'cat <<EOF >> /etc/profile
# Start pipewire and wireplumber
if [ -z "\$DISPLAY" ] && [ \$(tty) = /dev/tty1 ]; then
    exec startx
fi
EOF'

# Set up runit services for Pipewire
print_message "Setting up runit services for Pipewire"
sudo mkdir -p /etc/sv/pipewire
sudo bash -c 'cat <<EOF > /etc/sv/pipewire/run
#!/bin/sh
exec pipewire
EOF'
sudo chmod +x /etc/sv/pipewire/run

sudo mkdir -p /etc/sv/wireplumber
sudo bash -c 'cat <<EOF > /etc/sv/wireplumber/run
#!/bin/sh
exec wireplumber
EOF'
sudo chmod +x /etc/sv/wireplumber/run

# Enable services
print_message "Enabling Pipewire and Wireplumber services"
sudo ln -s /etc/sv/pipewire /var/service/pipewire
sudo ln -s /etc/sv/wireplumber /var/service/wireplumber

# Notify user of completion
print_message "Installation and configuration complete. Reboot your system."

# End of script
