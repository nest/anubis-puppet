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

    file { '/etc/httpd/conf.d/infra.conf':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        require => Package['httpd'],
        notify => Service['httpd'],
        source => 'puppet:///nodes/httpd/infra.conf',
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
