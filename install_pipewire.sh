#!/bin/bash

# Function to print messages
print_message() {
  echo "========================================"
  echo "$1"
  echo "========================================"
}

# Update the system and install necessary packages
print_message "Updating the system and installing necessary packages"
xbps-install -Syu
xbps-install -Sy pipewire alsa-utils alsa-plugins alsa-firmware pipewire-alsa pipewire-pulse wireplumber

# Enable pipewire services
print_message "Enabling Pipewire and WirePlumber services"
ln -s /etc/sv/pipewire /var/service/
ln -s /etc/sv/wireplumber /var/service/

# Configure ALSA to use Pipewire
print_message "Configuring ALSA to use Pipewire"
cat <<EOF > /etc/alsa/conf.d/99-pipewire-default.conf
pcm.!default {
    type plug
    slave.pcm {
        type pipewire
    }
}

ctl.!default {
    type pipewire
}
EOF

# Reload ALSA
print_message "Reloading ALSA"
alsa force-reload

# Add instructions for starting services and enabling audio on login
print_message "Adding instructions for starting services on login"
cat <<EOF >> /etc/profile
# Start pipewire and wireplumber
if [ -z "\$DISPLAY" ] && [ \$(tty) = /dev/tty1 ]; then
    exec startx
fi
EOF

# Set up runit services for Pipewire
print_message "Setting up runit services for Pipewire"
mkdir -p /etc/sv/pipewire
cat <<EOF > /etc/sv/pipewire/run
#!/bin/sh
exec pipewire
EOF
chmod +x /etc/sv/pipewire/run

mkdir -p /etc/sv/wireplumber
cat <<EOF > /etc/sv/wireplumber/run
#!/bin/sh
exec wireplumber
EOF
chmod +x /etc/sv/wireplumber/run

# Enable services
print_message "Enabling Pipewire and Wireplumber services"
ln -s /etc/sv/pipewire /var/service/pipewire
ln -s /etc/sv/wireplumber /var/service/wireplumber

# Notify user of completion
print_message "Installation and configuration complete. Reboot your system."

# End of script
