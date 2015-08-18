if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
      allow_virtual => $allow_virtual_packages,
    }
}

class pkgsextra{
    #por estructura paso estos paquetes a que se instalen por puppet y no por bash
    package { ['curl', 'git', 'ant', 'tar','java-1.7.0-openjdk-devel','java-1.7.0-openjdk','nano', 'gcc', 'gcc-c++','autoconf','automake'] :
        ensure  => present,
    }
}

class websrv{
    #esto asegura no tener problemas por un bug conocido con los archivos estaticos en virtualbox con linux y nginx
    class { 'nginx': sendfile => off }
    user { "nginx":
        ensure     => present,
        gid        => "nginx",
        groups     => ["vagrant","apache"],
        # For the user to exist
            require => [Group['nginx'],Group['vagrant']]
    }
    group {"nginx":
        ensure     => present,
    }
    group {"vagrant":
        ensure     => present,
    }
    group {"apache":
        ensure     => present,
    }
}
class mysqlSrv{
    require ::mysql::client
    class { '::mysql::server':
        override_options => {
            'mysqld' => {
                'lower_case_table_names' => '1',
                'bind-address'          => '0.0.0.0',
            }
        },
        users => {
            'root@%' => {
                ensure => 'present',
                password_hash => '*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19',#hash de la palabra password
            },
        },
        users => {
            'root@localhost' => {
                ensure => 'present',
                password_hash => '*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19',#hash de la palabra password
            },
        },
    }->
    mysql_grant { 'root@%/*.*':
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => '*.*',
        user       => 'root@%',
    }->
    mysql_grant { 'root@localhost/*.*':
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => '*.*',
        user       => 'root@localhost',
    }

}
class createdb{
        mysql::db{'proyecto':
        user     => 'root',
        password => 'password',
        host     => '127.0.0.1',
    }
}
class appsrv {
    require yum::repo::remi
    require yum::repo::epel
    require yum::repo::remi_php56
    # For the user to exist
    require websrv
    package { 'libtidy':
        ensure  => present,
    }
    package { 'libtidy-devel':
        ensure  => present,
    }
    package { 'php-tidy':
        ensure  => present,
    }
    class { php::fpm::daemon:
        log_owner => 'nginx',
        log_group => 'nginx',
        log_dir_mode => '0775',
    }
    php::fpm::conf { 'www':
        listen  => '127.0.0.1:9001',
        user    => 'nginx',
    }
    php::module { [ 'pecl-apcu',
        'pear',
        'pdo',
        'mysqlnd',
        'pgsql',
        'pecl-mongo',
        'pecl-sqlite',
        'mbstring',
        'mcrypt',
        'xml',
        'pecl-memcached',
        'gd',
        'soap']:
        notify  => Service['php-fpm'],
    }
    php::ini { '/etc/php.ini':
        short_open_tag              => 'On',
        asp_tags                    => 'Off',
        date_timezone               =>'America/Mexico_City',
        error_reporting             => 'E_ALL',
        display_errors              => 'On',
        html_errors                 => 'On',
        notify  => Service['php-fpm'],
    }
    file { '/var/log/php-fpm/www-error.log':
        ensure => "file",
        owner  => "nginx",
        group  => "nginx",
        mode   => 664
    }
    file { '/var/log/php-fpm/error.log':
        ensure => "file",
        owner  => "nginx",
        group  => "nginx",
        mode   => 664,
    }
}
class xdebug{
    require appsrv
    package { ['php-devel'] :
        ensure  => present,
    }->
    exec { "install_xdebug":
       path => "/usr/bin/",
       command => "sudo pecl install Xdebug",
       creates => "/usr/lib64/php/modules/xdebug.so"
    }->
    file { "/etc/php.d/xdebug.ini":
        ensure  => file,
        notify  => Service['php-fpm'],
        content => "[xdebug]
            zend_extension=\"/usr/lib64/php/modules/xdebug.so\"
            xdebug.remote_enable        = 1
            xdebug.remote_connect_back  = 1
            xdebug.collect_params       = 4
            xdebug.collect_vars         = on
            xdebug.dump_globals         = on
            xdebug.dump.SERVER          = REQUEST_URI
            xdebug.show_local_vars      = on
            xdebug.cli_color            = 1
            #xdebug.force_error_reporting = E_ALL & ~E_DEPRECATED",
    }
}
class ecommerce {
    require websrv
    require appsrv
    require mysqlSrv
    require createdb
    require xdebug
    nginx::resource::vhost { 'www.proyecto.local.com':
        www_root => '/www/www.proyecto.local.com/public',
        ssl => true,
        ssl_cert             => '/vagrant/puppet/certs/server.crt',
        ssl_key              => '/vagrant/puppet/certs/server.key',
        index_files           => [ 'index.php' ],
        use_default_location => false,
    }
    nginx::resource::location { "www.proyecto.local.com":
        ensure          => present,
        ssl              => true,
        vhost           => 'www.proyecto.local.com',
        www_root        => '/www/www.proyecto.local.com/public',
        location        => '~ \.php$',
        index_files     => ['index.php'],
        proxy           => undef,
        fastcgi         => "127.0.0.1:9001",
        fastcgi_script  => undef,
        location_cfg_append => { 
            fastcgi_connect_timeout => '5h',
            fastcgi_read_timeout    => '5h',
            fastcgi_send_timeout    => '5h',
            fastcgi_param    => "APPLICATION_ENV 'development'"
        }
    }
    nginx::resource::location { "try":
        ensure          => present,
        ssl              => true,
        vhost           => 'www.proyecto.local.com',
        location        => '/',
        www_root        => '/www/www.proyecto.local.com/public',
        location_cfg_append => { 
            try_files => '$uri $uri/ /index.php$is_args$args'
        }
    }
}
class stackmean{
    require pkgsextra
    class { 'nodejs':
        version => 'v0.10.25',
        make_install => true,
        target_dir => '/bin',
    }
    package { 'express':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'grunt':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'grunt-cli':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'bower':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'less':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'jade':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'coffee-script':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'nodefront':
        provider => npm,
        require  => Class['nodejs']
    }
    package { 'gulp':
        provider => npm,
        require  => Class['nodejs']
    }
}
include pkgsextra
include stackmean
include ecommerce
