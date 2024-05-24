#!/usr/bin/env python

import os
import yaml
import subprocess
import json

config_file_path = os.getenv('CONFIG_PATH', 'config.yaml')
occ_command = os.getenv('OCC_COMMAND', 'sudo -u www-data php occ')

with open(config_file_path, 'r') as file:
    config = yaml.safe_load(file)

desired_shares = config['shares']

result = subprocess.run(
    [*occ_command.split(), 'files_external:list', '--output=json'],
    capture_output=True,
    text=True
)

current_shares = json.loads(result.stdout)

# Convert current shares to a dictionary for easier comparison
current_shares_dict = {
    share['mount_point']: share for share in current_shares
}

# Create or update shares based on configuration
for share_name, share_info in desired_shares.items():
    mount_point = f"/{share_name}"
    path = share_info['path']
    groups = share_info['groups']

    if mount_point in current_shares_dict:
        print(f"Share {mount_point} already exists. Checking for updates...")
        # Check if the current configuration matches the desired configuration
        current_config = current_shares_dict[mount_point]['configuration']
        current_options = current_shares_dict[mount_point]['options']
        current_groups = current_shares_dict[mount_point]['applicable_groups']

        if current_config['datadir'] != path:
            print(f"Updating datadir for share {mount_point}")
            subprocess.run([
                *occ_command.split(), 'files_external:option',
                str(current_shares_dict[mount_point]['mount_id']),
                'datadir', path,                
            ])
        
        if not current_options['enable_sharing']:
            print(f"Enabling sharing for share {mount_point}")
            subprocess.run([
                *occ_command.split(), 'files_external:option',
                str(current_shares_dict[mount_point]['mount_id']),
                'enable_sharing', 'true',                
            ])

        # Update applicable groups
        groups_to_add = set(groups) - set(current_groups)
        groups_to_remove = set(current_groups) - set(groups)

        for group in groups_to_add:
            subprocess.run([*occ_command.split(), 'files_external:applicable', str(current_shares_dict[mount_point]['mount_id']), '--add-group', group])

        for group in groups_to_remove:
            subprocess.run([*occ_command.split(), 'files_external:applicable', str(current_shares_dict[mount_point]['mount_id']), '--remove-group', group])
    else:
        print(f"Creating new share {mount_point}")

        subprocess.run([
            *occ_command.split(), 'files_external:create',
            mount_point,
            'local',
            'null::null',
            '--config', f'datadir={path}'
        ])
        # Get the new mount ID and set groups
        new_mount_id_result = subprocess.run(
            [*occ_command.split(), 'files_external:list', '--output=json'],
            capture_output=True,
            text=True
        )
        new_mount_id = json.loads(new_mount_id_result.stdout)
        new_mount_id = next(item for item in new_mount_id if item['mount_point'] == mount_point)['mount_id']

        subprocess.run([
            *occ_command.split(), 'files_external:option',
            str(new_mount_id),
            'enable_sharing', 'true',                
        ])
        
        for group in groups:
            subprocess.run([*occ_command.split(), 'files_external:applicable', str(new_mount_id), '--add-group', group])

# Remove shares that are not in the desired configuration
for mount_point, share in current_shares_dict.items():
    if mount_point not in [f"/{name}" for name in desired_shares.keys()]:
        print(f"Removing share {mount_point}")
        subprocess.run([*occ_command.split(), 'files_external:delete', str(share['mount_id']), "--yes"])
