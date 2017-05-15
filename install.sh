#!/bin/sh
printf "Please enter IP address for this server:"
read IP

printf "Please enter FTP username:"
read USERNAME

printf "Please enter FTP password:"
read PASSWORD

# Update
sudo yum update -y

# Install Nginx and PHP-FPM
sudo yum install -y httpd24 php56

# Install PHP extensions
sudo yum install -y php56-mysqlnd php56-devel php56-pdo php56-pear php56-mbstring php56-cli php56-odbc php56-imap php56-gd php56-xml php56-soap  php56-mcrypt php56-mysqlnd

#Install ftp
sudo yum install -y vsftpd

printf "Config httpd...\n"
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/httpd/conf/httpd.conf

printf "Config vsftp...\n"
sudo sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" /etc/vsftpd/vsftpd.conf
sudo sed -i "s/#chroot_local_user=YES/chroot_local_user=YES/g" /etc/vsftpd/vsftpd.conf
echo -e "pasv_enable=YES" | sudo tee --append /etc/vsftpd/vsftpd.conf
echo -e "pasv_min_port=1024" | sudo tee --append /etc/vsftpd/vsftpd.conf
echo -e "pasv_max_port=1048" | sudo tee --append /etc/vsftpd/vsftpd.conf
echo -e "pasv_address=$IP" | sudo tee --append /etc/vsftpd/vsftpd.conf

printf "Autostart httpd and vsftpd...\n"
sudo chkconfig httpd on
sudo chkconfig vsftpd on

printf "Start service...\n"
sudo service httpd start
sudo service vsftpd start

printf "Adding user group...\n"
sudo groupadd www
sudo usermod -a -G www ec2-user

printf "Adding FTP user...\n"
sudo adduser -G www $USERNAME
sudo passwd $USERNAME <<EOF
$PASSWORD
$PASSWORD
EOF

printf "Setup user permission...\n"
sudo usermod -d /var/www/ $USERNAME

printf "Setup web directory...\n"
sudo chown -R root:www /var/www
sudo chmod -R 777 /var/www

printf "Congratulation, the system is ready to use!\n"
