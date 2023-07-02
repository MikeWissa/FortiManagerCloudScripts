#!/bin/bash
# In this example we login to FortiManager Cloud and Create a Policy Package, Device Group, Template Group, Device Blue Print, Add a device using pre-shared key
# loads the environment variables file, ensure that your password the \! is there otherwise it will not work
source.env
# The first step is to get the access token
access_token=$(curl -s --location 'https://customerapiauth.fortinet.com/api/v1/oauth/token/' \
--data '{
    "username": "'"$username"'",
    "password": "'"$password"'",
    "client_id": "FortiManager",
    "grant_type": "password"
}' | jq -r '.access_token')
URL=$FortiManagerHost
session=$(curl -s --location --globoff 'https://${URL}/forticloud_jsonrpc_login/' \
--data '{
    "access_token": "'"$access_token"'"
}' | jq -r '.session')
