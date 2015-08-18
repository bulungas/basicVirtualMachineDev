#sudo yum -y update;
if ! rpm -qa | grep -qw openvpn; then
   sudo yum install -y openvpn;
fi
if ! rpm -qa | grep -qw gcc; then
    sudo rpm -ivh http://epel.mirror.net.in/epel/6/i386/epel-release-6-8.noarch.rpm;
    sudo yum install -y epel-release;
    sudo yum install -y gcc gcc-c++ patch readline readline-devel curl zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel;
fi
#if ! rpm -qa | grep -qw gcc; then
#    sudo yum install -y gcc gcc-c++ patch readline readline-devel curl zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel;
#    sudo yum install -y autoconf autoconf autoconf-archive automake ncurses-devel curl-devel erlang-asn1 erlang-erts erlang-eunit erlang-os_mon erlang-xmerl help2man js-devel libicu-devel libtool perl-Test-Harness;
#    sudo yum install -y epel-release;
#    sudo yum install -y js-devel;
#    sudo yum install -y erlang;
#
#    sudo wget http://ftp.mozilla.org/pub/mozilla.org/js/mozjs17.0.0.tar.gz;
#    sudo tar -xvf mozjs17.0.0.tar.gz;
#    cd mozjs17.0.0/js/src/;
#    sudo ./configure;
#    sudo make && make install;
#    cd ~/
#    wget http://apache.webxcreen.org/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz;
#    tar zxvf apache-couchdb-1.6.1.tar.gz;
#    cd apache-couchdb-1.6.1;
#    sudo ./configure --with-erlang=/usr/lib64/erlang/usr/include/;
#    sudo make && sudo make install;
#    sudo  adduser --no-create-home couchdb
#    sudo  chown -R couchdb:couchdb /usr/local/var/lib/couchdb /usr/local/var/log/couchdb /usr/local/var/run/couchdb
#    sudo  ln -sf /usr/local/etc/rc.d/couchdb /etc/init.d/couchdb
#    sudo  chkconfig --add couchdb
#    sudo  chkconfig couchdb on
#    sudo chown -R couchdb:couchdb /usr/local/etc/couchdb
#    sudo chown -R couchdb:couchdb /usr/local/var/lib/couchdb
#    sudo chown -R couchdb:couchdb /usr/local/var/log/couchdb
#    sudo chown -R couchdb:couchdb /usr/local/var/run/couchdb
#    sudo chmod -R 0770 /usr/local/etc/couchdb
#    sudo chmod -R 0770 /usr/local/var/lib/couchdb
#    sudo chmod -R 0770 /usr/local/var/log/couchdb
#    sudo chmod -R 0777 /usr/local/var/run/
#    sudo usermod -a -G couchdb vagrant
#    sudo cp /vagrant/local.ini /usr/local/etc/couchdb/local.ini
#fi

if ! rpm -qa | grep -qw ruby; then
    curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -
    curl -L https://get.rvm.io | bash -s stable --ruby;
    source /usr/local/rvm/scripts/rvm;
    rvm install 2.2.1;
    rvm use 2.2.1;
    rvm rubygems latest;
    gem update --system;
    gem install bundler;
    gem install json_pure;
    gem install compass;
    gem install sass;
fi
#si aun no se instala puppet, registro el repo y lo instalo
if ! rpm -qa | grep -qw puppet; then
	sudo rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs;
	sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
    sudo rpm -ivh http://yum.puppetlabs.com/el/6.5/products/x86_64/puppetlabs-release-6-7.noarch.rpm;
	sudo yum -y install puppet;
    sudo puppet resource package puppet ensure=latest
    sudo /etc/init.d/puppet restart
fi
#para evitar el warning de que no existe el archivo
sudo touch /etc/puppet/hiera.yaml;
#istalo los modulos de los que depende mi site.pp
sudo puppet module install jfryman-nginx;
sudo puppet module install thias-php;
sudo puppet module install example42-yum;
sudo puppet module install puppetlabs-mysql;
sudo puppet module install puppetlabs-firewall;
sudo puppet module install willdurand/nodejs;
