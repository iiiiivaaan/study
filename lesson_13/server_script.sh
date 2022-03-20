#!/bin/bash
yum install epel-release -y
yum install ansible vim -y
mkdir -p /home/vagrant/ansible/roles
mkdir -p /home/vagrant/ansible/inventory

cat << EOF > /home/vagrant/ansible/inventory/hosts
[client]
192.168.50.11
[client:vars]
ansible_user=vagrant
ansible_ssh_pass=vagrant
http_port=8080
EOF

cat << EOF > /home/vagrant/.ansible.cfg
[defaults]
remote_user = 'vagrant'
roles_path = ~/ansible/roles
inventory = ~/ansible/inventory/
log_path = ~/ansible/log_ansible/ansible.log
retry_files_enabled = False
interpreter_python = auto_legacy_silent
host_key_checking = false

[privilege_escalation]
become=True
become_allow_same_user = True
EOF

ansible-galaxy init /home/vagrant/ansible/roles/install_nginx

cat << EOF > /home/vagrant/ansible/roles/install_nginx/handlers/main.yml
---

- name: Restart nginx
  ansible.builtin.service:
    name: nginx
    state: restarted
EOF

cat << EOF > /home/vagrant/ansible/roles/install_nginx/tasks/main.yml
---

- name: Install the latest version of epel-release
  yum:
    name: epel-release
    state: latest

- name: Install the latest version of Nginx
  yum:
    name: nginx
    state: latest

- name: Enable nginx sevice
  ansible.builtin.service:
    name: nginx
    enabled: yes

- name: Copy nginx config
  ansible.builtin.template:
    src: /home/vagrant/ansible/roles/install_nginx/templates/client.conf.j2
    dest: /etc/nginx/conf.d/client.conf
  notify: Restart nginx
EOF

cat << EOF > /home/vagrant/ansible/roles/install_nginx/templates/client.conf.j2
    server {
        listen       {{ http_port }};
        server_name  client.local;
        root         /usr/share/nginx/html;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
EOF

cat << EOF > /home/vagrant/ansible/playbook.yml
---

- hosts: all
  gather_facts: yes
  become: yes
  roles:
    - install_nginx
EOF

chown -R vagrant:vagrant /home/vagrant/
