# ZYV

#
# Distribute default firewall settings
#
class iptables {

    file { '/etc/sysconfig/iptables':
        ensure => 'file',
        group => 'root',
        mode => '0600',
        notify => Service['iptables'],
        owner => 'root',
        source => 'puppet:///nodes/sysconfig/iptables',
    }

    service { 'iptables':
        enable => 'true',
        ensure => 'running',
    }

}

#
# Distribute default hosts file to the clients
#
class hosts {

    file { '/etc/hosts':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        source => 'puppet:///nodes/hosts',
    }

}

#
# Interface on the virtualization host, that the services that need to be
# accessible to the virtual machines, but not to the outside network have to
# listen (e.g. Postfix)
#
# For now, activation needs a reboot to not to complicate the configuration
#
class internal_interface {

    package { 'tunctl':
        ensure => 'present',
    }

    file { '/etc/sysconfig/network-scripts/ifcfg-tap1':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        require => Package['tunctl'],
        source => 'puppet:///nodes/network-scripts/ifcfg-tap1',
    }

}

#
# Class that completely disables IPV6 support on a system
#
class disable_ipv6 {

    # https://access.redhat.com/kb/docs/DOC-8711
    #
    # - Disabling IPv6 support in Red Hat Enterprise Linux 6
    #
    # options ipv6 disable=1
    #
    # - Disabling IPv6 support in Red Hat Enterprise Linux 5
    #
    # alias ipv6 off
    # alias net-pf-10 off
    # options ipv6 disable=1
    #
    # - Disabling IPv6 support in Red Hat Enterprise Linux 4
    #
    # alias ipv6 off
    # alias net-pf-10 off
    #

    #
    # Extend via facter to support multiple platforms some day
    #
    $modprobe_content = 'options ipv6 disable=1'

    file { '/etc/modprobe.d/disable-ipv6.conf':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        content => "# ZYV\n${modprobe_content}"
    }

    service { 'ip6tables':
        enable => 'false',
        ensure => 'stopped',
    }

    insert_comment { 'network':
        file => '/etc/sysconfig/network',
    }

    augeas { 'network':
        context => '/files/etc/sysconfig/network',
        changes => 'set NETWORKING_IPV6 "no"',
    }

}
