#!/usr/bin/env python

import os
import yaml
import subprocess
import json

def run_occ_command(command_args):
    try:
        result = subprocess.run(command_args, capture_output=True, text=True, check=True)
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        return None

def create_or_update_user(username, password_file):
    with open(password_file, 'r') as file:
        password = file.read().strip()

    users = get_user_list()
    env = os.environ.copy()
    env['OC_PASS'] = password

    if username in users:
        print(f"User {username} already exists. Updating password...")
        subprocess.run([*occ_command.split(), 'user:resetpassword', '--password-from-env', username], env=env, check=True)
    else:
        print(f"Creating user {username}")
        subprocess.run([*occ_command.split(), 'user:add', '--password-from-env', username], env=env, check=True)

def remove_user(username):
    if username == 'admin':
        print("Skipping deletion of admin user.")
        return
    print(f"Removing user {username}")
    subprocess.run([*occ_command.split(), 'user:delete', username], check=True)


def get_user_list():
    result = run_occ_command([*occ_command.split(), 'user:list', '--output=json'])
    return result if result else []

def get_user_groups(users):
    user_info = {}
    for username in users:
        result = run_occ_command([*occ_command.split(), 'user:info', username, '--output=json'])
        if result:
            user_info[username] = result.get('groups', [])
    return user_info

def assign_group_membership(current_users_groups, desired_users_groups):
    for username, desired_groups in desired_users_groups.items():    
        current_user_groups = current_users_groups[username]
        for desired_group in desired_groups:
            if desired_group not in current_user_groups:
                print(f"Adding user {username} to group {desired_group}")
                subprocess.run([*occ_command.split(), 'group:adduser', desired_group, username], check=True)

        for current_group in current_user_groups:
            if current_group not in desired_groups:
                print(f"Removing user {username} from group {current_group}")
                subprocess.run([*occ_command.split(), 'group:removeuser', current_group, username], check=True)


config_file_path = os.getenv('CONFIG_PATH', '/etc/nextcloud-config/user-group-config.yaml')
occ_command = os.getenv('OCC_COMMAND', 'sudo -u www-data php occ')

with open(config_file_path, 'r') as file:
    config = yaml.safe_load(file)

desired_users = config.get('users', {})
desired_groups = config.get('groups', {})

# Create or update users
for username, user_info in desired_users.items():
    password_file = user_info.get('passwordFile')
    if password_file:
        create_or_update_user(username, password_file)

# Remove users not in the desired configuration
current_users = get_user_list()
for username in current_users:
    if username not in desired_users and username != 'admin':
        remove_user(username)

# Fetch user groups
current_users_groups = get_user_groups(desired_users.keys())

# Assign group memberships
desired_users_groups = {}
for group, info in desired_groups.items():
    for member in info["members"]:
        if member not in desired_users_groups:
            desired_users_groups[member] = []
        desired_users_groups[member].append(group)

assign_group_membership(current_users_groups, desired_users_groups)