#!/bin/bash

# pipevoid - pipewire installer for void linux by Nicklas Rudolfsson

# Update system and install necessary packages
sudo xbps-install -S dumb_runtime_dir pipewire wireplumber pavucontrol qpwgraph

# Create directories and create symbolic links for PipeWire and WirePlumber configuration
sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

# Create symbolic links for autostart
sudo ln -s /usr/share/applications/wireplumber.desktop /etc/xdg/autostart/
sudo ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/

# Backup existing .xinitrc if it exists
if [ -f ~/.xinitrc ]; then
    cp ~/.xinitrc ~/.xinitrc.bak
fi

# Insert PipeWire start commands into .xinitrc
grep -qxF '# PipeWire start' ~/.xinitrc || echo -e "\n# PipeWire start\npipewire &\npipewire-pulse &\nwireplumber &" >> ~/.xinitrc

# Insert dbus launch command at the end of .xinitrc
grep -qxF '# Void dbus' ~/.xinitrc || echo -e "\n# Void dbus\nexec dbus-launch --sh-syntax --exit-with-session dwm" >> ~/.xinitrc

echo "Installation and configuration completed. Please restart your session."
