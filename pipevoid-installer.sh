sudo xbps-install -S dumb_runtime_dir pipewire wireplumber pavucontrol qpwgraph

sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/

sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

sudo ln -s /usr/share/applications/wireplumber.desktop /etc/xdg/autostart/
sudo ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/

Insert this sections in .xinitrc:

# PipeWire start
pipewire &
pipewire-pulse &
wireplumber &

And instert after everyting else at the last line of .xinitrc:

# Void dbus
exec dbus-launch --sh-syntax --exit-with-session dwm
