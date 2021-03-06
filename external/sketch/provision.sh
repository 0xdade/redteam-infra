#!/bin/bash

if [ $(whoami) != "root" ]; then
    echo "you must be root"
    exit 1
fi

cat <<EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl -p

export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get -y install screen ufw simpleproxy

useradd -p '*' -m -s '/bin/bash' -k /etc/skel  user
mkdir ~user/.ssh
cat <<EOF > ~user/.ssh/authorized_keys
<YOUR AUTHORIZED KEYS HERE>
EOF
chmod 700 ~user/.ssh
chmod 600 ~user/.ssh/authorized_keys
chown -R user:user ~user

sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -E 's/#?UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sed -i -E 's/#?ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

echo "sshd config:"
grep -i PasswordAuthentication /etc/ssh/sshd_config
grep -i UsePAM /etc/ssh/sshd_config
grep -i ChallengeResponseAuthentication /etc/ssh/sshd_config

cat <<EOF > /etc/sudoers.d/99user
user            ALL = (ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/99user

/etc/init.d/ssh reload
ufw allow ssh
ufw --force enable
apt-get install unattended-upgrades

