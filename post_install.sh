#!/bin/bash

# Script to install the regular suite of programs on a fresh OS installation
# Run with sudo

# Check if the script was run as root

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run with sudo privileges"
	exit 1
fi

clear

# Collect username for error log

echo 'What is your username?'
echo -n '>>> '
read USERNAME

# Create the log file for any errors

sudo -H -u $USERNAME touch /home/$USERNAME/Documents/post_install_error.log 

echo 'Error log created at:'
echo "/home/$USERNAME/Documents/post_install_error.log"
read -n 1 -r -s -p "Press any key to continue..."

# Command line based tools and non-interactive libraries

packages=(
	wget
	curl
	python3-pip # PIP package manager for python 3
	python3-venv # Python 3 virtual environment manager
	default-jdk # Java developer Kit needed for running Eclipse IDE
	git
	apt-transport-https # Needed for Syncthing
	zsh
	)

# GUI applications 

apps=(
	zim # Personal Wiki 
	sigil # Edit Epub meta data
	keepass2 # Local password vault
	timeshift # system state automatic backup
	qbittorrent # Torrent downloader
	bleachbit # System cleaner
	handbrake-gtk # Video encoder
	mkvtoolnix-gui # Video Muxer
	syncthing # File Syncronization between systems
	gpa # Graphical frontend for gnupg
	gnupg2 # PGP handling
	gnubg  # Backgammon game
	gtkhash # GUI checksum application
	)

# Snap packages

snaps=(
	gimp
	gnome-sudoku
	sublime-text
	youtube-dl
	)

#Terminal addons
	
addons=(
	tree
	ncdu
	inxi
	neofetch
	htop
	vim
	mediainfo
	nodejs
	npm
	fortune
	cowsay
	hwinfo
	terminator
	dstat
	hollywood
	figlet
	)

echo "Additional Program Installation for a Fresh OS Install"
echo "======================================================"
echo ""
echo "Adding Required Repositories"
echo "============================"
echo ""
# Add the Timeshift repo
apt-add-repository -y ppa:teejee2008/ppa 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nTimeshift repo added...\n\n'

# Add the qbittorrent repo
add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nqbittorrent repo added...\n\n'

# Add the Handbrake repo
add-apt-repository -y ppa:stebbins/handbrake-releases 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nHandbrake repo added...\n\n'

echo -n "Is this a KDE installation? (y/n): "
read DISTRO
if [[ $DISTRO == "y"* || $DISTRO == "Y"* ]] ; then
	add-apt-repository -y ppa:rikmills/latte-dock 2>> /home/$USERNAME/Documents/post_install_error.log && printf "\nLattee Dock repo added... \n\n"
	add-apt-repository ppa:kubuntu-ppa/backports 2>> /home/$USERNAME/Documents/post_install_error.log -y && printf "\nKDE backports repo added... \n\n"
fi

echo "Finished addding repos..."
echo ""
echo "Updating Repos and Upgrading System Files"
echo "========================================="
apt update && apt upgrade -y

clear

echo "Installing Additional Tools"
echo "==========================="
echo ""

# Install the packages first as wget and curl are needed in the next step

for pkg in "${packages[@]}" ; do
	if apt install -y $pkg ; then 
		printf "\n$pkg installed... \n\n" 
	else 
		printf "\n$pkg install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
	fi
done

echo ""
echo "Adding Additional Sources with wget and curl"
echo "============================================"
echo ""
# Install Oh-My-ZSH
sudo -H -u $USERNAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

# Install Calibre
wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin 2>> /home/$USERNAME/Documents/post_install_error.log

# MKVToolnix repo
# There are new repos for every version of Ubuntu
# The code below will have to be updated periodically to include
# new versions and remove versions no longer supported refer to
# https://mkvtoolnix.download/downloads.html#ubuntu

echo "Enter the number in () next to the version of Ubuntu you are using"
echo "    (1) 18.04"
echo "    (2) 19.10"
echo -n ">>> "
read VER
wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - 2>> /home/$USERNAME/Documents/post_install_error.log
case $VER in
    1) echo 'deb https://mkvtoolnix.download/ubuntu/ bionic main' | tee /etc/apt/sources.list.d/mkvtoolnix.download.list 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nMKVToolNix repo installed for 18.10\n\n' ;;
    2) echo 'deb https://mkvtoolnix.download/ubuntu/ eoan main' | tee /etc/apt/sources.list.d/mkvtoolnix.download.list 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nMKVToolNix repo installed for 19.10\n\n' ;;
esac
echo ''
# Syncthing repo
curl -s https://syncthing.net/release-key.txt | apt-key add - 2>> /home/$USERNAME/Documents/post_install_error.log
echo 'deb https://apt.syncthing.net/ syncthing stable' | tee /etc/apt/sources.list.d/syncthing.list 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nSyncthing repo installed\n\n'

echo "Additional sources added"
echo ""

echo "Updating Sources"
echo "================"
apt update
clear

echo "Installing Applications"
echo "======================="
echo ""
for app in "${apps[@]}" ; do
	if apt install -y $app ; then 
		printf "\n$app installed... \n\n"
	else 
		printf "\n$app install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
	fi
done
echo ""

if [[ $DISTRO == "y"* || $DISTRO == "Y"* ]] ; then
	apt install -y latte-dock 2>> /home/$USERNAME/Documents/post_install_error.log && printf "\nLatte Dock installed... \n\n"
	apt install yakuake -y && printf "\nYAKUAKE installed...\n\n"
fi

echo "Installing Terminal Addons for Fresh Install"
echo "============================================"
echo ""
echo "Updating Repositories..."
echo ""
apt update
echo ""
clear
echo "Installing Terminal Addons for Fresh Install"
echo "============================================"
echo ""

for pkg in "${addons[@]}" ; do
	apt install -y $pkg
	printf "\n$pkg installed... \n\n"
done

npm install -g tldr && printf "\nTLDR installed... \n\n"

chsh -s /usr/bin/zsh
echo ""
echo "Terminal Addons and all applications installed... 
Remember to configure Git without using sudo privileges after this script has exited.

git config --global user.name <username>
git config --global user.email me@example.com

Log out and back in or reboot to activate the ZSH shell.
Replace the ~/.zshrc with your custom backup.
Place clay.zsh-theme in ~/.oh-my-zsh/themes/
Add your aliases file to the home directory.

Setup script finished."

