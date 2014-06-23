     _ _     _    _   _                     ___  ___            
    | (_)   | |  | | | |                    |  \/  |            
  __| |_ ___| | _| | | |___  __ _  __ _  ___| .  . | ___  _ __  
 / _` | / __| |/ / | | / __|/ _` |/ _` |/ _ \ |\/| |/ _ \| '_ \ 
| (_| | \__ \   <| |_| \__ \ (_| | (_| |  __/ |  | | (_) | | | |
 \__,_|_|___/_|\_\\___/|___/\__,_|\__, |\___\_|  |_/\___/|_| |_|
                                   __/ |                        
                                  |___/                         
==================================================================
==================================================================

Disk usage monitor designed for the Raspberry Pi. The diskUsageMon can be easily configured to automatically alert the user if the disk usage reach a predefined limit


Requirements:
-------------
In order to use the email alert feature, the Raspberry Pi must be able to send emails through the Internet

Follow the guide below in order to set up a Gmail account to be used by the Raspberry Pi for sending email alerts

Link: http://bogdanioanliviu.no-ip.org/install-postfix-gmail-account-on-raspberry-pi/


How to install:
---------------
To install diskUsageMon just execute the install.sh which can be found inside the installer directory

For more options, the instal.sh script also accept the -h switch

./install.sh -h

Usage: install.sh [OPTIONS]

OPTIONS:
  -h show this help
  -f force installation overwriting any existing files
  -u uninstall tool


Customizing diskUsageMon:
-------------------------
Inside the script directory it can be found a .props file with a bunch of parameters which can be set as needed in order to customize this tool

How to uninstall:
-----------------
To unistall diskUsageMon just execute the install.sh script with the -u switch


How to setup periodic checks:
-----------------------------
In order to setup periodic checks,the script should be installed in the target system and then a cron job should be created

A cron job example can be seen just below (this should work if used inside /etc/cronjob)

# Disk usage monitor
0 3 * * * root /opt/icetools/bin/diskUsageMon.sh -v -a &>/dev/null

Remember to add the /opt/icetools/bin directory to the crontab PATH defined in the first section of the file /etc/crontab file
