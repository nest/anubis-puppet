# ZYV

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


class services::git {
    package { 'git':
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
class services::ntpdate {

    package { 'ntpdate':
        ensure => 'present',
    }

    cron { 'ntpdate':
        command => '/usr/sbin/ntpdate time.uni-freiburg.de && /usr/sbin/hwclock --systohc',
        ensure => 'present',
        hour => '3',
        minute => '30',
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
