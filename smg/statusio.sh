#!/bin/bash

### Created by Maiko Tuitupou for the Service Monitoring Group
###
### This script gets the overall status information from
### https://api.status.io/1.0/status/561446c409989c1d2d000e99. This status information
### is then used to send either green, yellow, or red via the IR transceiver.
### Green will be sent if the overall status is "Operational". Red will be sent if the
### overall status is "Service Disruption", "Planned Maintenence", "Degraded Performance".
### Blue is sent otherwise indicating an internal error. In this case, the script
### returns an exit code of 1. In the case of a successful run, the script will exit with
### exit code 0.
###
### Dependencies:
### - jq for json parsing
### - lirc for irsend
### - correctly configured led remote in lirc
###

# File locations
STATUS_FILE="/smg/overall_status.json"		# Stores the overall_status
LOG_FILE="/smg/errors.log"			# Logs any errors that occur

# API URL
API='https://api.status.io/1.0/status/thishasbeenremoved' # This has been removed for security reasons

# Argument variables
forced=false

# Process arguments
while getopts fh o
do	case "$o" in
	f)	forced=true;;			# Force script to update overall_status
	h)	printf "Usage: $0 [-f] [-h]\n-f\tForces script to update overall_status\n-h\tDisplays help information\n"
		exit 1;;
	[?])	printf "Usage: $0 [-f] [-h]\n"
		exit 1;;
	esac
done

# Get the overall status from the statusio API
_status=$(curl -sS '${API}' | jq '.result.status_overall' | cat)

# If no status was retrieved, there was a problem.
if [ -z "$_status" ] ; then
	printf "\e[1;31mERROR:\tNo status received\n"
	irsend SEND_ONCE led-remote KEY_BLUE
	printf "\nError with script at $(date)\n" >> $LOG_FILE
	printf "No status retrieved from StatusIO\n" >> $LOG_FILE
	exit 1
fi

# Compare timestamp from curled status to stored status
if [ "$forced" = false ] ; then
	_cupdated=$(echo "$_status" | jq -r ".updated")
	_supdated=$(cat $STATUS_FILE | jq -r ".updated")
	if [ "$_cupdated" = "$_supdated" ]; then
		printf "NOTE:\tOverall status has not been updated since last curl.\n"
		exit 0
	fi
fi

# Update the old status file
echo "$_status" > $STATUS_FILE

# Send IR information depending on status from API call
if echo "$_status" | grep -iq "Operational" ; then
	printf "STATUS:\t\e[1;32mOperational\n" ; irsend SEND_ONCE led-remote KEY_GREEN
elif echo "$_status" | grep -iq "Planned Maintenance" ; then
	printf "STATUS:\t\e[1;32mPlanned Maintenance\n" ; irsend SEND_ONCE led-remote KEY_GREEN
elif echo "$_status" | grep -iq "Service Disruption" ; then
	printf "STATUS:\t\e[1;31mService Disruption\n" ; irsend SEND_ONCE led-remote KEY_RED
elif echo "$_status" | grep -iq "Degraded Performance" ; then
	printf "STATUS:\t\e[1;31mDegraded Performance\n" ; irsend SEND_ONCE led-remote KEY_RED
elif echo "$_status" | grep -iq "Security Issue" ; then
	printf "STATUS:\t\e[1;31mSecurity Issue\n" ; irsend SEND_ONCE led-remote KEY_RED
else # Script error
        irsend SEND_ONCE led-remote KEY_BLUE
	printf "\nError with script at $(date)\n" >> $LOG_FILE
	echo "$_status" >> $LOG_FILE
	printf "\n" >> $LOG_FILE
	exit 1
fi

exit 0
