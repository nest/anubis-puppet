# ZYV

#
# Things that have to be that way on ALL hosts, no exceptions
#
class services::everybody {

    #
    # For now it's only a directory in /tmp that stores misc site admin / config
    # scripts to be piped into the admin tools or scheduled via cron jobs etc.
    #
    file { $infra_config:
        ensure => 'directory',
    }

}

#
# Distribute default firewall settings
#
class services::iptables {

    package { 'iptables':
        ensure => 'present',
    }

    service { 'iptables':
        enable => 'true',
        ensure => 'running',
        require => Package['iptables'],
    }

    file { '/etc/sysconfig/iptables':
        ensure => 'file',
        mode => '0600',

#
# If iptables are restarted, the virtual network rules added by libvirt are
# removed, so the right way to go is probably to do iptables-save, then add
# changes manually and do iptables-restore if the rules update is to be
# executed on fly without rebooting the whole server or at least iptables +
# libvirt networking (which can screw up virtual machines network connectivity)
#

#        notify => Service['iptables'],
        source => 'puppet:///nodes/sysconfig/iptables',
    }

}

class services::python {
    package { 'python':
        ensure => 'present',
    }
}

class services::bzr {
    package { 'bzr':
        ensure => 'present',
    }
}

class services::git {
    package { 'git':
        ensure => 'present',
    }
}

class services::mercurial {
    package { 'mercurial':
        ensure => 'present',
    }
}

class services::subversion {
    package { 'subversion':
        ensure => 'present',
    }
}

class services::java {

    #
    # Is available from RHEL Server Supplementary (v. 6 64-bit x86_64) channel
    #
    # Reference: https://wiki.jasig.org/display/CASUM/HOWTO+Switch+to+Sun+JVM+in+RHEL
    #            https://issues.jenkins-ci.org/browse/JENKINS-3947
    #
    # Jenkins: "Captcha Not Rendering with OpenJDK 1.6.0.0"
    #
    case $operatingsystem {
        /RedHat/: { $java_package = 'java-1.6.0-sun' }
        default: { fail('Unsupported operating system') }
    }

    package { $java_package:
        ensure => 'present',
    }

}

#
# Keeps system time in sync with a local time server
#
# According to the RHEL hardening guide it is more secure to update the time
# every once in a while with ntpdate as opposed to running a full blown ntp
# server
#
class services::ntpdate($ntp_server) {

    if $ntp_server == undef {
        fail('This class requires $ntp_server to be passed!')
    }

    package { 'ntpdate':
        ensure => 'present',
    }

    #
    # As host / guest time sync problems are getting more severe, run ntpdate
    # client every half an hour to keep the time reasonably in sync
    #
    $cron_minute_1 = fqdn_rand(25)
    $cron_minute_2 = $cron_minute_1 + 30

    cron { 'ntpdate':
        command => "/bin/sh -c '/usr/sbin/ntpdate ${ntp_server} && /usr/sbin/hwclock --systohc' >/dev/null 2>&1",
        ensure => 'present',
        minute => [ $cron_minute_1, $cron_minute_2 ],
        user => 'root',
    }

}

#
# Default logwatch configuration
#
class services::logwatch {

    package { 'logwatch':
        ensure => 'present',
    }

}

#
# Rudementary config for SMART monitor
#
class services::smartmontools {

    package { 'smartmontools':
        ensure => 'present',
    }

    service { 'smartd':
        enable => 'true',
        ensure => 'running',
        require => Package['smartmontools'],
    }

    #
    # On RH-based systems you don't need to do anything else
    #
    # The default configuration is to use all devices and
    # mail root if they fail the self-assesment test
    #

}

#
# rnhsd fails to apply scheduled actions, so just cron rnh_check, damn it!
#
class services::rhn_check {

    service { 'rhnsd':
        enable => 'false',
        ensure => 'stopped',
    }

    $cron_minute = fqdn_rand(59)

    cron { 'rhn_check':
        command => '/usr/sbin/rhn_check >/dev/null 2>&1',
        ensure => 'present',
        minute => $cron_minute,
        user => 'root',
    }

}

#
# Services that should be disabled by default
#
class services::disabled {

    $services_to_disable = [
        'abrtd',
        'avahi-daemon',
        'iscsi',
        'iscsid',
        'kdump',
        'netfs',
        'nfs',
        'nfslock',
        'rpcbind',
        'rpcgssd',
        'rpcidmapd',
        'sysstat',
    ]

    service { $services_to_disable:
        enable => 'false',
        ensure => 'stopped',
    }

}
