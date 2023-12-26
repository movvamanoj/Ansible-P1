#!/usr/bin/env python

import os

# Fetch IP addresses dynamically from Harness variables
ip_addresses = os.environ.get('HARNESS_IP_ADDRESSES', '').split(',')

# Fetch group-specific variables dynamically from Harness variables
ansible_user = os.environ.get('HARNESS_ANSIBLE_USER', 'default_user')
ansible_password = os.environ.get('HARNESS_ANSIBLE_PASSWORD', 'default_password')
ansible_port = os.environ.get('HARNESS_ANSIBLE_PORT', '5985')
ansible_connection = os.environ.get('HARNESS_ANSIBLE_CONNECTION', 'winrm')
ansible_winrm_transport = os.environ.get('HARNESS_ANSIBLE_WINRM_TRANSPORT', 'ntlm')
ansible_winrm_server_cert_validation = os.environ.get('HARNESS_ANSIBLE_WINRM_SERVER_CERT_VALIDATION', 'ignore')

# Specify the directory where hosts.ini should be created
inventory_directory = "inventory"

# Generate hosts.ini content with the specified group and dynamic variables
inventory_content = f"[win]\n" + "\n".join(ip_addresses) + f"""
[win:vars]
ansible_user={ansible_user}
ansible_password={ansible_password}
ansible_port={ansible_port}
ansible_connection={ansible_connection}
ansible_winrm_transport={ansible_winrm_transport}
ansible_winrm_server_cert_validation={ansible_winrm_server_cert_validation}
"""

# Save to hosts.ini file in the specified directory
inventory_file_path = os.path.join(inventory_directory, 'hosts.ini')
with open(inventory_file_path, 'w', encoding='utf-8') as file:
    file.write(inventory_content)

print(f"Dynamic inventory file created at: {inventory_file_path}")


#!/bin/bash

# Set Harness environment variables
# export HARNESS_IP_ADDRESSES=""
# export HARNESS_ANSIBLE_USER="p"
# export HARNESS_ANSIBLE_PASSWORD="!"
# export HARNESS_ANSIBLE_PORT="5985"
# export HARNESS_ANSIBLE_CONNECTION="winrm"
# export HARNESS_ANSIBLE_WINRM_TRANSPORT="ntlm"
# export HARNESS_ANSIBLE_WINRM_SERVER_CERT_VALIDATION="ignore"

# Execute the Python script
# python3 inventory/harness_inventory.py
