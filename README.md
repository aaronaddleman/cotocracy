# generate a ssh key

ssh-keygen -t rsa -b 4096 -f $PWD/id_rsa

# ensure .ssh exists

# transfer key to target host for control

ssh root@54.158.155.138 "mkdir ~/.ssh"

# copy key to server

scp id_rsa.pub root@54.158.155.138:~/.ssh/authorized_keys

# verify access to server without prompting for password

ssh -i id_rsa root@54.158.155.138