#!/bin/bash

# Script to install my regular suite of programs on a fresh OS installation
# Run with sudo
# This script is not distro agnostic, it assumes Kubuntu is the chosen distro
# Plasma rules Gnome drools

# Check if the script was run as root

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run with sudo privileges"
	exit 1
fi

clear

# Create the log file for any errors

USERNAME="$SUDO_USER"

sudo -H -u $USERNAME touch /home/$USERNAME/Documents/post_install_error.log 

echo 'Error log created at:'
echo "/home/$USERNAME/Documents/post_install_error.log"
sleep 3

# Create the variables for the various packages to be installed
# Comment out any you do not want/need

# Command line based tools and non-interactive libraries

packages=(
	wget
	curl
	python3-pip # PIP package manager for python 3
	python3-venv # Python 3 virtual environment manager
	default-jdk # Java developer Kit
    default-jre # Java Runtime Environment
	git
	apt-transport-https # Needed for Syncthing
	zsh
	)

# GUI applications 

apps=(
        appimagelauncher # integrate AppImages into the system menu - from 3rd party PPA
        bleachbit # System cleaner
        brave-browser
        exiftool  # tool for displaying metadata of epub and other formats
        firefox
        gimp
        gnupg2 # PGP handling
        gnubg  # Backgammon game
        gpa # Graphical frontend for gnupg
        gparted # I just prefer it over KDE Partition Manager
        gtkhash # GUI checksum application
        keepass2 # Local password vault
        latte-dock # app dock for KDE
        mediainfo-gui # graphical frontend for mediainfo
        mp3splt-gtk # graphical frontend for mp3splt
        nomacs # Image viewer - requires 'Universe' repo to be enabled
        syncthing # File Syncronization between systems - will install from 3rd party PPA
        timeshift # system state automatic backup
        zim # Personal Wiki
    )

# Snap packages

#snaps=(
#    newpass
#	)

# Flatpaks

flatpaks=(
        com.discordapp.Discord
        org.flatpak.Builder
        fr.handbrake.ghb
        com.cerebralnomad.recipescribe
        org.gnome.Sudoku
        org.qbittorrent.qBittorrent
        org.bunkus.mkvtoolnix-gui
        com.calibre_ebook.calibre
        com.sigil_ebook.Sigil
        org.kde.filelight
        org.kde.kdenlive
        org.torproject.torbrowser-launcher
)

#Terminal addons
	
addons=(
	    bat  # a cat clone with syntax highlighting
        btop  # Resource monitor, like htop but better
        bucklespring # utility to make kestrokes mimic IBM keyboard
        checkinstall # make install replacement for building from source
        cowsay
        dmidecode # reports information about your system's hardware as described in your system BIOS
        dstat  # tool for generating system resource statistics
        duf # a better du command to display disk usage/free
        fastfetch # alternative to neofetch which is no longer maintained
        ffmpeg  # command line video converter
        figlet # create ASCII art from plain text
        fortune-mod # display fortunes in the terminal
        fortunes-off # adds offensive fortunes (fortune -o)
        gcp  # advanced command-line file copier
        hollywood # silly program to make the terminal look like 1337 H4X0R
        hwinfo # display details abou tsystem hardware
        inxi # command line system information script
        imagemagick
        kwave # sound editor for KDE
        libpwquality-tools  # for the pwscore utility to check pw strength
        mediainfo # display information about audio/video files
        mp3gain # mp3 volume adjuster
        mp3wrap # joins mp3 files
        mp3splt # split mp3 files without decoding
        ncdu # NCurses Disk Usage utility
        nmap # network scanning tool
        nodejs # JavaScript runtime
        npm # JavaScript package manager
        rename # batch rename files using sed syntax
        simplescreenrecorder
        terminator # terminal emulator
        tree # list contents of directories in a tree-like format
        vim # terminal text editor
        yakuake # drop down terminal
	)

echo "Additional Program Installation for a Fresh OS Install"
echo "======================================================"
echo ""
echo "Adding Required Repositories"
echo "============================"
echo ""

# Add the AppImage Launcher repo
add-apt-repository ppa:appimagelauncher-team/stable 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nAppImage Launcher repo added...\n\n'
sleep 2

# Add the backports ppa 
add-apt-repository ppa:kubuntu-ppa/backports
sleep 2

# Syncthing repo
curl -s https://syncthing.net/release-key.txt | apt-key add - 2>> /home/$USERNAME/Documents/post_install_error.log
echo 'deb https://apt.syncthing.net/ syncthing stable' | tee /etc/apt/sources.list.d/syncthing.list 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nSyncthing repo installed\n\n'
sleep 2

# Remove the Firefox snap and setup the Mozilla PPA to install the .deb version (thank you Mozilla) because the snap sucks 
snap remove firefox
install -d -m 0755 /etc/apt/keyrings  # Create an APT keyring (if one doesn’t already exist)
# Import the Mozilla APT repo signing key
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
# Add the Mozilla signing key to your sources.list
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
# Set the Firefox package priority to ensure Mozilla’s Deb version is always preferred
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

# Add the Brave browser repo for the once or twice a year when a site doesn't work with Firefox
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

echo "Finished addding repos..."
echo ""
echo "Updating Repos and Upgrading System Files"
echo "========================================="
apt update && apt dist-upgrade -y

sleep 2

echo "Installing Additional Tools"
echo "==========================="
echo ""

# Install the packages first as wget and curl are needed in the next steps

for pkg in "${packages[@]}" ; do
	if apt install -y $pkg ; then 
		printf "\n$pkg installed... \n\n"
        sleep 1 
	else 
		printf "\n$pkg install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
        sleep 1
	fi
done
echo ""
sleep 2

# Install Flatpak because Canonical is being a dick about it

echo "Installing Flatpak"
echo "=================="
echo ""
sudo apt install flatpak
sleep 1
echo ""
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo ""
sleep 2

echo "Adding Additional Sources with wget and curl"
echo "============================================"
echo ""
# Install Oh-My-ZSH
sudo -H -u $USERNAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
sleep 1
# Pull zsh theme from github and install 
wget https://raw.githubusercontent.com/cerebralnomad/post_install_script/master/clay.zsh-theme -O ~/.oh-my-zsh/themes/clay.zsh-theme
sleep 1

echo "Additional sources added"
echo ""
sleep 2
echo "Installing Applications"
echo "======================="
echo ""
for app in "${apps[@]}" ; do
	if apt install -y $app ; then 
		printf "\n$app installed... \n\n"
        sleep 1
	else 
		printf "\n$app install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
        sleep 1
	fi
done
echo ""
sleep 1

echo "Installing Flatpaks"
echo "==================="
echo ""
for app in "${flatpaks[@]}" ; do
        if flatpak install flathub $app ; then
                printf "\n$app installed... \n\n"
                sleep 1
        else
                printf "\n$app install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
                sleep 1
        fi
done

# Install yt-dlp, a better youtube-dl replacement

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp

# Add the configuration file to default to best video and audio in mp4 format
# Other things such as default save location can be added to this file later as desired
# Comment the next 2 lines to skip the creation of the config file
echo "# Always choose the best available quality" > /etc/yt-dlp.conf
echo '-f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"' >> /etc/yt-dlp.conf

echo "yt-dlp installed"
echo ""
sleep 1

echo "Installing Terminal Addons for Fresh Install"
echo "============================================"
echo ""

for pkg in "${addons[@]}" ; do
        if apt install -y $pkg ; then
                printf "\n$pkg installed... \n\n"
                sleep 1
        else
                printf "\n$pkg install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
                sleep 1
        fi
done

# Create symlink for bat in .local directory
# bat installs as batcat on Ubuntu due to a name clash with another existing package
ln -s /usr/bin/batcat ~/.local/bin/bat

# Install the TL/DR utility
npm install -g tldr && printf "\nTLDR installed... \n\n"
sleep 1

# Change the default shell from bash to zsh
chsh -s /usr/bin/zsh

echo ""
echo "Terminal Addons and all applications installed... 
Remember to configure Git without using sudo privileges after this script has exited.

git config --global user.name <username>
git config --global user.email me@example.com

Log out and back in or reboot to activate the ZSH shell.
Replace the ~/.zshrc with your custom backup.
Add your aliases file to the bin directory and symlink in the home directory.

Setup script finished."

