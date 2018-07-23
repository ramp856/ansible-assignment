---
- name: Provision Production env
  hosts: jumpbox
  gather_facts: true
  become: yes
  tasks: 
  - name: Install latest version of jq
    yum: 
      name: jq
      state: latest
  - name: create bin directory
    file: 
      path: "{{ ansible_env.HOME }}/bin"
      state: directory
      mode: 0755
  - name: download common.sh and order_svc.sh
    get_url:
      url: http://www.opentlc.com/download/ansible_bootcamp/scripts/{{item }}
      dest: "{{ ansible_env.HOME }}/{{ item }}"
      mode: 0755
    with_items:
    - common.sh
    - order_svc.sh
  - name: download jq-linux64
    shell: "wget http://www.opentlc.com/download/ansible_bootcamp/scripts/jq-linux64 -O {{ anisble_env.HOME }}/bin/jq"
  - name: change mode +x
    shell: "chmod +x {{ ansible_env.HOME }}/order_svc.sh {{ ansible_env.HOME }}/bin/jq"
  - name: create credentials.rc
    template:
    src: credentials.rc.j2
    dest: "{{ ansible_env.HOME }}/credentials.rc"
  - name: Deploy production env in OPENTLC
    shell: "source {{ ansible_env.HOME }}/credentials.rc && {{ ansible_env.HOME }}/order_svc.sh -c 'OPENTLC Automation' -i '3 Tier Application' -t 1 -y"
  - name: Pause for 15 min for the env to come up
    pause:
      minutes: 15
