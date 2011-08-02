# ZYV

#
# Generic web server setup
# (binds to localhost by default and doesn't really do anything)
#
class apache($default_listen = undef) {

    if $default_listen == undef {
        $listen = '127.0.0.1:80'
    } else {
        $listen = $default_listen
    }

    include apache::install
    include apache::config
    include apache::service

}

class apache::install {
    package { 'httpd':
        ensure => 'present',
    }
}

class apache::config {

    insert_comment { 'httpd.conf':
        file => '/etc/httpd/conf/httpd.conf',
        require => Class['apache::install'],
    }

    augeas { 'httpd.conf':
        context => '/files/etc/httpd/conf/httpd.conf',
        changes => "set *[self::directive='Listen']/arg '${apache::listen}'",
        require => Class['apache::install'],
        notify => Class['apache::service'],
    }

}

class apache::service {
    service { 'httpd':
        enable => 'true',
        ensure => 'running',
        require => [
            Class['apache::config'],
            Class['apache::install'],
        ]
    }
}
