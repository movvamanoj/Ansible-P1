# Ansible-P1

# roles/common_role/tasks/main.yml:

---
- name: Ensure essential packages are installed
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - vim
    - htop
    - curl
    - unzip




# roles/web_server/tasks/main.yml:

---
- name: Include common tasks from common_role
  include_role:
    name: common_role

- name: Install Nginx
  apt:
    name: nginx
    state: present



# roles/database_server/tasks/main.yml:


---
- name: Include common tasks from common_role
  include_role:
    name: common_role

- name: Install PostgreSQL
  apt:
    name: postgresql
    state: present


# playbooks/setup_servers.yml:

---
- name: Set up web servers and database servers
  hosts: servers
  become: yes

  roles:
    - web_server
    - database_server


# ansible-playbook -i inventory/hosts.ini playbooks/setup_servers.yml
