# ZYV

#
# Generic web server setup
# (binds to localhost by default and doesn't really do anything)
#
class apache($settings = undef) {
    include apache::params
    include apache::install
    include apache::config
    include apache::service
}

class apache::params {

    if $apache::settings == undef {
        fail('This class requires settings to be passed!')
    }

    if 'listen' in keys($apache::settings) {
        $listen = $apache::settings['listen']
    } else {
        $listen = '127.0.0.1:80'
    }

}

class apache::install {
    package { 'httpd':
        ensure => 'present',
    }
}

class apache::config {

    augeas::insert_comment { 'httpd.conf':
        file => '/etc/httpd/conf/httpd.conf',
        require => Class['apache::install'],
    }

    augeas { 'httpd.conf':
        context => '/files/etc/httpd/conf/httpd.conf',
        changes => "set *[self::directive='Listen']/arg '${apache::params::listen}'",
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

class apache::redirect::https {

    #
    # Redirect any incoming requests to HTTPS
    #
    file { '/etc/httpd/conf.d/jenkins.conf':
        ensure => 'file',
        require => Class['apache::install'],
        notify => Class['apache::service'],
        content => '
            # ZYV
            #
            # For now do nothing but redirect all requests to HTTPS
            #
            RewriteEngine On
            RewriteRule ^.*$ https://%{HTTP_HOST} [R,L]

            RedirectMatch 403 ^.*$
            ',
    }

}
