# ZYV

class postfix($settings = undef) {
    include postfix::params
    include postfix::install
    include postfix::config
    include postfix::service
}

class postfix::params {

    if $postfix::settings == undef {
        fail('This class requires settings to be passed!')
    }

    $keys = keys($postfix::settings)

    if 'inet_interfaces' in $keys {
        $inet_interfaces = $postfix::settings['inet_interfaces']
    }

    if 'mydestination' in $keys {
        $mydestination = $postfix::settings['mydestination']
    }

    if 'mydomain' in $keys {
        $mydomain = $postfix::settings['mydomain']
    } else {
        $mydomain = $fqdn
    }

    if 'myorigin' in $keys {
        $myorigin = $postfix::settings['myorigin']
    } else {
        $myorigin = '$mydomain'
    }

    if 'myhostname' in $keys {
        $myhostname = $postfix::settings['myhostname']
    } else {
        $myhostname = '$mydomain'
    }

    if 'mynetworks' in $keys {
        $mynetworks = $postfix::settings['mynetworks']
    }

    if 'relayhost' in $keys {
        $relayhost = $postfix::settings['relayhost']
    }

    $aliases = {
        'zaytsev' => { ensure => 'present', notify => Class['postfix::service'], require => Class['postfix::install'], 'recipient' => 'yury@shurup.com', },
        'root'    => { ensure => 'present', notify => Class['postfix::service'], require => Class['postfix::install'], 'recipient' => 'zaytsev', },
    }

}

class postfix::install {
    package { 'postfix':
        ensure => 'present',
    }
}

class postfix::config {

    augeas::insert_comment { 'main.cf':
        file => '/etc/postfix/main.cf',
        require => Class['postfix::install'],
    }

    $main_changes = [
        'set inet_protocols "ipv4"',
        join( [ 'set inet_interfaces "', strip("127.0.0.1 ${postfix::params::inet_interfaces}"), '"' ] ),

        "set mydomain '${postfix::params::mydomain}'",

        "set myorigin '${postfix::params::myorigin}'",
        "set myhostname '${postfix::params::myhostname}'",

        join( [ 'set mydestination "', strip("${postfix::params::mydestination} ${hostname} ${fqdn} localhost localhost.localdomain"), '"' ] ),

        'set mynetworks_style "host"',

        join( [ 'set mynetworks "', strip("127.0.0.0/8 ${postfix::params::mynetworks}"), '"' ] ),

        "set relayhost '${postfix::params::relayhost}'",

        'set smtp_tls_security_level "may"',
        'set smtp_tls_CAfile "/etc/pki/tls/certs/ca-bundle.crt"',
    ]

    augeas { 'main.cf':

        context => '/files/etc/postfix/main.cf',
        changes => $main_changes,

        notify => Class['postfix::service'],
        require => Class['postfix::install'],

    }

    create_resources(mailalias, $postfix::params::aliases)

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
