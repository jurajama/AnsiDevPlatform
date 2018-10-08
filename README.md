This is demonstration of deploying VMs to OpenStack cloud with Ansible, producing a complete system that is easy to expand by adding new nodes. User accounts of the admin team are distributed to all VMs.

Jumphost is the node that is intended for running Ansible during normal operations. Only in the very beginning when you create the cluster from scratch, you need to run Ansible elsewhere for example in Docker container <A HREF="https://github.com/jurajama/OS_ansible_client">https://github.com/jurajama/OS_ansible_client</A>

Any other nodes shall be deployed by running Ansible in jumphost, because it is expected that many of the other nodes do not have public IP and therefore direct connection from the outside world would not be possible.

The VMs are deployed with fixed IPs defined in the environment's env_config.yml file in group_vars. When floating IPs are needed, that is at least for jumphost, you shall manually allocate the IP when you start creating the project:
<PRE>openstack floating ip create --description jump1_floating_ip Public-Helsinki-1</PRE>

Then put the created IP-address to the group_vars file. The IP will always remain the same even if you would delete and re-create the VM. This is assuming that you don't de-allocate the IP from your project. Note that floating IPs allocated to your project may incur costs in the cloud even if they are not associated with any VM.

User management is an important part of this solution. All admin users shall be configured in group_vars/all/users.yml. There is one human user as a model of admin-user, and jenkinsci user as a model for user account used by Jenkins. When deploying this system, already before jumphost deployment you shall put your own account and public key in users.yml and use that same username in the host (like docker container) where you run Ansible.

dbserver-create-os.yml is not deploying any real DB server, but serves as a skeleton example of deploying some application.

jenkins-create-os.yml deploys Jenkins master server that could be used for continuous integration purposes. Jumphost is registered as a slave for Jenkins.

Tested to work with Ansible 2.7 in Nebula cloud <A HREF="https://cloud9.nebula.fi">https://cloud9.nebula.fi</A>
