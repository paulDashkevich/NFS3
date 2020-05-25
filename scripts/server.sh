#!/bin/bash
mkdir /home/vagrant/Upload
chmod -R 755 /home/vagrant/Upload
chown vagrant:vagrant /home/vagrant/Upload
cat > /etc/exports <<EOF
/home/vagrant/Upload 192.168.11.102(async,rw,no_subtree_check,root_squash,anonuid=1000,anongid=1000)
EOF
exportfs -arv
echo "шара готова!"
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
systemctl restart nfs-server
firewall-cmd --permanent --add-port=111/tcp
firewall-cmd --permanent --add-port=54302/tcp
firewall-cmd --permanent --add-port=20048/tcp
firewall-cmd --permanent --add-port=2049/tcp
firewall-cmd --permanent --add-port=46666/tcp
firewall-cmd --permanent --add-port=42955/tcp
firewall-cmd --permanent --add-port=875/tcp
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
echo "Server NFS is ready to rock"
exit 0
