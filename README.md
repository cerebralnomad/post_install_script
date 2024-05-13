# post_install_script

Script to automatically install my preferred apps and packages on a fresh install of Ubuntu

The new scripts have been updated for 24.04.  
Snaps are not installed, several Flatpaks are.

post_install_kde.sh is for Kubuntu only.  
post_install.sh is for the other flavors, it will only be tested with MATE though. 

Latte Dock and Timeshift repos are no longer used. Those projects have been taken over by KDE and Linux Mint respectively and are in the standard repo.

The Firefox snap is removed, and Firefox is installed from the Mozilla repo.

Some apps have become available as Flatpaks and have been switched to that format to ensure the latest versions.  
This also eliminated the need for several additional repos.

Both scripts are now able to be run unattended. There are no requests for input once they are executed.  

The new scripts are currently untested. This line will be removed once testing in complete.

