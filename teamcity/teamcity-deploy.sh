#!/usr/bin/env bash

set -o xtrace
set -o errexit

# For file loop below.
shopt -s nullglob

LOCAL_PATH=`pwd`
ARTIFACT_PATH="/home/dev/tmp"



mkdir -p .ansible-playbook

cat <<EOT >  .ansible-playbook/inventory-file.yml

[$VARIABLE_HOST]
$IP_HOST ansible_connection=ssh ansible_port=2222 ansible_ssh_user=dev 

EOT

cat  .ansible-playbook/inventory-file.yml


cat <<EOT > .ansible-playbook/deploy.yml

- name: Deploy application
  hosts: "{{ variable_host | default('not') }}"
  tasks:

#  - name: Stop Nginx
#    command: sudo  /usr/sbin/service nginx stop


  - name: Synchronize artifact
    synchronize:
     src: /{{ local_path }}/
     dest: /{{ artifact_path }}/
     delete: yes
     recursive: yes
     rsync_opts:
      - "--exclude=.*"
      - "--exclude=teamcity"

# - name: Start Nginx
#    command: sudo /usr/sbin/service nginx  start

EOT

cat .ansible-playbook/deploy.yml


ansible-playbook .ansible-playbook/deploy.yml -e "artifact_path=$ARTIFACT_PATH local_path=$LOCAL_PATH variable_host=$VARIABLE_HOST"  -i .ansible-playbook/inventory-file.yml
