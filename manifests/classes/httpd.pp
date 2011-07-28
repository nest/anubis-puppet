# ZYV

class web_server {

    package { 'httpd':
        ensure => 'present',
    }

    service { 'httpd':
        enable => 'true',
        ensure => 'running',
        require => Package['httpd'],
    }

    insert_comment { 'httpd.conf':
        file => '/etc/httpd/conf/httpd.conf',
    }

    augeas { 'httpd.conf':
        context => '/files/etc/httpd/conf/httpd.conf',
        changes => 'set *[self::directive="Listen"]/arg "127.0.0.1:80"',
        notify => Service['httpd'],
    }

}
