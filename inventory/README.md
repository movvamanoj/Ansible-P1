# Ansible-P1



; [python_servers]
; 3.14.79.114 
; [python_servers:vars]
; ansible_user=Administrator
; ansible_password=@VfSlGs2N?Uj3Amaj-UQsP-NW.3mpZcp
; ansible_port=5985
; ; ansible_port: 5986
; ansible_connection=winrm
; ansible_winrm_server_cert_validation=ignore
; ; ansible_winrm_transport: basic
; ansible_winrm_transport=ntlm
; ansible_winrm_kerberos_delegation=true
; ; ansible_winrm_operation_timeout_sec=60


; [windows_servers]
; 3.134.117.90 ansible_user=Administrator ansible_password=T)EW?lig%A?FQJlhp.Fr5d9a43kCzEeE ansible_port=5985 ansible_connection=winrm ansible_winrm_server_cert_validation=ignore ansible_winrm_transport=ntlm ansible_winrm_kerberos_delegation=true
; [python_servers]
; 3.14.79.114 ansible_user=Administrator ansible_password=@VfSlGs2N?Uj3Amaj-UQsP-NW.3mpZcp ansible_port=5986 ansible_connection=winrm ansible_winrm_server_cert_validation=ignore ansible_winrm_transport=basic ansible_winrm_kerberos_delegation=true



[windows_servers]
3.134.117.90 


[windows_servers:vars]
ansible_user=Administrator
ansible_password=T)EW?lig%A?FQJlhp.Fr5d9a43kCzEeE
ansible_port=5985
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
ansible_winrm_transport=ntlm
ansible_winrm_kerberos_delegation=true

[python_servers]
3.14.79.114 

[python_servers:vars]
ansible_user=Administrator
ansible_password="@VfSlGs2N?Uj3Amaj-UQsP-NW.3mpZcp"
ansible_port=5985
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
ansible_winrm_transport=ntlm
ansible_winrm_kerberos_delegation=true
