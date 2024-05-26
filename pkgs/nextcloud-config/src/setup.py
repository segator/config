from setuptools import setup, find_packages

with open('requirements.txt') as f:
    install_requires = f.read().splitlines()

setup(
  name='nextcloud-config',  
  version='0.1.0',
  
  install_requires=install_requires,
  scripts=[
    'nextcloud-share.py',
    'nextcloud-group.py',
    'nextcloud-user.py'
  ],  
   packages=find_packages(),
)