#install apache
yum install --quiet -y httpd httpd-devel
#copy conf files
cp httpd.conf /etc/httpd/conf/httpd.conf
cp httpd-vhosts /etc/httpd/conf/httpd-vhosts.conf
#start apache and conf it to run at boot
service httpd start
chkconfig httpd on