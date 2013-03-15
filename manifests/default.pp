class nginx-php-mongo {

  host {'self':
    ensure       => present,
    name         => $fqdn,
    host_aliases => ['puppet', $hostname],
    ip           => $ipaddress,
  }

  $php = ["php5-fpm", "php5-cli", "php5-dev", "php5-gd", "php5-curl", "php-pear", "php-apc", "php5-mcrypt", "php5-xdebug", "php5-sqlite", "php5-intl", "php5-imagick"]

  exec { 'sudo apt-key mongodb':
    command => '/usr/bin/sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10',
    before => Exec['apt-get update'],
  }

  file { '/etc/apt/sources.list.d/10gen.list':
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/files/10gen.list',
    before => Exec['apt-get update'],
    require => Exec['sudo apt-key mongodb'],
  }

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => [Package["python-software-properties"], Package["build-essential"], Package["nginx"], Package["git"], Package["mongodb-10gen"], Package[$php], Package["openjdk-7-jre"]],
  }

  package { "python-software-properties":
    ensure => present,
  }

  exec { 'add-apt-repository ppa:ondrej/php5':
    command => '/usr/bin/add-apt-repository ppa:ondrej/php5',
    require => Package["python-software-properties"],
  }

  exec { 'apt-get update for latest php, mongodb-10gen':
    command => '/usr/bin/apt-get update',
    before => Package[$php],
    require => Exec['add-apt-repository ppa:ondrej/php5'],
  }

  package { "build-essential":
    ensure => present,
  }

  package { "nginx":
    ensure => present,
  }

  package { "openjdk-7-jre":
    ensure => present,
  }

  package { "git":
    ensure => present,
  }

  package { "mongodb-10gen":
    ensure => present,
    require => Exec['apt-get update'],
  }

  package { $php:
    notify => Service['php5-fpm'],
    ensure => present,
  }

  package { "imagemagick":
    ensure => present,
    require => Package[$php],
  }

  package { "libmagickwand-dev":
    ensure => present,
    require => Package["imagemagick"],
  }

  package { "apache2.2-bin":
    notify => Service['nginx'],
    ensure => purged,
    require => Package[$php],
  }

  exec { 'pecl install mongo':
    notify => Service["php5-fpm"],
    command => '/usr/bin/pecl install --force mongo',
    logoutput => "on_failure",
    require => [Package["build-essential"], Package[$php]],
    before => [File['/etc/php5/cli/php.ini'], File['/etc/php5/fpm/php.ini'], File['/etc/php5/fpm/php-fpm.conf'], File['/etc/php5/fpm/pool.d/www.conf']],
  }

  exec { 'pear config-set auto_discover 1':
    command => '/usr/bin/pear config-set auto_discover 1',
    before => Exec['pear install pear.phpunit.de/PHPUnit'],
    require => Package[$php],
    unless => "/bin/ls -l /usr/bin/ | grep phpunit",
  }

  exec { 'pear install pear.phpunit.de/PHPUnit':
    notify => Service["php5-fpm"],
    command => '/usr/bin/pear install --force pear.phpunit.de/PHPUnit',
    before => [File['/etc/php5/cli/php.ini'], File['/etc/php5/fpm/php.ini'], File['/etc/php5/fpm/php-fpm.conf'], File['/etc/php5/fpm/pool.d/www.conf']],
    unless => "/bin/ls -l /usr/bin/ | grep phpunit",
  }

  file { '/etc/php5/cli/php.ini':
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/files/php/cli/php.ini',
    require => Package[$php],
  }

  file { '/etc/php5/fpm/php.ini':
    notify => Service["php5-fpm"],
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/files/php/fpm/php.ini',
    require => Package[$php],
  }

  file { '/etc/php5/fpm/php-fpm.conf':
    notify => Service["php5-fpm"],
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/files/php/fpm/php-fpm.conf',
    require => Package[$php],
  }

  file { '/etc/php5/fpm/pool.d/www.conf':
    notify => Service["php5-fpm"],
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/files/php/fpm/pool.d/www.conf',
    require => Package[$php],
  }

  file { '/etc/nginx/sites-available/default':
    notify => Service["nginx"],
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/files/nginx/default',
    require => Package["nginx"],
  }

  file { "/etc/nginx/sites-enabled/default":
    ensure => link,
    target => "/etc/nginx/sites-available/default",
    require => Package["nginx"],
  }

  service { "php5-fpm":
    ensure => running,
    require => Package["php5-fpm"],
  }

  service { "nginx":
    ensure => running,
    require => Package["nginx"],
  }

  service { "mongodb":
    ensure => running,
    require => Package["mongodb-10gen"],
  }
}

include nginx-php-mongo