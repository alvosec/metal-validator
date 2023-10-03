#!/bin/bash
# Create cronjob @hourly to run and check the status of your metal validator
# Check an example of validator status via this API https://explorer.metalblockchain.org/api/v1/validators/NodeID-MRFsc5DD5gegwp37E9tk5YWvKMqa1dTaz
# This metal node belongs to Alvosec

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists jq; then
    echo "jq is not installed. Please install jq before running this script."
    exit 1
fi

if ! command_exists curl; then
    echo "curl is not installed. Please install curl before running this script."
    exit 1
fi

# Create your own TG bot and group (it can be private), find chat id and enter here. 
CHAT_ID="chat_id"
BOT_TOKEN="bot_token"
NODE_ID="NodeID-*"
URL="https://explorer.metalblockchain.org/api/v1/validators/$NODE_ID"

JSON_DATA=$(curl -s "$URL" | jq '.')

NAME=$(jq -r '.name' <<< "$JSON_DATA")
CONNECTED=$(jq -r '.connected' <<< "$JSON_DATA")
UPTIME=$(jq -r '.uptime' <<< "$JSON_DATA")

if [[ "$CONNECTED" == "true" ]]; then
    STATUS_EMOJI="✅"
else
    STATUS_EMOJI="❌"
fi

if [[ "$CONNECTED" == "false" || "$UPTIME" -lt 110 ]]; then
    MESSAGE="<b>Validator Alert!</b>
Validator Name: $NAME
Connected: $STATUS_EMOJI $CONNECTED
Uptime: $UPTIME"

    curl -X POST \
         -H 'Content-Type: application/json' \
         -d "{\"chat_id\": \"$CHAT_ID\", \"text\": \"$MESSAGE\", \"parse_mode\": \"HTML\", \"disable_notification\": false}" \
         "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
fi
