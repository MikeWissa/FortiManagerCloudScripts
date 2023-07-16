#!/bin/bash
# In this example we login to FortiManager Cloud and Create a Policy Package, Device Group, Template Group, Device Blue Print, Add a device using pre-shared key
# loads the environment variable
# This script is intended to be used with the FortiManager Cloud API
source .env
source subfunctions36.sh


# Read login payload from file
template=$(<login_payload.json)
declare -A csv_data
declare -A row_data
declare -A metadatavars
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
    if $debug; then
    debugoption="--trace-ascii ./logs/getsessionid-$(date +'%Y-%m-%d_%H_%M_%S').log"
    fi
    session=$(curl -s --location --globoff $LOGINURL \
    --data '{
        "access_token": "'"$access_token"'"
    }' | jq -r '.session')
    if $debug; then
    sleep 2
    fi
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


device_blueprint_add()  {
    response=$(subfunc "device_blueprint_add")
    if jq -e . <<<"$response" >/dev/null 2>&1; then
        parsed_json=$(jq .<<<"$response")
        echo "Parsed JSON" $parsed_json
        if [[ $(printf '%s\n' "$parsed_json") =~ .*\"message\":\ \"OK\"* ]]; then
        echo "exists already"
        else
        echo "does not exist"
        fi
    else
        echo -e "\e[31m***** Error Processing dDding Serial Number, JSON output received is invalid ****\e[0m"
        escaped_string=$(printf "%q" "$response")
        echo "Error adding blue print, this is the output that was returned $escaped_string" >> error.log
    fi
}

# generic function to check if element exists
generic_get_url () {
    response=$(subfunc "generic_url" $1)
     if jq -e . <<<"$response" >/dev/null 2>&1; then
        parsed_json=$(jq .<<<"$response")
        echo "Parsed JSON" $parsed_json
        if [[ $(printf '%s\n' "$parsed_json") =~ .*\"message\":\ \"OK\"* ]]; then
        echo "exists already"
        else
        echo "does not exist"
        fi
    else
        echo -e "\e[31m***** Error Processing dDding Serial Number, JSON output received is invalid ****\e[0m"
        escaped_string=$(printf "%q" "$response")
        echo "Error with getting url, this is the output that was returned" "$escaped_string" >> error.log
    fi
}

# Function to add device group leveraging mycurlbuilder
device_group_add() {
    response=$(subfunc "device_group_add")
    if jq -e . <<<"$response" >/dev/null 2>&1; then
        parsed_json=$(jq .<<<"$response")
        echo "Parsed JSON" $parsed_json
        if [[ $(printf '%s\n' "$parsed_json") =~ .*\"message\":\ \"OK\"* ]]; then
        echo "exists already"
        else
        echo "does not exist"
        fi
    else
        escaped_string=$(printf "%q" "$response")
        echo -e "\e[31m***** Error Processing dDding Serial Number, JSON output received is invalid ****\e[0m"
        echo "Error adding device group, this is the output that was returned $escaped_string" >> error.log
    fi
}

device_model_add_by_psk() {
    response=$(subfunc "device_model_add_by_psk")
    if jq -e . <<<"$response" >/dev/null 2>&1; then
        parsed_json=$(jq .<<<"$response")
        echo "Parsed JSON" $parsed_json
        if [[ $(printf '%s\n' "$parsed_json") =~ .*\"message\":\ \"OK\"* ]]; then
        echo "exists already"
        else
        echo "does not exist"
        fi
    else
        escaped_string=$(printf "%q" "$response")
        echo -e "\e[31m***** Error Processing dDding Serial Number, JSON output received is invalid ****\e[0m"
        echo "Error adding device model for device $device_name by psk, this is the output that was returned $escaped_string" >> error.log
    fi
}

device_model_add_by_sn() {
    response=$(subfunc "device_model_add_by_sn")
    if jq -e . <<<"$response" >/dev/null 2>&1; then
        parsed_json=$(jq .<<<"$response")
        echo "Parsed JSON" $parsed_json
        if [[ $(printf '%s\n' "$parsed_json") =~ .*\"message\":\ \"OK\"* ]]; then
        echo "exists already"
        else
        echo "does not exist"
        fi
    else
        escaped_string=$(printf "%q" "$response")
        echo -e "\e[31m***** Error Processing dDding Serial Number, JSON output received is invalid ****\e[0m"
        echo "Error adding device model for device $device_name by SN, this is the output that was returned $escaped_string" >> error.log
    fi
}

policy_package_add(){
    response=$(subfunc "policy_package_add")
    if jq -e . <<<"$response" >/dev/null 2>&1; then
        parsed_json=$(jq .<<<"$response")
        echo "Parsed JSON" $parsed_json
        if [[ $(printf '%s\n' "$parsed_json") =~ .*\"message\":\ \"OK\"* ]]; then
        echo "exists already"
        else
        echo "does not exist"
        fi
    else
        escaped_string=$(printf "%q" "$response")
        echo -e "\e[31m***** Error Processing dDding Serial Number, JSON output received is invalid ****\e[0m"
        echo "Error adding policy package $policy_package, this is the output that was returned $escaped_string" >> error.log
    fi
}

check_if_metadata_var_exists() {
    response=$(subfunc "generic_url" "/pm/config/adom/root/obj/fmg/variable/'"${metadatavars[metadata_variable_name]}"'" $1)
     if jq -e . <<<"$response" >/dev/null 2>&1; then
        parsed_json=$(jq .<<<"$response")
        echo "Parsed JSON" $parsed_json
        $2 ||  if [[ $(printf '%s\n' "$parsed_json") =~ .*$2* ]]; then
        echo "exists already"
        else
        echo "does not exist"
        fi
    else
        echo -e "\e[31m***** Error Processing dDding Serial Number, JSON output received is invalid ****\e[0m"
        escaped_string=$(printf "%q" "$response")
        echo "Error with getting url, this is the output that was returned" "$escaped_string" >> error.log
        fi
}

bulk_add_meta_variables() {
    # loop over csv data and create variables
    for key in "${!csv_data[@]}"; do
    eval "$key"="${csv_data[$key]}"
    eval "metadatavars["$key"]="${csv_data[$key]}""
    done

    # Check if metavariable already exist
    # this passes the paramter to the already pre-made function that would return exists already if it exists
    response1=$(generic_get_url "/pm/config/adom/root/obj/fmg/variable/$metadata_variable_name")

    # Check if the response contains the string exists already
    if [[ $response1 == *"exists already"* ]]; then
            # Notify the user that the variable
            echo "variable exists $metadata_variable_name already exist and will not be create, skipping"
            
            # Check value of dynamic mapping to validate value matches
            # This means we need to check the dynamic mapping to verify that the record we have is the same as the one in the system
            # This is done by checking the value of the dynamic mapping
            # we first make a call to get the json values relating to the mapping
            parsed_json2=$(subfunc "generic_url" "/pm/config/adom/root/obj/fmg/variable/$metadata_variable_name")
            # we then check if the json is valid
            if jq -e . <<<"$parsed_json2" >/dev/null 2>&1; then
            # We then need to get the length of the dynamic mapping, there could be multiple mappings for different firewalls
            len=$(echo $parsed_json2 | jq '.result[0].data.dynamic_mapping | length')
            
            for ((i=0;i<$len;i++)); do
            found=null
                name=$(echo $parsed_json2 | jq -r ".result[0].data.dynamic_mapping[$i]._scope[0].name")
                vdom=$(echo $parsed_json2 | jq -r ".result[0].data.dynamic_mapping[$i]._scope[0].vdom")
                value=$(echo $parsed_json2 | jq -r ".result[0].data.dynamic_mapping[$i].value")
                
                # This will compare to verify that all relevant mapping values match
                if [ "$name" = "$firewall_name" ] && [ "$vdom" = "$firewall_vdom" ] && [ "$value" = "$metadata_variable_value" ]; then
                    
                    found="true"
                    echo "found match for name: $name and value: $value"
                    break
                fi
            done
            # if found is null
                if [ "$found" = "null" ]; then
                    echo "metavariable for this firewall $firewall_name with the value $metadata_variable_name and $metadata_variable_value have changed, and will need to updated"
                    response3=$(subfunc "add_meta_variable_mapping")
                    parsed_json3=$(jq .<<<"$response3")
                    #echo "Parsed JSON" $parsed_json3
                    if [[ $(printf '%s\n' "$parsed_json3") =~ .*\"message\":\ \"OK\"* ]]; then
                        echo "dynamic mapping was created"
                        else
                        escaped_string3=$(printf "%q" "$response3")
                        echo -e "\e[31m***** Error creating metavariable mapping, JSON output received is invalid ****\e[0m"
                        echo "Error with creating $metadata_variable_name, this is the output that was returned" "$escaped_string3" >> error.log
                    fi
                fi
            fi


            
    else
        echo "variable does not exist, we will need to  create the $metadata_variable_name variable"
        response4=$(subfunc "add_meta_variable")
            if jq -e . <<<"$response4" >/dev/null 2>&1; then
                parsed_json4=$(jq .<<<"$response4")
                echo "Parsed JSON" $parsed_json4
                if [[ $(printf '%s\n' "$parsed_json4") =~ .*\"message\":\ \"OK\"* ]]; then
                echo "metavariable object $metadata_variable_name  was created"
                    response5=$(subfunc "add_meta_variable_mapping")
                    parsed_json5=$(jq .<<<"$response5")
                    echo "Parsed JSON" $parsed_json5
                    if [[ $(printf '%s\n' "$parsed_json5") =~ .*\"message\":\ \"OK\"* ]]; then
                        echo "dynamic mapping was created"
                        else
                        escaped_string5=$(printf "%q" "$response5")
                        echo -e "\e[31m***** Error creating metavariable mapping, JSON output received is invalid ****\e[0m"
                        echo "Error with creating $metadata_variable_name, this is the output that was returned" "$escaped_string5" >> error.log
                    fi
                else
                escaped_string4=$(printf "%q" "$response4")
                echo -e "\e[31m***** Error creating metavariable objectr, JSON output received is invalid ****\e[0m"
                echo "Error with creating $metadata_variable_name, this is the output that was returned" "$escaped_string4" >> error.log
                fi
            fi

    fi    
}

parse_csv() {
  local filename=$1
  local func=$2
  local headers=()
  local values=()
  local index=0

  if [[ ! -f $filename || ! -r $filename ]]; then
    echo "Error: File '$filename' does not exist or is not readable."
    return 1
  fi

  dos2unix "$filename"

  while IFS=, read -r -a line
  do
    if ((index == 0)); then
      headers=("${line[@]}")
    else
      values=("${line[@]}")
      for ((i=0; i<${#headers[@]}; ++i)); do
        csv_data["${headers[$i]}"]="${values[$i]}"
      done
      eval "$func"
    fi
    ((++index))
  done < "$filename"
}

# Function to process the variables from the CSV
process_variables() {
  for key in "${!csv_data[@]}"; do
    eval "$key"="${csv_data[$key]}"
    eval "row_data["$key"]="${csv_data[$key]}""
     
  done

    echo "devie_name: $device_name"
    echo "device_group: $device_group"
    echo "device_sn: $device_sn"
    echo "policy_package: $policy_package"
    echo "blue_print: $blue_print"
    echo "platform_type: $platform_type"
    echo "min_ver: $min_ver"
    echo "template_group: $template_group"
    echo "psk_name: $psk_name"
    
    if [[ $(generic_get_url "dvmdb/adom/root/group/$device_group") == *"exists already"* ]]; then
        echo -e "\e[32mDevice Group $device_group already exists\e[0m"
    else
        device_group_add 
    fi

    #check if the policy package exist if not create it
    if [[  $(generic_get_url "/pm/pkg/adom/root/$policy_package") == *"exists already" ]]; then
        echo -e "\e[32mPOlicy Package $policy_package already exists\e[0m"
    else
        policy_package_add
    fi

    #check kthe device blue print exist if not create it
    #if [[ $(api_check "dvmdb/adom/root/device_blueprint/$blue_print") == *"exists already"* ]]; then
    if [[ $(generic_get_url "pm/config/adom/root/obj/fmg/device/blueprint/$blue_print") == *"exists already"* ]]; then
        echo -e "\e[32mDevice Blueprint $blue_print already exists\e[0m"
    else
        device_blueprint_add
    fi

    # if the device_sn is not none then add device by sn
    if [ "$device_sn" != "none" ]; then
    if [[ $(generic_get_url "dvmdb/adom/root/device/$device_name") == *"exists already" ]]; then
    echo -e "\e[32mDevice $device_name already exists\e[0m"
    else
    device_model_add_by_sn
    fi
    fi
    if [ "$device_sn" == "none" ]; then
    if [[ $(generic_get_url "dvmdb/adom/root/device/$device_name") == *"exists already" ]]; then
    echo -e "\e[32mDevice $device_name already exists\e[0m"
    else
    device_model_add_by_psk
    fi
    fi
}

# This is the main routine
mainroutine() {
    echo "=================================================================="
    echo "=========Fortimanager cloud automation tool======================="
    echo "=================================================================="
    echo " "
options=("Login to FortiManager Cloud" \
"Create firewall objects based on variable.csv" \
"Add metadata variable" \
"Enable Debugging" \
"Disable Debugging" \
"Manual Get URL" \
"Manual Get URL with Filter Attribute" \
"Quit")
declare -A vars
while true; do
select opt in "${options[@]}"
do
    case $opt in
        "Login to FortiManager Cloud")
            echo "You are logged into FortiManager Cloud"
            Get_access_token
            Get_session_id
            read -n1 -r -p "Press any key to continue..." key
            printmenu
            ;;
        "Create firewall objects based on variable.csv")
            Get_access_token
            Get_session_id
            variablefilename="variables-3.csv"
            parse_csv "$variablefilename" "process_variables"
            read -n1 -r -p "Press any key to continue..." key
            printmenu
            ;;
        "Add metadata variable")
            Get_access_token
            Get_session_id
            #echo "You chose Add metdata variable"
            metavarsfilename="metavars.csv"
            # check if the metadata variable file exists
            if [[ -f $metavarsfilename ]]; then
            parse_csv "$metavarsfilename" "bulk_add_meta_variables"
            read -n1 -r -p "Press any key to continue..." key
            else
            echo "Error: File '$metavarsfilename' does not exist or is not readable."
            read -n1 -r -p "Press any key to continue..." key
            fi
            printmenu
            ;;
        "Enable Debugging")
            echo "You chose Enable Debugging"
            debug="true"
            Get_access_token
            Get_session_id
            read -n1 -r -p "Press any key to continue..." key
            printmenu
            ;;
        "Disable Debugging")
            echo "You chose Disable Debugging"
            debug=null
            Get_access_token
            Get_session_id
            read -p "Do you want to delete logs? (y/n) " choice
            case "$choice" in
            y|Y ) rm ./logs/*;;
            n|N ) echo "Logs not deleted.";;
            * ) echo "Invalid choice.";;
            esac
            read -n1 -r -p "Press any key to continue..." key
            printmenu
            ;;
        "Manual Get URL")
            Get_access_token
            Get_session_id
            echo "You chose Generic Get URL"
            read -p "Enter URL: " url
            manual_get_url $url
            read -n1 -r -p "Press any key to continue..." key
            printmenu
            ;;
        "Manual Get URL with Filter Attribute")
            Get_access_token
            Get_session_id
            echo "You chose Generic Get URL"
            read -p "Enter URL: " url
            read -p "Enter Filter Attribute: " filter
            read -p "Enter Filter Value: " filter_value
            manual_get_url_filtered $url $filter $filter_value
            read -n1 -r -p "Press any key to continue..." key
            printmenu
            ;;
        "Quit")
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
done
}

printmenu() {
clear
echo "=================================================================="
echo "=========Fortimanager cloud automation tool======================="
echo "=================================================================="
echo " "
echo "1) Login to FortiManager Cloud"
echo "2) Create firewall objects based on variable.csv"
echo "3) Add metdata variable"
echo "4) Enable Debugging"
echo "5) Disable Debugging"
echo "6) Generic Get URL"
echo "7) Generic Get URL with Filter Attribute"
echo "8) Quit"
}
mainroutine
