#!/bin/bash

# Script to install my regular suite of programs on a fresh OS installation
# Run with sudo
# This script is for Ubuntu flavors not running KDE (Kubuntu)
# It will only be tested with MATE
# Plasma rules Gnome drools

# Check if the script was run as root

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run with sudo privileges"
	exit 1
fi

clear

# Set variables for colorizing the terminal output
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
reset='\033[0m'
pink='\033[1;31m'
lightred='\033[1;31m'
yellow='\033[1;33m'
lightpurple='\033[1;35m'
warn=$(tput setaf 214)

# Create the log file for any errors

USERNAME="$SUDO_USER"

sudo -H -u $USERNAME touch /home/$USERNAME/Documents/post_install_error.log 

echo 'Error log created at:'
echo "/home/$USERNAME/Documents/post_install_error.log"
sleep 3

# Increase the bash history size to allow scrolling back through the output
export HISTSIZE=-1
export HISTFILESIZE=-1
source /home/$USERNAME/.bashrc

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
# Currently (May 2024) the AppImage Launcher PPA does not have a release for Ubuntu 24.04
# This will be uncommented once it is available
apps=(
        alacarte # application menu editor
 #       appimagelauncher # integrate AppImages into the system menu - from 3rd party PPA
        bleachbit # System cleaner
        brave-browser
        dconf-editor # configure application settings on GTK distros
        exiftool  # tool for displaying metadata of epub and other formats
        gimp
        gnupg2 # PGP handling
        gnubg  # Backgammon game
        gpa # Graphical frontend for gnupg
        gparted # disk partition manager
        gtkhash # GUI checksum application
        keepass2 # Local password vault
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
        org.torproject.torbrowser-launcher
)

#Terminal addons

# The offensive fortunes (fortunes-off) package is missing from the 24.04 repo
# The whining pansies may have gotten it removed
# Will uncomment if someone of substance decides to put it back

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
 #       fortunes-off # adds offensive fortunes (fortune -o)
        gcp  # advanced command-line file copier
        hollywood # silly program to make the terminal look like 1337 H4X0R
        hwinfo # display details abou tsystem hardware
        inxi # command line system information script
        imagemagick
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
	)

echo -e "${lightgreen}Updating Repos and Upgrading System Files${reset}"
echo -e "${lightgreen}=========================================${reset}"
add-apt-repository universe -y
add-apt-repository restricted -y
apt update && apt dist-upgrade -y
apt install -y software-properties-common
sleep 2

# Install the packages first as wget and curl are needed in the next steps

for pkg in "${packages[@]}" ; do
    if apt install -y $pkg ; then
            echo ""
            echo -e "${green}$pkg successfully installed...${reset}"
            echo ""
            sleep 1
        
    else
            echo ""
            echo -e "${red}$pkg install FAILED!${reset}"
            echo "$pkg failed to install" >> /home/$USERNAME/Documents/post_install_error.log
            echo ""
            sleep 1
    fi
done

echo -e "${lightgreen}Additional Program Installation for a Fresh OS Install${reset}"
echo -e "${lightgreen}======================================================${reset}"
echo ""
echo -e "${lightgreen}Adding Required Repositories${reset}"
echo -e "${lightgreen}============================${reset}"
echo ""

# Remove the Firefox snap and setup the Mozilla PPA to install the .deb version (thank you Mozilla) because the snap sucks 
snap remove firefox
install -d -m 0755 /etc/apt/keyrings  # Create an APT keyring (if one doesn’t already exist)
# Import the Mozilla APT repo signing key
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
https://raw.githubusercontent.com/cerebralnomad/post_install_script/master/post_install_testing.sh# Add the Mozilla signing key to your sources.list
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
# Set the Firefox package priority to ensure Mozilla’s Deb version is always preferred
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

# Add the AppImage Launcher repo

# Currently (May 2024) this repo does not have a release for Ubuntu 24.04
# Uncomment once a release is available

#add-apt-repository ppa:appimagelauncher-team/stable 2>> /home/$USERNAME/Documents/post_install_error.log 
#echo ""
#echo -e "${green}AppImage Launcher repo added...${reset}"
#sleep 2

# Syncthing repo
curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg  2>> /home/$USERNAME/Documents/post_install_error.log
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list 2>> /home/$USERNAME/Documents/post_install_error.log 
echo ""
echo -e "${green}Syncthing repo installed${reset}"
sleep 2

# Add the Brave browser repo for the once or twice a year when a site doesn't work with Firefox
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Add the fastfetch repo; it is not yet in the 24.04 main repo
add-apt-repository ppa:zhangsongcui3371/fastfetch -y

echo -e "${green}Finished addding repos...${reset}"
echo ""
echo -e "${lightgreen}Updating Newly Added Repos${reset}"
echo -e "${lightgreen}==========================${reset}"
apt update
bash add to path
sleep 2
echo ""
echo -e "${lightgreen}Installing Additional Tools${reset}"
echo -e "${lightgreen}===========================${reset}"
echo ""

# Install Flatpak because Canonical is being a dick about it

echo -e "${lightgreen}Installing Flatpak${reset}"
echo -e "${lightgreen}==================${reset}"
echo ""
sudo apt install flatpak -y
sleep 1
echo ""
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo ""
echo -e "${green}Flatpak installed...${reset}"
echo ""
sleep 2

echo -e "${lightgreen}Adding Additional Sources with wget and curl${reset}"
echo -e "${lightgreen}============================================${reset}"
echo ""
# Install Oh-My-ZSH
sudo -H -u $USERNAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
sleep 1
# Pull zsh theme from github and install 
wget https://raw.githubusercontent.com/cerebralnomad/post_install_script/master/clay.zsh-theme -O /home/$USERNAME/.oh-my-zsh/themes/clay.zsh-theme
sleep 1

echo -e "${green}Additional sources added${reset}"
echo ""
sleep 2
echo -e "${lightgreen}Installing Applications${reset}"
echo -e "${lightgreen}=======================${reset}"
echo ""
# Install of firefox will occasionally fail if -y is used without --allow-downgrades
# so it is installed separately
if apt install -y --allow-downgrades firefox ; then
        echo ""
        echo -e "${green}Firefox installed...${reset}"
        echo ""
        sleep 1
else
        echo""
        echo -e "${red}Firefox install FAILED!${reset}"
        echo "Firefox to install from the Mozilla repo" >> /home/$USERNAME/Documents/post_install_error.log
        echo ""
        sleep 1
fi


for app in "${apps[@]}" ; do
	if apt install -y $app ; then
        echo "" 
		echo -e "${green}$app installed...${reset}"
        echo ""
        sleep 1
	else 
		echo ""
        echo -e "${red}$app install FAILED!${reset}"
        echo "$app failed to install" >> /home/$USERNAME/Documents/post_install_error.log
        echo ""
        sleep 1
	fi
done
echo ""
sleep 1

echo -e "${lightgreen}Installing Flatpaks${reset}"
echo -e "${lightgreen}===================${reset}"
echo ""
for app in "${flatpaks[@]}" ; do
        if flatpak install -y flathub $app ; then
                echo ""
                echo -e "${green}$app Flatpak installed...${reset}"
                echo ""
                sleep 1
        else
                echo ""
                echo -e "${red}$app install FAILED!${reset}"
                echo "$app Flatpak failed to install" >> /home/$USERNAME/Documents/post_install_error.log
                sleep 1
        fi
done

# Install yt-dlp, a better youtube-dl replacement
echo ""
echo -e "${lightgreen}Installing yt-dlp${reset}"
echo ""
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp

# Add the configuration file to default to best video and audio in mp4 format
# Other things such as default save location can be added to this file later as desired
# Comment the next 2 lines to skip the creation of the config file
echo "# Always choose the best available quality" > /etc/yt-dlp.conf
echo '-f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"' >> /etc/yt-dlp.conf

echo -e "${green}yt-dlp installed...${reset}"
echo ""
sleep 1

echo -e "${lightgreen}Installing Terminal Addons for Fresh Install${reset}"
echo -e "${lightgreen}============================================${reset}"
echo ""

for pkg in "${addons[@]}" ; do
        if apt install -y $pkg ; then
                echo ""
                echo -e "${green}$pkg installed...${reset}"
                echo ""
                sleep 1
        else
                echo ""
                echo -e "${red}$pkg install FAILED!${reset}"
                echo "$pkg failed to install" >> /home/$USERNAME/Documents/post_install_error.log
                echo ""
                sleep 1
        fi
done

# Install the syntax highlighting plugin for ZSH
sudo -u $USERNAME mkdir /home/$USERNAME/.zsh_scripts
cd /home/$USERNAME/.zsh_scripts
sudo -u $USERNAME git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
cd /home/$USERNAME

# Make local directories to be added to PATH
sudo -u $USERNAME mkdir /home/$USERNAME/.local/bin
sudo -u $USERNAME mkdir /home/$USERNAME/bin
# Remove existing .zshrc
rm /home/$USERNAME/.zshrc
# Fetch modified .zshrc from GitHub
wget https://raw.githubusercontent.com/cerebralnomad/post_install_script/master/.zshrc -O /home/$USERNAME/.zshrc
source /home/$USERNAME/.zshrc

# Create symlink for bat in .local directory
# bat installs as batcat on Ubuntu due to a name clash with another existing package
sudo -u $USERNAME ln -s /usr/bin/batcat /home/$USERNAME/.local/bin/bat

# Install the TL/DR utility
if npm install -g tldr ; then
        echo ""
        echo -e "${green}TL/DR installed...${reset}"
        echo ""
else
        echo ""
        echo -e "${red}TL/DR install FAILED!${reset}"
        echo "TLDR failed to install with npm" >> /home/$USERNAME/Documents/post_install_error.log
        echo ""
fi

sleep 1

# Install broot
curl -o broot -L https://dystroy.org/broot/download/x86_64-linux/broot
mv broot /usr/local/bin
chmod +x /usr/local/bin/broot

echo -e "${pink}Now we'll change the default shell to ZSH. The password for $USERNAME will be required${reset}"
echo ""
# Change the default shell from bash to zsh
sudo -u $USERNAME chsh -s /usr/bin/zsh
echo ""
# Configure broot
echo -e "${pink}Now we'll configure broot. You will be prompted to let it install the shell function, select Yes${reset}"
echo ""
sudo -u $USERNAME broot
echo ""
echo -e "${pink}Now you can use br to run broot${reset}"
echo ""
echo -e "${green}Terminal Addons and all applications installed... 
Remember to configure Git without using sudo privileges after this script has exited.

git config --global user.name <username>
git config --global user.email me@example.com

Log out and back in or reboot to activate the ZSH shell.
Replace the ~/.zshrc with your custom backup.
Add your aliases file to the bin directory and symlink in the home directory.

Setup script finished.${reset}"
echo ""
echo -e "${pink}System must reboot for all changes to take effect${reset}"
echo ""
echo -e "${warn}System will reboot in 10 seconds...${reset}"
echo ""
sleep 10
reboot
