# post_install_script

Script to automatically install my preferred apps and packages on a fresh install of Ubuntu

The new scripts have been updated for 24.04.  
Snaps are not installed, several Flatpaks are.

post_install_kde.sh is for Kubuntu only.  
post_install.sh is for the other flavors, it will only be tested with MATE though. 

The Firefox snap is automatically removed and Firefox installed from the Mozilla repo.

Latte Dock and Timeshift repos are no longer used. Those projects have been taken over by KDE and Linux Mint respectively and are in the standard repo.

I noticed Keepass2 installed a ton of root certificates.  
I didn't like that, so I switched to KeepassXC as a flatpak.

Some apps have become available as Flatpaks and have been switched to that format to ensure the latest versions.  
This also eliminated the need for several additional repos.

Oh-My-ZSH is configured with my default theme, and my base .zshrc file is added to the home directory.  
My vim customizations are also pulled from this repo and applied.

The scripts ended up not being able to be run fully unattended. 
At the end the default shell is changed to ZSH and this requires the user password.  
Broot is also configured and it requires a yes input to proceed.



