#!/bin/bash

# Get the directory that this script is running from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Run updates and run initial installation of dependencies
apt-get update
apt-get install -y jq ufw
### Removed UFW rule setup for security reasons
apt-get install -y lirc

# Backup modules and boot files
cp /etc/modules /etc/modules.backup
cp /boot/config.txt /etc/boot/config.txt.backup

# Replace system configuration files
cp "${DIR}/sysfiles/modules" /etc/modules
cp "${DIR}/sysfiles/config.txt" /boot/config.txt

# Repair LIRC files to avoid fail on install
cp "${DIR}/sysfiles/lirc_options.conf" /etc/lirc/lirc_options.conf
cp "${DIR}/sysfiles/lircd.conf" /etc/lirc/lircd.conf

# Reinstall lirc to fix errors
apt-get install -y lirc

# Restart lirc
service lircd restart

# Create the /smg directory
cp -r "${DIR}/smg" /

# Create a crontab entry for statusio.sh
cat "${DIR}/sysfiles/cron" | crontab -

# Test IR Remote
echo "\nTesting LED remote . . ."
sleep 1
irsend SEND_ONCE led-remote KEY_GREEN
sleep 1
irsend SEND_ONCE led-remote KEY_RED
sleep 1
irsend SEND_ONCE led-remote KEY_BLUE
sleep 1
irsend SEND_ONCE led-remote KEY_GREEN
sleep 1
irsend SEND_ONCE led-remote KEY_RED
sleep 1
irsend SEND_ONCE led-remote KEY_BLUE

# Start reboot process
echo -n "About to reboot, would you like to proceed? (y/n)"
read reply
if [ "$reply" = y -o "$reply" = Y ]
then
	reboot now
else
	exit
fi
