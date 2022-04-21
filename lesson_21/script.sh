#!/bin/bash

setenforce 0
yum install vim epel-release -y
yum install pam_script yum-utils -y

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y
systemctl start docker
systemctl enable docker

useradd day
useradd night
echo "123123" | passwd --stdin day
echo "123123" | passwd --stdin night 
groupadd admin
usermod -aG admin day
usermod -aG docker night

sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service

cat <<EOF > /usr/local/sbin/admin.sh
#!/bin/bash
ADM=`groups $PAM_USER | grep admin`
if [[ $? == 0 ]]; then
  exit 0
else
  if [[ $(date +%u) -lt 6 ]]
     then
        exit 0
     else
        exit 1
     fi
fi
EOF
chmod 700 /usr/local/sbin/admin.sh
echo "account required pam_script.so /usr/local/sbin/admin.sh" >> /etc/pam.d/sshd
