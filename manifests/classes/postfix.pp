# ZYV

class postfix {
    include postfix::params
    include postfix::install
    include postfix::config
    include postfix::service
}

class postfix::params {

    #
    # Note: $domain, $hostname and $fqdn are Facter facts
    #
    if $hostname == 'puppet' {
        $mydomain = $domain
        $mydestination = $domain
        $inet_interfaces = '192.168.1.1'
        $mynetworks = '192.168.1.0/24 192.168.122.0/24'
        $relayhost = '[smtp.uni-freiburg.de]:25'
    } else {
        $mydomain = $fqdn
        $mydestination = ''
        $inet_interfaces = ''
        $mynetworks = ''
        $relayhost = '192.168.1.1:25'
    }

    $aliases = [
        { 'user' => 'zaytsev', 'recipient' => 'yury.zaytsev@bcf.uni-freiburg.de', },
        { 'user' => 'wiebelt', 'recipient' => 'wiebelt@bcf.uni-freiburg.de', },
        { 'user' => 'root', 'recipient' => 'zaytsev', },
    ]

}

class postfix::install {
    package { 'postfix':
        ensure => 'present',
    }
}

class postfix::config {

    insert_comment { 'main.cf':
        file => '/etc/postfix/main.cf',
        require => Class['postfix::install'],
    }

    augeas { 'main.cf':

        context => '/files/etc/postfix/main.cf',
        changes => [

            'set inet_protocols "ipv4"',
            "set inet_interfaces '127.0.0.1 ${postfix::params::inet_interfaces}'",

            "set mydomain '${postfix::params::mydomain}'",

            'set myorigin "$mydomain"',
            'set myhostname "$mydomain"',
            "set mydestination '${postfix::params::mydestination} ${hostname} ${fqdn} localhost localhost.localdomain'",

            'set mynetworks_style "host"',
            "set mynetworks '127.0.0.0/8 ${postfix::params::mynetworks}'",

            "set relayhost '${postfix::params::relayhost}'",

            'set smtp_tls_security_level "may"',
            'set smtp_tls_CAfile "/etc/pki/tls/certs/ca-bundle.crt"',
        ],

        notify => Class['postfix::service'],
        require => Class['postfix::install'],

    }

    include postfix::config::aliases

}

class postfix::config::aliases {

    define make_alias {
        mailalias { $name['user']:
            ensure => 'present',
            recipient => $name['recipient'],
            require => Class['postfix::install'],
        }
    }

    make_alias { $postfix::params::aliases : ; }

}

class postfix::service {
    service { 'postfix':
        enable => 'true',
        ensure => 'running',
        require => [
            Class['postfix::install'],
            Class['postfix::config'],
        ]
    }
}
