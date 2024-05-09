#!/bin/bash

# Script to install my regular suite of programs on a fresh OS installation
# Run with sudo
# This script is no longer distro agnostic, it assumes Kubuntu is the chosen distro
# Plasma rules Gnome drools

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
	default-jdk # Java developer Kit
    default-jre # Java Runtime Environment
	git
	apt-transport-https # Needed for Syncthing
	zsh
	)

# GUI applications 

apps=(
	zim # Personal Wiki 
#	sigil # Edit Epub meta data
	keepass2 # Local password vault
	timeshift # system state automatic backup
	qbittorrent # Torrent downloader
	bleachbit # System cleaner
#	handbrake-gtk # Video encoder
	mkvtoolnix-gui # Video Muxer
	syncthing # File Syncronization between systems
	gpa # Graphical frontend for gnupg
	gnupg2 # PGP handling
	gnubg  # Backgammon game
	gtkhash # GUI checksum application
    libpwquality-tools  # for the pwscore utility to check pw strength
	exiftool  # tool for displaying metadata of epub and other formats
	bucklespring # utility to make kestrokes mimic IBM keyboard
    nomacs # Image viewer - requires 'Universe' repo to be enabled
    latte-dock # app dock for KDE
    )

# Snap packages

#snaps=(
#	cheat
#	solitaire
#    newpass
#    bashtop
#	)

# Flatpaks

flatpaks=(
        com.discordapp.Discord
        org.flatpak.Builder
        fr.handbrake.ghb
        com.cerebralnomad.recipescribe
        org.gnome.Sudoku
        com.sigil_ebook.Sigil
)

#Terminal addons
	
addons=(
	tree
	gcp
	bat
	ncdu
	inxi
	fastfetch # neofetch alternative
	htop
    btop
    ffmpeg
	vim
	mediainfo
	nodejs
	npm
	fortune
    fortunes-off 
    fortune-ng
    fortune-mod
    fortune-docs
    fortune-libs
	cowsay
	hwinfo
	terminator
	dstat
	hollywood
	figlet
    yakuake
	)

echo "Additional Program Installation for a Fresh OS Install"
echo "======================================================"
echo ""
echo "Adding Required Repositories"
echo "============================"
echo ""
# Add the qbittorrent repo
add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nqbittorrent repo added...\n\n'

# Add the backports ppa 
add-apt-repository ppa:kubuntu-ppa/backports

# MKVToolnix repo
# There are new repos for every version of Ubuntu
# The code below will have to be updated periodically for new Ubuntu
# versions and remove versions no longer supported refer to
# https://mkvtoolnix.download/downloads.html#ubuntu
# This should always be set for the current LTS
# Curently set to 24.04

sudo wget -O /usr/share/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg 2>> /home/$USERNAME/Documents/post_install_error.log
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/ubuntu/ noble main' | tee /etc/apt/sources.list.d/mkvtoolnix.download.list 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nMKVToolNix repo installed for 24.04\n\n'
echo ''

# Syncthing repo
curl -s https://syncthing.net/release-key.txt | apt-key add - 2>> /home/$USERNAME/Documents/post_install_error.log
echo 'deb https://apt.syncthing.net/ syncthing stable' | tee /etc/apt/sources.list.d/syncthing.list 2>> /home/$USERNAME/Documents/post_install_error.log && printf '\nSyncthing repo installed\n\n'

echo "Finished addding repos..."
echo ""
echo "Updating Repos and Upgrading System Files"
echo "========================================="
apt update && apt dist-upgrade -y

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

# Install Flatpak

echo "Installing Flatpak"
echo "=================="
echo ""
sudo apt install flatpak
echo ""
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo ""

echo "Adding Additional Sources with wget and curl"
echo "============================================"
echo ""
# Install Oh-My-ZSH
sudo -H -u $USERNAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

# Pull zsh theme from github and install 
wget https://raw.githubusercontent.com/cerebralnomad/post_install_script/master/clay.zsh-theme -O ~/.oh-my-zsh/themes/clay.zsh-theme

# Install Calibre
wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin 2>> /home/$USERNAME/Documents/post_install_error.log

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

echo "Installing Flatpaks"
echo "==================="
echo ""
for app in "${flatpaks[@]}" ; do
        if flatpak install flathub $app ; then
                printf "\n$app installed... \n\n"
        else
                printf "\n$app install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
        fi
done

# Install yt-dlp, a better youtube-dl replacement

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp
echo "yt-dlp installed"
echo ""

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
        if apt install -y $pkg ; then
                printf "\n$pkg installed... \n\n"
        else
                printf "\n$pkg install FAILED! \n\n" 2>> /home/$USERNAME/Documents/post_install_error.log
        fi
done

# Create symlink for bat in .local directory; bat is already a system alias
ln -s /usr/bin/batcat ~/.local/bin/bat

npm install -g tldr && printf "\nTLDR installed... \n\n"

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

