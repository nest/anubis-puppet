# ZYV

class git {
    package { 'git':
        ensure => 'present',
    }
}

#
# Services that should be disabled by default
#
class disable_services {

    $services_to_disable = [
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
    ]

    service { $services_to_disable:
        enable => 'false',
        ensure => 'stopped',
    }

}

#
# Keeps system time in sync with a local time server
#
# According to the RHEL hardening guide it is more secure to update the time
# every once in a while with ntpdate as opposed to running a full blown ntp
# server
#
class ntpdate {

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
class logwatch {

    package { 'logwatch':
        ensure => 'present',
    }

}
