set -x

# Elevate priviledges, retaining the environment.
sudo -E su

# Install dev tools.
yum install -y "@Development Tools" python2-pip openssl-devel python-devel gcc libffi-devel

# Get the OKD 3.11 installer.
pip install -I ansible==2.6.5
rm -rf ./openshift311-prereqs-ansible
git clone https://github.com/welshstew/openshift311-prereqs-ansible.git


ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./inventory.cfg ./openshift311-prereqs-ansible/install-prereqs.yml --extra-vars "redhat_username=$REDHAT_USERNAME redhat_password=$REDHAT_PASSWORD redhat_poolid=$REDHAT_POOLID"
