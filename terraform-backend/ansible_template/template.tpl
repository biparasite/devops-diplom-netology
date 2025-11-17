all:
  children:
    Control_node:
      hosts:
%{ for k, ip in Control_node ~}
        controlnode${k + 1}:
          ansible_host: ${ip}
          ansible_user: biparasite
%{ endfor ~}
    Worker_node:
      hosts:
%{ for k, ip in Worker_node ~}
        worknode${k + 1}:
          ansible_host: ${ip}
          ansible_user: biparasite
%{ endfor ~}
