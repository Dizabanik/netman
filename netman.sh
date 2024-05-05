#!/bin/bash
function show_menu {
	# clear the screen
	tput clear
	 
	# Move cursor to screen location X,Y (top left is 0,0)
	tput cup 3 15
	 
	# Set a foreground colour using ANSI escape
	tput setaf 3
	echo "network manager using iwd."
	tput sgr0
	 
	tput cup 5 17
	# Set reverse video mode
	tput rev
	echo "M A I N - M E N U"
	tput sgr0
	 
	tput cup 7 15
	echo "1. Current connection"
	 
	tput cup 8 15
	echo "2. Connect to network"
	 
	tput cup 9 15
	echo "3. Disconnect"
	 
	tput cup 10 15
	echo "4. Exit"
	 
	# Set bold mode
	tput bold
	tput cup 12 15
	read -p "Enter your choice [1-4] " choice
	 
	tput clear
	tput sgr0
	tput rc
	# Run iwctl to list devices and capture the output
	iw_output=$(iwctl device list)
	
	# Use grep to extract the device name
	device_name=$(echo "$iw_output" | awk 'NR>4 {print $2}')
	adapter_name=$(echo "$iw_output" | awk 'NR>4 {print $4}')	
	
	if [[ $choice -eq 1 ]]
	then
		# Print the device name
		tput cup 5 17
		tput rev
		echo "C O N N E C T I O N - I N F O"
		tput sgr0
		tput cup 7 10
		echo "Device name: $device_name"
		outp_p=$(iwctl station $device_name show)
		state=$(echo "$outp_p" | grep 'State' | awk '{print $2}')
		con_id=$(echo "$outp_p" | grep 'Connected' | awk '{print $3}')
		ipv4_ad=$(echo "$outp_p" | grep 'IPv4' | awk '{print $3}')
		tput cup 8 10
		echo "State: $state"
		tput cup 9 10
		tput bold
		echo "Network: $con_id"
		tput sgr0
		tput cup 10 10
		echo "IPv4: $ipv4_ad"
	elif [[ $choice -eq 2 ]]
	then
		tput cup 2 17
		tput rev
		echo "C O N N E C T - T O"
		tput sgr0
		iwctl device $device_name set-property Powered on
		iwctl adapter $adapter_name set-property Powered on | grep -q "str"
		iwctl station $device_name scan
		networks_list=$(iwctl station $device_name get-networks | tail -n +2)
		tput cup 4 17
		tput bold
		echo "NETWORK LIST"
		tput sgr0
		tput cup 5 0
		echo "$networks_list"
		read -p 'Write the name of network you want to connect to: ' network_id_to_conn
		iwctl station $device_name connect $network_id_to_conn
		tput bold
		echo "Connected Successfully!"
		tput sgr0
	elif [[ $choice -eq 3 ]]
	then
		tput cup 5 17
		tput rev
		echo "D-I-S-C-O-N-N-E-C-T"
		tput sgr0
		tput cup 7 17
		tput bold
		read -p "Are you sure you want to disconnect from network?[y,N]: " disC
		if [[ "$disC" = "y" ]]
		then
			iwctl station $device_name disconnect
			echo "Disconnected Successfully!"
		fi
	elif [[ $choice -eq 4 ]]
	then
		exit 0
	else
		show_menu	
	fi
	echo "Press any key to continue..."
	read -n 1 -s
	show_menu
}
show_menu
