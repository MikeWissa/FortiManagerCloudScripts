#!/bin/bash
# create a function that takes a string and returns a list of commands to return back to the calling function
subfunc() {
    # process the input string
    case $1 in
        "generic_url")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 4-generic-get-url.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|url_path|'"$2"'|g')" \
             ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})
            printf '%s\n' "$output"
            ;;
        "manual_get_url")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 4-generic-get-url.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|url_path|'"$2"'|g')" \
             ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})
            printf '%s\n' "$output"
            ;;
        "add_meta_variable_mapping")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 7-add-meta-variable-mapping.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|metadata_variable_name|'"${metadatavars[metadata_variable_name]}"'|g' \
            | sed 's|metadata_variable_value|'"${metadatavars[metadata_variable_value]}"'|g' \
            | sed 's|firewall_name|'"${metadatavars[firewall_name]}"'|g' \
            | sed 's|firewall_vdom|'"${metadatavars[firewall_vdom]}"'|g' \
            ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})")
            printf '%s\n' "$output"
            ;;
        "add_meta_variable")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 6-add-meta-variable.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|metadata_variable_name|'"${metadatavars[metadata_variable_name]}"'|g' \
            ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})")
            printf '%s\n' "$output"
            ;;
        "device_group_add")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 1-add-device-group.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|device_group_name|'"${row_data[device_group]}"'|g')" \
             ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})
            printf '%s\n' "$output"
            ;;
        "device_blueprint_add")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 2-add-blueprint.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|blue_print|'"${row_data[blue_print]}"'|g' \
            | sed 's|device_group|'"${row_data[device_group]}"'|g' \
            | sed 's|policy_package|'"${row_data[policy_package]}"'|g' \
            | sed 's|platform_type|'"${row_data[platform_type]}"'|g' \
            | sed 's|min_ver|'"${row_data[min_ver]}"'|g' \
            | sed 's|template_group|'"${row_data[template_group]}"'|g')" \
             ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})
            printf '%s\n' "$output"
            ;;
        "policy_package_add")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 0-add-policy-package.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|policy_package_name|'"${row_data[policy_package]}"'|g')" \
             ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})
            printf '%s\n' "$output"
            ;;
        "device_model_add_by_psk")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 3-add-device-model-psk-1.1.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|device_group|'"${row_data[device_group]}"'|g' \
            | sed 's|device_name|'"${row_data[device_name]}"'|g' \
            | sed 's|platform_type|'"${row_data[platform_type]}"'|g' \
            | sed 's|prefer_img_version|'"${row_data[min_ver]}"'|g' \
            | sed 's|blue_print|'"${row_data[blue_print]}"'|g' \
            | sed 's|psk_value|'"${row_data[psk_name]}"'|g')" \
             ${debug:+--trace-ascii "logs\$1-$(date +'%Y-%m-%d')"})
            printf '%s\n' "$output"
            ;;
        "device_model_add_by_sn")
            output=$(curl -s --globoff "$RPCURL" \
            --data "$(cat 3-add-device-model-sn-1.2.yaml \
            | sed 's|session_id|'"$session"'|g' \
            | sed 's|device_name|'"${row_data[device_name]}"'|g' \
            | sed 's|blue_print|'"${row_data[blue_print]}"'|g' \
            | sed 's|platform_type|'"${row_data[platform_type]}"'|g' \
            | sed 's|min_ver|'"${row_data[min_ver]}"'|g' \
            | sed 's|device_sn|'"${row_data[device_sn]}"'|g' \
            | sed 's|device_group|'"${row_data[device_group]}"'|g')" \
             ${debug:+--trace-ascii "$1-$(date +'%Y-%m-%d')"})
            printf '%s\n' "$output"
            ;;
        esac
}
