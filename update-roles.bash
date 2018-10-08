#!/usr/bin/env bash

# Install and/or update all roles
# --force is needed to do an update of installed roles :-/

ansible-galaxy install -r requirements.yml \
  -p ext-roles \
  --force \
  --verbose \
  --no-deps # Ignore any role dependancies

# NOTE: --no-deps is used to keep the control of dependent role versions in own hands.
#       If the included role includes some dependencies in metadata, they need to be
#       added in requirements.yml.

# Need to remove this metadata or otherwise geerlingguy.java dependency causes trouble
rm ext-roles/ansible-role-jenkins/meta/main.yml
