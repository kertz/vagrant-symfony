class nginx {

  package { "nginx":
    ensure => present,
  }

  service { "nginx":
    ensure => running,
    require => Package["nginx"],
  }

  file { '/etc/nginx/nginx.conf':
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/manifests/nginx/nginx.conf',
    require => Package["nginx"],
    notify => Service["nginx"],
  }

  file { '/etc/nginx/sites-available/default':
    owner  => root,
    group  => root,
    ensure => file,
    mode   => 644,
    source => '/vagrant/manifests/nginx/default',
    require => Package["nginx"]
  }

  file { "/etc/nginx/sites-enabled/default":
    ensure => link,
    target => "/etc/nginx/sites-available/default",
    require => Package["nginx"],
    notify => Service["nginx"],
  }
}

class php {

  $php = ["php5-fpm", "php5-cli", "php5-dev", "php5-gd", "php5-curl", "php-pear", "php-apc", "php5-mcrypt", "php5-xdebug", "php5-sqlite", "php5-intl"]

  package { $php:
    ensure => present,
    notify => Service["php5-fpm"]
  }

  service { "php5-fpm":
    ensure => running
  }
}

include nginx
include php
