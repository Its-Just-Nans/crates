#!/bin/bash

# Usage: ./get_user_crates.sh <username>

USERNAME="$1"
me="Its-Just-Nans"

if [ -z "$USERNAME" ]; then
    echo "Usage: $0 <crates.io username>"
    echo "Defaulting to '$me'"
    USERNAME="$me"
fi

USER_AGENT="get all crates scripts"

PAGE=1
PER_PAGE=100
ALL_CRATES=()

user_id=$(curl -s "https://crates.io/api/v1/users/$USERNAME" -H "User-Agent: $USER_AGENT" | jq -r '.user.id')

if [ -z "$user_id" ] || [ "$user_id" == "null" ]; then
    echo "User '$USERNAME' not found on crates.io."
    exit 1
fi

echo "Fetching crates for user '$USERNAME' (ID: $user_id)..."

while : ; do
    sleep 1  # To avoid hitting the API too fast
    RESPONSE=$(curl -s "https://crates.io/api/v1/crates?user_id=$user_id&page=$PAGE&per_page=$PER_PAGE" -H "User-Agent: $USER_AGENT")

    # Check if the response contains crates
    CRATES=$(echo "$RESPONSE" | jq -r '.crates[].id')
    if [ -z "$CRATES" ]; then
        break
    fi

    # Append to the list
    while IFS= read -r crate; do
        ALL_CRATES+=("$crate")
    done <<< "$CRATES"

    # If less than requested, it's the last page
    COUNT=$(echo "$CRATES" | wc -l)
    if [ "$COUNT" -lt "$PER_PAGE" ]; then
        break
    fi

    ((PAGE++))
done

# Print results
echo "Crates published by user '$USERNAME':"
# crate a json to list.json
echo "[" > list.json
for i in "${!ALL_CRATES[@]}"; do
    echo "  \"${ALL_CRATES[$i]}\"$(if [ "$i" -lt $((${#ALL_CRATES[@]} - 1)) ]; then echo ","; fi)"
done >> list.json
echo "]" >> list.json
echo "Total crates found: ${#ALL_CRATES[@]}"
echo "Crates list saved to list.json"