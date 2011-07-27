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

}
