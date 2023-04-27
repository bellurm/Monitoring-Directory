#!/bin/bash

# We need to install 'inotify'.
# '> /dev/null' this command hiding installing transaction's output.
# '2>&1' this command, routing the stderr to stdout.
sudo apt install inotify-tools -y > /dev/null 2>&1

# Get input of the folder to be monitored.
read -p "Enter the directory to monitor: " dir

echo "Monitoring $dir for changes."

# Path of the log file.
log_file="/home/cyberworm/changes.log"

# Create log file if it doesn't exist.
if [ ! -f "$log_file" ]
then
	touch "$log_file"
fi

# In this block, we controlling the $dir for a change.
inotifywait -m -r -e create,delete,moved_to,moved_from "$dir" | while read -r directory events filename; do
	# Get IP address
	ip_address=$(ifconfig | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
	# Get MAC address
	mac_address=$(ifconfig | grep '\w\w:\w\w:\w\w:\w\w:\w\w:\w\w')
	# Get current time
	timestamp=$(date +"%Y-%m-%d %T")
	# echo to our log file
	echo -e "----------\nWhen: $timestamp - Where: $directory$filename - W.Happend: $events \n\nIP Address: $ip_address\nMAC Address: $mac_address\n----------\n" >> "$log_file"
	# Send a warn.
	notify-send "WARNING" \
	"[***] $directory/$filename has been $events. Source: In the log file." \
	-t 20000
done
