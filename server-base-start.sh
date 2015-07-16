#!/bin/sh

# Enable ssh if specified on docker run

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# FOR LOCAL ENVIRONMENT ONLY
if [ "${ENABLE_SSH}" != "" ];
then
if [ "${SSH_USERNAME}" != "" ]; then sshuname=$SSH_USERNAME else sshuname=root; fi
if [ "${SSH_PASSWORD}" != "" ]; then sshpass=$SSH_PASSWORD else sshpass=password; fi
rm -f /etc/service/sshd/down
echo "${sshuname}:${sshpass}" | chpasswd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
chmod 0755 /var/run/sshd
mkdir -p /root/.ssh/ && touch /root/.ssh/authorized_keys
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd;
fi
# END LOCAL ONLY

# Start memcache
# /usr/bin/memcached -u memcache -v
