#/bin/bash

yum install redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc curl vim git -y
cd /root/
wget --no-check-certificate https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm -P /root/
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1m.tar.gz -P /root/
tar -xvf openssl-1.1.1m.tar.gz
yum-builddep /root/rpmbuild/SPECS/nginx.spec -y
git clone https://github.com/iiiiivaaan/study
rm -f /root/rpmbuild/SPECS/nginx.spec
cp /root/study/lesson_6/nginx.spec /root/rpmbuild/SPECS/nginx.spec
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl enable nginx --now
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget https://repo.percona.com/yum/release/7/RPMS/noarch/percona-release-1.0-22.noarch.rpm -P /usr/share/nginx/html/repo/
createrepo /usr/share/nginx/html/repo/
cat >> /etc/nginx/conf.d/default.conf << EOF
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        autoindex on;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
systemctl reload nginx.service
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
