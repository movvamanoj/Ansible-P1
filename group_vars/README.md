# Ansible-P1

<!-- group_vars/production.yml: -->

---
web_servers:
  - linux_web_server
  - windows_web_server

database_servers:
  - linux_database_server
  - windows_database_server

common_variable: "This is a variable common to all hosts in production."


<!-- group_vars/production/linux_web_server.yml: -->
---
specific_variable: "This is a variable specific to the Linux web server."

<!-- group_vars/production/windows_web_server.yml: -->
---
specific_variable: "This is a variable specific to the Windows web server."

<!-- playbooks/setup_servers.yml -->

---
- name: Set up web servers
  hosts: web_servers
  become: yes
  roles:
    - web_server

<!-- 
In the above playbook section, Ansible will use the variables defined in group_vars/production.yml for all web servers. If the playbook is applied to a Linux web server, it will also use the variables from group_vars/production/linux_web_server.yml. -->
