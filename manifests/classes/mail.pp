# ZYV

#
# Class that sets up a smart-hosting postfix on the virtualization server
#

$email_domain = 'qa.nest-initiative.org'

$email_zaytsev = 'yury.zaytsev@bcf.uni-freiburg.de'
$email_wiebelt = 'wiebelt@bcf.uni-freiburg.de'

$email_root = "${email_zaytsev}"

class mail_server {

    package { 'postfix':
        ensure => 'present',
    }

    service { 'postfix':
        enable => 'true',
        ensure => 'running',
        require => [
            Augeas['main.cf'],
            Package['postfix'],
        ]
    }

    insert_comment { 'main.cf':
        file => '/etc/postfix/main.cf',
    }

    augeas { 'main.cf':

        context => '/files/etc/postfix/main.cf',
        changes => [

            'set inet_protocols "ipv4"',
            'set inet_interfaces "127.0.0.1, 192.168.1.1"',

            "set mydomain '${email_domain}'",

            'set myorigin "$mydomain"',
            'set myhostname "$mydomain"',
            'set mydestination "$mydomain, puppet, puppet.$mydomain, localhost, localhost.localdomain, localhost4, localhost4.localdomain4"',

            'set mynetworks_style "host"',
            'set mynetworks "127.0.0.0/8, 192.168.1.0/24, 192.168.122.0/24"',

            'set relayhost "[smtp.uni-freiburg.de]:25"',

            'set smtp_tls_security_level "may"',
            'set smtp_tls_CAfile "/etc/pki/tls/certs/ca-bundle.crt"',
        ],

        notify => Service['postfix'],
        require => Package['postfix'],

    }

    mailalias { 'root':
        ensure => 'present',
        recipient => "${email_root}",
    }

    mailalias { 'zaytsev':
        ensure => 'present',
        recipient => "${email_zaytsev}",
    }

    mailalias { 'wiebelt':
        ensure => 'present',
        recipient => "${email_wiebelt}",
    }

}
