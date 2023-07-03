#!/bin/bash
# In this example we login to FortiManager Cloud and Create a Policy Package, Device Group, Template Group, Device Blue Print, Add a device using pre-shared key
# loads the environment variable
source .env
# Read login payload from file
template=$(<login_payload.json)

# declare -A vars for userid and userpass for correct substitution
declare -A vars
vars["userid"]=${userid}
vars["userpass"]=${userpass}

# Construct the URLs that we will use for the rest of the API calls
RPCURL="https://${FortiManagerHost}/jsonrpc"
LOGINURL="https://${FortiManagerHost}/p/forticloud_jsonrpc_login/"

# session file to be used
session_file="session.txt"

# access token file to be used
access_token_file="access_token.txt"

# specify session timeout in seconds
session_timeout=3600

# Substitute variables in the template to login to FortiManager Cloud
substitute_variables() {
  local result="$1"
  local var="$2"
  local value="${vars[$var]}"
  result="${result//\$$var/$value}"
  result="${result//$'\r'/}"
  echo "$result"
}

# Replace placeholders in the JSON template with variable values
for var in "${!vars[@]}"; do
  template=$(substitute_variables "$template" "$var" "${vars[$var]}")
done

# This fucnciton will get the access token from the access_token.txt file if it is not expired
Get_access_token() {
if [ -f "$access_token_file" ] && [ $(($(date +%s) - $(stat -c %Y "$access_token_file"))) -lt $session_timeout ]
then
    access_token=$(cat "$access_token_file")
else
# Get access token
access_token=$(curl -s --location --globoff 'https://customerapiauth.fortinet.com/api/v1/oauth/token/' --data "$template" | jq -r '.access_token')
if [ "$access_token" == "null" ]
then
    echo "Error: could not get access token"
    exit 1
else
echo $access_token > "$access_token_file"
fi
fi
}

# This function will get the session id from the session.txt file if it is not expired or create a new session id
Get_session_id() {
# Build the URLs that we will use for the rest of the API calls

if [ -f "$session_file" ] && [ $(($(date +%s) - $(stat -c %Y "$session_file"))) -lt $session_timeout ]
then
    session=$(cat "$session_file")
    
else
# Get session token
session=$(curl -s --trace-ascii test.log --location --globoff $LOGINURL \
--data '{
    "access_token": "'"$access_token"'"
}' | jq -r '.session')

# Check if session is empty IF it is empty then exit with error
if [ "$session" == "null" ]
then
    echo "Error: could not get session token"
    exit 1
else
echo $session > "$session_file"
fi 
fi
} 

# This function will create a policy package
policy_package_add() {
echo "adding Policy Package"
echo " "
curl -s --location --globoff $RPCURL --data \
"$(cat 0-set-policy-package.yaml | sed -e "s|session_id|$session|g" | sed "s|policy_package_name|$1|g")"
echo " "
echo "====================="
echo " "
}

# add device blue print
device_blueprint_add() {
echo "adding Device Blueprint"
echo " "
curl -s --trace-ascii test5.log --location --globoff $RPCURL --data \
"$(cat 2-add-blueprint.yaml \
| sed -e "s|session_id|$session|g" \
| sed "s|device_blueprint_name|$1|g" \
| sed "s|device_group_name|$2|g" \
| sed "s|pkg_name|$3|g" \
| sed "s|platform_name|$4|g" \
| sed "s|prefer_img_version|$5|g" \
| sed "s|template_group|$6|g")"
echo " "
echo "====================="
echo " "
}

# This function will add devicegroup
device_group_add() {
echo "adding Device Group"
echo " "
curl -s --location --globoff $RPCURL --data \
"$(cat 1-add-devicegroup.yaml \
| sed -e "s|session_id|$session|g" \
| sed "s|device_group_name|$1|g")"
echo " "
echo "====================="
echo " "
}

add_device_model() {
echo "adding Device"
echo " "
curl -s --location --globoff $RPCURL --data \
"$(cat 3-add-device.yaml \
| sed -e "s|session_id|$session|g" \
| sed "s|device_name|$1|g" \
| sed "s|platform_name|$2|g" \
| sed "s|prefer_img_version|$3|g" \
| sed "s|device_blueprint_name|$4|g" \
| sed "s|psk_value|$5|g")"
echo " "
echo "====================="
echo " "

}


# This function will parse the csv file and set the variables
Parse_csv() {
  IFS=$'\n'
  ((c=-1))
  for line in $(cat $1)
  do
  ((c++))
  if ((c==0)); then continue; fi
  IFS=','
  read  item device_group_name pkg_name device_blueprint_name device_name platform_name prefer_img_version template_group psk_value <<<${line}
    IFS=$'\n'

    policy_package_add ${pkg_name}
    
    device_group_add ${device_group_name}

    device_blueprint_add ${device_blueprint_name} ${device_group_name} ${pkg_name} ${platform_name} ${prefer_img_version} ${template_group}

    add_device_model ${device_name} ${platform_name} ${prefer_img_version} ${device_blueprint_name} ${psk_value}

 done
}

# Call the functions
Get_access_token
Get_session_id
Parse_csv "variables.csv"
