#!/usr/bin/env python

import os
import yaml
import subprocess
import json

def run_occ_command(command_args):
    result = subprocess.run(command_args, capture_output=True, text=True)
    return json.loads(result.stdout)

def create_or_update_group(groupname):
    groups = run_occ_command([*occ_command.split(), 'group:list', '--output=json'])
    if groupname in groups:
        print(f"Group {groupname} already exists.")
    else:
        print(f"Creating group {groupname}")
        subprocess.run([*occ_command.split(), 'group:add', groupname])

def remove_group(groupname):
    groups = run_occ_command([*occ_command.split(), 'group:list', '--output=json'])
    if groupname in groups:
        print(f"Removing group {groupname}")
        subprocess.run([*occ_command.split(), 'group:delete', groupname])
    else:
        print(f"Group {groupname} does not exist.")

config_file_path = os.getenv('CONFIG_PATH', '/etc/nextcloud-config/group-config.yaml')
occ_command = os.getenv('OCC_COMMAND', 'sudo -u www-data php occ')

with open(config_file_path, 'r') as file:
    config = yaml.safe_load(file)

desired_groups = config.get('groups', {})

for groupname in desired_groups:
    create_or_update_group(groupname)

# Remove groups not in the desired configuration
current_groups = run_occ_command([*occ_command.split(), 'group:list', '--output=json'])
for groupname in current_groups:
    if groupname not in desired_groups:
        if groupname == "admin":
            continue
        remove_group(groupname)
