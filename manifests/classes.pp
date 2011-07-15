# ZYV

#
# Ensure that site admins are on the sudoers list
#
class sudoers {

    package { 'sudo':
        ensure => 'present',
    }

    file { '/etc/sudoers.d/admins':
        ensure => 'file',
        group => 'root',
        mode => '0440',
        owner => 'root',
        require => Package['sudo'],
        source => 'puppet:///common/sudoers/admins',
    }

}

#
# Custom fstab settings
#
class fstab {

    file { '/etc/fstab':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        source => 'puppet:///nodes/fstab',
    }

}

#
# Custom rc.local settings (i.e. elevator tweaks)
#
class rc_local {

    file { '/etc/rc.d/rc.local':
        ensure => 'file',
        group => 'root',
        mode => '0755',
        owner => 'root',
        source => 'puppet:///nodes/rc.local',
    }

}

#
# The EFI-based systems can only boot off a special vfat partition and for that
# reason software RAID1 is not supported in such configurations.
#
# This class makes sure that the main EFI boot partition is backed up to to the
# second drive as it changes, so that in case if one of the hard drives in the
# RAID array fails, the system can still boot off the second drive.
#
# The mount point for the backup partition is to be created from the kickstart
# during the system provisioning phase.
#
class efi_backup {

    file { '/mnt/efi':
        ensure => 'directory',
        group => 'root',
        mode => '0700',
        owner => 'root',
        recurse => 'true',
        source => 'file:///boot/efi',
    }

}

#
# Ensures that the master Puppet configuration is always up to date
#
class master_configuration {

    package { 'git':
        ensure => 'present',
    }

#    vcsrepo { '/etc/puppet':
#        ensure => 'latest',
#        provider => 'git',
#        require => Package['git'],
#        revision => 'HEAD',
#        source => 'git://git.zaytsev.net/anubis-puppet.git',
#    }

}

#
# Class that sets up a smart-hosting postfix on the virtualization server
#

$email_domain = 'qa.nest-initiative.org'

$email_zaytsev = 'yury.zaytsev@bcf.uni-freiburg.de'
$email_wiebelt = 'wiebelt@bcf.uni-freiburg.de'

$email_root = "$email_zaytsev"

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

    augeas { 'main.cf':

        context => '/files/etc/postfix/main.cf',
        changes => [

            'set inet_protocols "ipv4"',
            'set inet_interfaces "127.0.0.1, 192.168.122.1"',

            "set mydomain '$email_domain'",

            'set myorigin "$mydomain"',
            'set myhostname "$mydomain"',
            'set mydestination "$mydomain, puppet, puppet.$mydomain, localhost, localhost.localdomain, localhost4, localhost4.localdomain4"',

            'set mynetworks_style "host"',
            'set mynetworks "127.0.0.0/8, 192.168.122.0/24"',

            'set relayhost "[smtp.uni-freiburg.de]:25"',

            'set smtp_tls_security_level "may"',
            'set smtp_tls_CAfile "/etc/pki/tls/certs/ca-bundle.crt"',
        ],

        notify => Service['postfix'],
        require => Package['postfix'],

    }

    mailalias { 'root':
        ensure => 'present',
        recipient => "$email_root",
    }

    mailalias { 'zaytsev':
        ensure => 'present',
        recipient => "$email_zaytsev",
    }

    mailalias { 'wiebelt':
        ensure => 'present',
        recipient => "$email_wiebelt",
    }

}


#
# Local yum repositories on anubis (puppet etc.)
#
class yum_repos_anubis {

    #
    # TODO: think of how to best get the files there
    #
    yumrepo { 'rhel-6-local-noarch':
        baseurl => 'file:///srv/repos/rhel-6-local/noarch',
        descr => 'rhel-6-local-noarch',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/repos'],
    }

    yumrepo { 'rhel-6-local-x86_64':
        baseurl => 'file:///srv/repos/rhel-6-local/x86_64',
        descr => 'rhel-6-local-x86_64',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/repos'],
    }

    file { '/srv/repos':
        ensure => 'directory',
        group => 'root',
        mode => '0644',
        owner => 'root',
        recurse => 'true',
    }

    file { '/srv/repos/update-metadata':
        ensure => 'file',
        group => 'root',
        mode => '0755',
        owner => 'root',
        require => File['/srv/repos'],
        source => 'puppet:///nodes/update-metadata',
    }

    exec { 'update_metadata':
        command => '/srv/repos/update-metadata',
        cwd => '/srv/repos',
        logoutput => 'true',
        refreshonly => 'true',
        require => File['/srv/repos/update-metadata'],
        subscribe => File['/srv/repos'],
    }

}

