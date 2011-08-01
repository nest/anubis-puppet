# ZYV

#
# Generic web server setup
# (binds to localhost by default and doesn't really do anything)
#
class web_server($default_listen = undef) {

    include web_server::package
    include web_server::service

    if $default_listen == undef {
        $listen = '127.0.0.1:80'
    } else {
        $listen = "${default_listen}"
    }

    insert_comment { 'httpd.conf':
        file => '/etc/httpd/conf/httpd.conf',
    }

    augeas { 'httpd.conf':
        context => '/files/etc/httpd/conf/httpd.conf',
        changes => "set *[self::directive='Listen']/arg '${listen}'",
        notify => Class['web_server::service'],
    }

}

class web_server::package {
    package { 'httpd':
        ensure => 'present',
    }
}

class web_server::service {
    service { 'httpd':
        enable => 'true',
        ensure => 'running',
        require => Class['web_server::package'],
    }
}
