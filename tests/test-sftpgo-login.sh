#!/bin/bash

# Temporary file to store cookies
COOKIE_FILE=$(mktemp)

# Fetch the login page and extract CSRF token
TOKEN=$(curl -k -s -c "$COOKIE_FILE" https://127.0.0.1/sftpgo/web/client/login \
        | grep -Po '(?<=name="_form_token" value=")[^"]*')

#echo "Token retrieved: $TOKEN"

# Log in with username/password + token
curl -k -s -b "$COOKIE_FILE" -c "$COOKIE_FILE" \
     -d "username=9001" \
     -d "password=9001" \
     -d "_form_token=$TOKEN" \
     -X POST https://127.0.0.1/sftpgo/web/client/login -D headers.txt

# Clean up
rm "$COOKIE_FILE"
rm headers.txt
