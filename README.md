## Overview

This is demonstration of deploying VMs to OpenStack cloud with Ansible, producing a complete system that is easy to expand by adding new nodes. User accounts and SSH public keys of the admin team are distributed to all VMs.

This project as such is not intended to be usable for other than demo purposes, but the idea is that you fork or copy it to your own repository where you do your real work. 

Tested to work with Ansible 2.7 in Nebula cloud <A HREF="https://cloud9.nebula.fi">https://cloud9.nebula.fi</A>

## Getting started
### Ansible runtime environment for jumphost deployment
Jumphost is the node that is intended for running Ansible during normal operations. Only in the very beginning when you create the cluster from scratch, you need to run Ansible elsewhere for example in Docker container <A HREF="https://github.com/jurajama/OS_ansible_client">https://github.com/jurajama/OS_ansible_client</A>. SSH agent forwarding must be in use when using the container, that is described in the readme-page of that repository.

Any other nodes shall be deployed by running Ansible in jumphost, because it is expected that many of the other nodes do not have public IP and therefore direct connection from the outside world would not be possible.

### Configuration preparations
Before running any Ansible playbooks or using OpenStack CLI commands, you shall set environment variables that define the used OpenStack project and credentials. Example template is in roles/users/templates/nebula_openrc.sh.j2. When jumphost is configured, that template is used to create environment-script in each users home directory with variables replaced by OpenStack project information configured in *group_vars/env1/envconfig.yml*. After you have properly filled openrc file in your home dir, activate it by *"source filename.sh"* and test with *"nova list"* command that it does not show authentication error.

Configure your OpenStack project ID and project name in *group_vars/env1/envconfig.yml*. They shall be exactly like shown in the openrc file downloaded from OpenStack GUI.

### Creating OpenStack networks and security groups
After you have the initial Ansible runtime environment created and OpenStack API access working, the next step is to create a network and router in OpenStack. That is done by playbook:
<PRE>ansible-playbook -i inventories/env1 openstack-net-create.yml</PRE>

Then create security groups:
<PRE>ansible-playbook -i inventories/env1 openstack-secgroup-create.yml</PRE>

### Allocating floating IPs
The VMs are deployed with fixed IPs defined in the environment's env_config.yml file in group_vars. When floating IPs are needed, that is at least for jumphost, you shall manually allocate the IP when you start creating the project. IPs are easy to allocate using openstack CLI command run for example in *OS_ansible_client* container.
<PRE>openstack floating ip create --description jump1_floating_ip Public-Helsinki-1</PRE>

Then put the created IP-address to the group_vars file in node's floating IP address variable. The IP will always remain the same even if you would delete and re-create the VM. This is assuming that you don't de-allocate the IP from your project. Note that floating IPs allocated to your project may incur costs in the cloud even if they are not associated with any VM.

## User management
User management is an important part of this solution. All admin users shall be configured in group_vars/all/users.yml. There is one human user as a model of admin-user, and jenkinsci user as a model for user account used by Jenkins. When deploying this system, already before jumphost deployment you shall put your own account and public key in users.yml and use that same username in the host (like docker container) where you run Ansible.

## Creating jumphost

The idea is that this same codebase can be used to deploy multiple environment instances, for example dev, staging and prod. They are differentiated by env-specific variables under group_vars and inventory file in inventories directory. When using the playbooks, you shall define the used inventory with -i parameter. This is the command to create jumphost for env1 environment after you have tuned the configuration to match with your environment.

<PRE>ansible-playbook -i inventories/env1 jump-create-os.yml</PRE>

The basic principle is that each environment shall have its own jumphost, as typically many application nodes would not have a public IP but accessible only via the jumphost of that specific env.

## Deploying other nodes
*dbserver-create-os.yml* is not deploying any real DB server, but serves as a skeleton example of deploying some application.

*jenkins-create-os.yml* deploys Jenkins master server that could be used for continuous integration purposes. Jumphost is registered as a slave for Jenkins.
Jenkins connects to jumphost using private key stored in group_vars/all/jenkins_credentials.yml and corresponding public key in *group_vars/all/users.yml*. **NOTE: Do not use these demo SSH keys in any production environment but create your own keys.** Also when you put any passwords or private keys in your own repository, encrypt those configuration files with ansible-vault. Search google for information on how to use ansible-vault.

**Note:** Before deploying Jenkins using *jenkins-create-os.yml*, run *"./update-roles.bash"* to update external roles. That fetches some code from github to ext-roles directory.

After Jenkins has been deployed, you can access GUI with http://jenkins_floating_ip:8080. Default credentials are username=admin, password=admin123. When deploying Jenkins for real use, change admin password in variable *jenkins_admin_password* before deployment.

