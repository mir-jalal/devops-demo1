#!/usr/bin/env bash

[ -f /vagrant/id_rsa ] || {
  ssh-keygen -t rsa -f /vagrant/id_rsa -q -N ''
}

[ -f /home/vagrant/.ssh/id_rsa ] || {
  cp /vagrant/id_rsa /home/vagrant/.ssh/id_rsa
  chmod 0600 /home/vagrant/.ssh/id_rsa
}

grep 'vagrant@node' ~/.ssh/authorized_keys &>/dev/null || {
  cat /vagrant/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 0600 ~/.ssh/authorized_keys
}

cat > ~/.ssh/config <<EOF
Host node*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

