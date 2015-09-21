sudo pecl install Xdebug
sudo cp /vagrant/vagrant/xdebug /etc/php.d/xdebug.ini
sudo service php-fpm restart
sudo chkconfig iptables off
sudo iptables stop