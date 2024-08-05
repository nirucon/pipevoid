#!/bin/bash

# Simple script/helper to install and enable PipeWire on Void Linux
# By Nicklas Rudolfsson https://github.com/nirucon

# Check if figlet is installed
if command -v figlet &> /dev/null
then
    figlet pipevoid
else
    echo "--------------------------------------"
    echo "=== pipevoid === by nirucon =========="
    echo "--------------------------------------"
fi

echo -e "\033[1;32mWelcome to the pipevoid!\033[0m"
echo -e "\033[1;34mA script that helps you install and enable PipeWire for you to enjoy some nice music and sound without hassle.\033[0m"

read -p "Do you want to start the installer? (Y/n) " -r response
response=${response,,} # convert to lowercase
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    echo -e "\033[1;33mStarting the installation...\033[0m"

    # Update the system
    echo -e "\033[1;34mUpdating the system...\033[0m"
    sudo xbps-install -Syu

    # Install PipeWire and related tools
    echo -e "\033[1;34mInstalling PipeWire and related tools...\033[0m"
    sudo xbps-install -S pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack

    # Enable PipeWire services
    echo -e "\033[1;34mEnabling PipeWire services...\033[0m"
    sudo ln -s /etc/sv/pipewire /var/service/
    sudo ln -s /etc/sv/pipewire-pulse /var/service/
    sudo ln -s /etc/sv/wireplumber /var/service/

    # Configure ALSA to use PipeWire
    echo -e "\033[1;34mConfiguring ALSA to use PipeWire...\033[0m"
    sudo mkdir -p /etc/alsa/conf.d
    echo "pcm.!default {
    type plug
    slave.pcm {
        type pipewire
        playback_node {
            node.name \"playback\"
        }
        capture_node {
            node.name \"capture\"
        }
    }
}

ctl.!default {
    type hw
    card 0
}" | sudo tee /etc/alsa/conf.d/99-pipewire-default.conf

    # Configure PulseAudio to use PipeWire
    echo -e "\033[1;34mConfiguring PulseAudio to use PipeWire...\033[0m"
    mkdir -p ~/.config/pipewire
    cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/pipewire.conf
    sed -i 's/#context.exec = \[\n.*\n.*\n.*\]/context.exec = \[\n    { path = "\/usr\/bin\/pipewire" args = "" }\n    { path = "\/usr\/bin\/pipewire-pulse" args = "" }\n\]/' ~/.config/pipewire/pipewire.conf

    # Enable PipeWire in User Session
    echo -e "\033[1;34mEnabling PipeWire in user session...\033[0m"
    systemctl --user enable pipewire
    systemctl --user enable pipewire-pulse
    systemctl --user enable wireplumber

    echo -e "\033[1;32mPipeWire installed and should work after reboot.\033[0m"
    read -p "Do you want to reboot now? (Y/n) " -r reboot_response
    reboot_response=${reboot_response,,} # convert to lowercase
    if [[ $reboot_response =~ ^(yes|y| ) ]] || [[ -z $reboot_response ]]; then
        echo -e "\033[1;33mRebooting the system...\033[0m"
        sudo reboot
    else
        echo -e "\033[1;31mNo sound until reboot then! Bye!\033[0m"
        exit 0
    fi
else
    echo -e "\033[1;31mGoodbye!\033[0m"
    exit 0
fi
