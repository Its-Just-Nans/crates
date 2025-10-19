#!/bin/bash

# Usage: ./get_user_crates.sh <username>

USERNAME="$1"
me="Its-Just-Nans"

if [ -z "$USERNAME" ]; then
    echo "Usage: $0 <crates.io username>"
    echo "Defaulting to '$me'"
    USERNAME="$me"
fi

{
    echo "# crates"
    echo ""
    echo "- <https://crates.io/users/$USERNAME>"
    echo -e "\n## Crates\n"
    echo "| Crate | Description | Homepage && Repo |"
    echo "|-------|------------|----------|"
}> README.md
n4n5 utils list_crates -o - -f -d 0.5 | jq -c '.[]' | while read -r CRATE_INFO; do
    CRATE_NAME=$(echo "$CRATE_INFO" | jq -r '.crate.name')
    REPO_URL=$(echo "$CRATE_INFO" | jq -r '.crate.repository')
    HOMEPAGE_URL=$(echo "$CRATE_INFO" | jq -r '.crate.homepage')
    DOC_URL=$(echo "$CRATE_INFO" | jq -r '.crate.documentation')
    DESCRIPTION=$(echo "$CRATE_INFO" | jq -r '.crate.description')
    echo -n "| [$CRATE_NAME](https://crates.io/crates/$CRATE_NAME) |"
    if [ "$DESCRIPTION" != "null" ]; then
        echo -n "$DESCRIPTION"
    else
        echo -n " N/A"
    fi
    echo -n " | "
    if [ "$HOMEPAGE_URL" != "null" ]; then
        echo -n "[$HOMEPAGE_URL]($HOMEPAGE_URL) "
    else
        echo -n " N/A "
    fi
    if [ "$REPO_URL" != "null" ]; then
        echo -n "<br/> [$REPO_URL]($REPO_URL)"
    else
        echo -n "<br/> N/A"
    fi
    if [ "$DOC_URL" != "null" ]; then
        echo -n "<br/> [$DOC_URL]($DOC_URL)"
    else
        echo -n "<br/> N/A"
    fi
    echo -n " |"
    echo ""
done >> README.md