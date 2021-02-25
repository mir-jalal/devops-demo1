#!/usr/bin/env bash

echo "useradd provisioning"

useradd -m -s /bin/bash -U demo_user -u 2302
cp -pr /home/mirjalalcloud/.ssh /home/demo_user/
chown -R demo_user:demo_user /home/demo_user
echo "%demo_user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/demo_user
