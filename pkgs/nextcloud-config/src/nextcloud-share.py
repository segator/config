#!/usr/bin/env python

import os
import yaml
import subprocess
import json

def run_occ_command(command_args):
    result = subprocess.run(command_args, capture_output=True, text=True)
    return json.loads(result.stdout)

def update_share_configuration(mount_id, configurations):
    update_share_configuration_or_option('config',mount_id,configurations)

def update_share_option(mount_id):
    options = {
        "encrypt": "true",
        "previews": "true",
        "enable_sharing": "true",
        "filesystem_check_changes": 1,
        "encoding_compatibility": "false",
        "readonly": "false"
    }
    update_share_configuration_or_option('option',mount_id,options)

def update_share_configuration_or_option(verb, mount_id, options):
    for key, value in options.items():
        subprocess.run([
            *occ_command.split(), f'files_external:{verb}',
            str(mount_id),
            key, str(value)
        ])


def manage_share_groups(mount_id, groups):
    current_groups = run_occ_command([
        *occ_command.split(), 'files_external:applicable',
        str(mount_id), '--output=json'
    ])['groups']

    groups_to_add = set(groups) - set(current_groups)
    groups_to_remove = set(current_groups) - set(groups)

    for group in groups_to_add:
        subprocess.run([
            *occ_command.split(), 'files_external:applicable',
            str(mount_id), '--add-group', group
        ])

    for group in groups_to_remove:
        subprocess.run([
            *occ_command.split(), 'files_external:applicable',
            str(mount_id), '--remove-group', group
        ])

config_file_path = os.getenv('CONFIG_PATH', '/etc/nextcloud-config/share-config.yaml')
occ_command = os.getenv('OCC_COMMAND', 'sudo -u www-data php occ')

with open(config_file_path, 'r') as file:
    config = yaml.safe_load(file)

desired_shares = config['shares']

current_shares_dict = {share['mount_point']: share for share in run_occ_command([*occ_command.split(), 'files_external:list', '--output=json'])}

for share_name, share_info in desired_shares.items():
    mount_point = f"/{share_name}"
    path = share_info['path']
    groups = share_info['groups']

    if mount_point in current_shares_dict:        
        current_share = current_shares_dict[mount_point]

        if current_share['configuration']['datadir'] != path:
            print(f"Updating datadir for share {mount_point}")
            update_share_configuration(current_share['mount_id'], {'datadir': path})
        
        
        update_share_option(current_share['mount_id'])

        manage_share_groups(current_share['mount_id'], groups)
    else:
        print(f"Creating new share {mount_point}")

        subprocess.run([
            *occ_command.split(), 'files_external:create',
            mount_point, 'local', 'null::null',
            '--config', f'datadir={path}'
        ])
        new_mount_id = run_occ_command([*occ_command.split(), 'files_external:list', '--output=json'])
        new_mount_id = next(item for item in new_mount_id if item['mount_point'] == mount_point)['mount_id']

        update_share_option(new_mount_id)
        manage_share_groups(new_mount_id, groups)

for mount_point, share in current_shares_dict.items():
    if mount_point not in [f"/{name}" for name in desired_shares.keys()]:
        print(f"Removing share {mount_point}")
        subprocess.run([*occ_command.split(), 'files_external:delete', str(share['mount_id']), "--yes"])