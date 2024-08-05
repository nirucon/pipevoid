#!/bin/bash

# Work in progress by Nicklas Rudolfsson...

# Function to print in color
print_color() {
    echo -e "\033[$1m$2\033[0m"
}

# Function to check and install package
install_package() {
    local package=$1
    if xbps-query -Rs "^${package}-[0-9]"; then
        sudo xbps-install -S ${package}
    else
        print_color "1;31" "Package '${package}' not found in repository pool."
    fi
}

# Function to create a default configuration file if it does not exist
create_default_file() {
    local file=$1
    local content=$2
    local dir
    dir=$(dirname "$file")
    if [[ ! -d $dir ]]; then
        sudo mkdir -p "$dir"
        print_color "1;32" "Created directory $dir."
    fi
    if [[ ! -f $file ]]; then
        echo -e "$content" | sudo tee "$file" > /dev/null
        print_color "1;32" "Created $file with default content."
    fi
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

# Check if PipeWire is already installed
if xbps-query -Rs "^pipewire-[0-9]"; then
    print_color "1;33" "PipeWire is already installed."
    read -p "Do you want to reinstall and configure PipeWire? (Y/n) " -r response
    response=${response,,} # convert to lowercase
    if [[ ! $response =~ ^(yes|y| ) ]] && [[ -n $response ]]; then
        print_color "1;31" "Goodbye!"
        exit 0
    fi
else
    read -p "Do you want to start the installer? (Y/n) " -r response
    response=${response,,} # convert to lowercase
    if [[ ! $response =~ ^(yes|y| ) ]] && [[ -n $response ]]; then
        print_color "1;31" "Goodbye!"
        exit 0
    fi
fi

print_color "1;33" "Starting the installation..."

# Update the system
print_color "1;34" "Updating the system..."
sudo xbps-install -Syu

# Install PipeWire and related tools
print_color "1;34" "Installing PipeWire and related tools..."
install_package pipewire
install_package alsa-pipewire
install_package pulseaudio-utils
install_package wireplumber
install_package pipewire-pulse

# Enable PipeWire services
print_color "1;34" "Enabling PipeWire services..."
sudo ln -sf /etc/sv/pipewire /var/service/
sudo ln -sf /etc/sv/wireplumber /var/service/
sudo ln -sf /etc/sv/pipewire-pulse /var/service/

# Create default /etc/pipewire/pipewire.conf if it doesn't exist
create_default_file "/etc/pipewire/pipewire.conf" "[context]\nexec = [ \"/usr/bin/pipewire\" ]\n[\"/usr/bin/pipewire\"] = { args = \"-c pipewire-pulse.conf\" }"

# Configure ALSA to use PipeWire
print_color "1;34" "Configuring ALSA to use PipeWire..."
sudo mkdir -p /etc/alsa/conf.d
sudo ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
sudo ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

# Create default /etc/pulse/client.conf if it doesn't exist
create_default_file "/etc/pulse/client.conf" "[daemon]\nautospawn = no"

# Edit /etc/pulse/client.conf to disable autospawn if it exists
if [[ -f /etc/pulse/client.conf ]]; then
    print_color "1;34" "Configuring PulseAudio client..."
    sudo sed -i 's/; autospawn = yes/autospawn = no/' /etc/pulse/client.conf
else
    print_color "1;31" "/etc/pulse/client.conf not found. Skipping PulseAudio configuration."
fi

# Create the start-pipewire script in ~/.local/bin
print_color "1;34" "Creating start-pipewire script..."
mkdir -p ~/.local/bin
echo '#!/bin/bash
pipewire &
sleep 1
wireplumber &
pipewire-pulse &' > ~/.local/bin/start-pipewire
chmod +x ~/.local/bin/start-pipewire
print_color "1;32" "Created ~/.local/bin/start-pipewire"

# Check if .xinitrc exists and ask if you want to add PipeWire start command
if [[ -f ~/.xinitrc ]]; then
    if ! grep -q "start-pipewire" ~/.xinitrc; then
        read -p "Do you want to add PipeWire to start at login in .xinitrc? (Y/n) " -r xinitrc_response
        xinitrc_response=${xinitrc_response,,} # convert to lowercase
        if [[ $xinitrc_response =~ ^(yes|y| ) ]] || [[ -z $xinitrc_response ]]; then
            print_color "1;34" "Adding PipeWire to start at login in .xinitrc..."
            echo -e "\n# Start PipeWire\n~/.local/bin/start-pipewire &" >> ~/.xinitrc
            print_color "1;32" "PipeWire added to .xinitrc."
        fi
    else
        print_color "1;32" "PipeWire is already set to start in .xinitrc."
    fi
else
    print_color "1;31" ".xinitrc not found. Please create it if you use startx."
fi

print_color "1;32" "PipeWire installed and should work after reboot."
read -p "Do you want to reboot now? (Y/n) " -r reboot_response
reboot_response=${reboot_response,,} # convert to lowercase
if [[ $reboot_response =~ ^(yes|y| ) ]] || [[ -z $reboot_response ]]; then
    print_color "1;33" "Rebooting the system..."
    sudo reboot
else
    print_color "1;31" "No sound until reboot then! Bye!"
    exit 0
fi
