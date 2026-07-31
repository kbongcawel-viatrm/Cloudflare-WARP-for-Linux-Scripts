#!/bin/bash

# Function to get WARP mode
warp_mode() {
    warp-cli settings | grep Mode | awk '{ print $3" "$4 }'
}

# Function to initialize WARP connection
warp_init() {
    echo "Initializing connection..."

    warp-cli registration delete  > /dev/null
    warp-cli registration new 	  > /dev/null
    warp-cli mode warp+doh 	  > /dev/null
    warp-cli dns families malware > /dev/null
    warp-cli tunnel protocol set MASQUE #returns success
}

# Function to connect WARP
warp_connect() {
    echo "Connecting WARP..."
    warp-cli connect
    warp_mode
}

# Function to disconnect WARP
warp_disconnect() {
    echo "Disconnecting WARP..."
    warp-cli disconnect
    warp-cli status
}

# Get WARP status
WARP_STATUS=$(warp-cli status | grep -i "Status" | awk -F': ' '{print $2}')

if [[ "$WARP_STATUS" == "Disconnected" ]]; then

    read -rp "WARP is disconnected. Setup and connect? (y/n): " ANSWER

    case "$ANSWER" in
        y|Y)
            warp_init
            warp_connect
            ;;
        n|N)
            echo "No changes made."
            warp_mode
            ;;
        *)
            echo "Invalid option."
            exit 1
            ;;
    esac

elif [[ "$WARP_STATUS" == "Connected" ]]; then

    warp-cli status
    warp_mode
    warp-cli registration show

    read -rp "WARP is connected. Disconnect? (y/n): " ANSWER

    case "$ANSWER" in
        y|Y)
            warp_disconnect
            echo "WARP disconnected."
            ;;
        n|N)
            echo "WARP remains connected."
            ;;
        *)
            echo "Invalid option."
            exit 1
            ;;
    esac

else
    echo "Unable to determine WARP status."
    warp-cli status
    exit 1
fi
