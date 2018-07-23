New Business for a TELECOM industry: Mitzicom

MitziCom being a telecom industry has asked you to lead a 30- to 40-hour proof-of-concept (POC) using Red Hat Ansible Tower. The purpose of the POC is to determine the feasibility of using Ansible Tower as a CI/CD tool for automating continuous deployment of an internal three-tier application on QA and production environments. Note that this requires maintaining several instances of the application and  MitziCom management requires that you include all of the items listed in these subsections in your POC.

Basic Requirements:
Need to have OpenTLC account to order VM's to complete this task with AWS credentials for Production Environment.
1. Openstack Platform Workstation: workstation-ede7.rhpds.opentlc.com
2. Ansible Tower Bastion: bastion.9748.example.opentlc.com
3. 3-Tier-App Bastion: bastion.150d.example.opentlc.com

Using The above environment you need to build a Openstack Platform and install a 3-tier-app (tomcat, HAproxy, Postgresql) and test the connectivity using the URL: http://127.0.0.1 or curl http://127.0.0.1 with port 80 to get desired output.

Openstack Setup:
GO to opentlc and order a Openstack Platform under your account.
Login to the workstation and fetch the openstack keys from the link below for public and private key authentications.
http://www.opentlc.com/download/ansible_bootcamp/openstack_keys/openstack.pub
http://www.opentlc.com/download/ansible_bootcamp/openstack_keys/openstack.pem
Using the playbooks create a openstack QA environment where you need to deploy the 3-tier-app on the same.
Once created delete the environment.

Ansible Tower:
Go to opentlc and order Ansible Tower platform under your account.
Login to the bastion and fetch the openstack keys from the link below for publick and private key authentications.
http://www.opentlc.com/download/ansible_bootcamp/openstack_keys/openstack.pub
http://www.opentlc.com/download/ansible_bootcamp/openstack_keys/openstack.pem
Create a Project and associate the desired SCM from GIT repo to get full access to all the necessary YAML files.
You need to have necessary credentials created in Ansible tower.

Credentials details:
cloud-user: Machine Login (private key)
OpenTLC: Machine Login (xyz-redhat.com, your_password)
OPENTLC_BASION_KEY: Machine Login (private key)
Three_Tier_Prod_Key: Machine Login (Dummy private key)

Jobs Template:
Create the following templates:
Create new Job Template, i.e. Provision_QA_OSP with the following settings:

    Inventory: Advanced_Ansible_Lab
    Project: Advanced_Ansible_Lab_Assignment
    Playbook: assignment_lab/Provision_OSP.yml
    Credential: cloud-user (Machine)
    Verbosity: 2

Create new Job Template, i.e. Config_3-tier-QA with the following settings:

    Inventory: Advanced_Ansible_Lab
    Project: Advanced_Ansible_Lab_Assignment
    Playbook: assignment_lab/Configure_3TA_OSP_QA.yml
    Credential: cloud-user (Machine)
    Verbosity: 2

Go to Ansible Tower INVENTORIES / AWS VM's / GROUPS and create new groups for

    frontends
    apps
    appdbs

Define the following variables for each of the newly created group

ansible_user: cloud-user
ansible_connection: ssh
ansible_ssh_common_args: '-o ProxyCommand="ssh -W %h:%p -q cloud-user@workstation-${GUID}.rhpds.opentlc.com"'

Create new Job Template, i.e. Clean_OSP_QA with the following settings:

    Inventory: Advanced_Ansible_Lab
    Project: Advanced_Ansible_Lab_Assignment
    Playbook: assignment_lab/cleanup_OSP-QA.yml
    Credential: cloud-user (Machine)
    Verbosity: 2

Create new credential type, i.e. OpenTLC

    Go to SETTINGS / CREDENTIAL TYPES

    The Input Configuration will be

    fields:
      - type: string
        id: username
        label: OpenTLC Username
      - secret: true
        type: string
        id: password
        label: OpenTLC Password
    required:
      - username
      - password

    The Injector Configuration will be

    extra_vars:
      opentlc_password: '{{ password }}'
      opentlc_username: '{{ username }}'

Create new credential with credential type OpenTLC, with your OpenTLC username and password

Create new Job Template, i.e. Production-OSP with the following settings:

    Inventory: Advanced_Ansible_Lab
    Project: Advanced_Ansible_Lab_Assignment
    Playbook: assignment_lab/Provision_OSP.yml
    Credential: cloud-user (Machine), OpenTLC
    Verbosity: 2

Create a new Inventory source under INVENTORIES / AWS VM's / SOURCES and name it as AWS. The parameters will be as follows:

    Source: Amazon EC2
    Credential: aws
    Regions: US East (Northern Virginia)
    Instance Filters: tag:instance_filter=three-tier-app-<username>*
    Overwrite: True
    Overwrite Variables: True
    Update on Launch: True

Sync the AWS source and check that we are able to see the filtered hosts from AWS in our inventory

Create new Job Template, i.e. Create-3-Tier-prod-key with the following settings:

    Inventory: Advanced_Ansible_Lab
    Project: Advanced_Ansible_Lab_Assignment
    Playbook: assignment_lab/Create-3-Tier-prod-key.yml
    Credential: prod_bastion_key
    Verbosity: 2

Create new Job Template, i.e. Prod-3-tier-app with the following settings:

    Inventory: Advanced_Ansible_Lab
    Project: Advanced_Ansible_Lab_Assignment
    Playbook: assignment_lab/configure_3TA_AWS.yml
    Credential: Three_Tier_Prod_Key
    Verbosity: 2

Create new Job Template, i.e. Clean_Up_3_Tier_App_Prod with the following settings:

    Inventory: Advanced_Ansible_Lab
    Project: Advanced_Ansible_Lab_Assignment
    Playbook: assignment_lab/cleanup_AWS.yml
    Credential: Three_Tier_Prod_Key
    Verbosity: 2

Create a new workflow job template, i.e. Ansible_CICD and update the workflow editor as follows: 3-Tier-APP-QA-Prod
Find the attached ScreenShot in the repo

Result Verification
Find the attached Screenshot in the repo
