# ZYV

#
# Distribute default hosts file & resolver settings to the clients
#
class network::hosts {
    file { '/etc/hosts':
        ensure => 'file',
        source => 'puppet:///nodes/hosts',
    }
}

class network::hosts::common {
    file { '/etc/hosts':
        ensure => 'file',
        source => 'puppet:///commmon/hosts',
    }
}

class network::resolv {
    file { '/etc/resolv.conf':
        ensure => 'file',
        source => 'puppet:///nodes/resolv.conf',
    }
}

class network::resolv::common {
    file { '/etc/resolv.conf':
        ensure => 'file',
        source => 'puppet:///common/resolv.conf',
    }
}

#
# Internal interfaces configuration on Anubis
#
class network::interfaces($ports = undef, $tunctl = 'false') {

    if $ports == undef {
        fail('You need to specify a list of interfaces when invoking this class!')
    }

    if $tunctl == 'true' {
        #
        # Interface on the virtualization host, that the services that need to be
        # accessible to the virtual machines, but not to the outside network have to
        # listen (e.g. Postfix)
        #
        # For now, activation needs a reboot to not to complicate the configuration
        #
        package { 'tunctl':
            ensure => 'present',
        }
    }

    #
    # Distribute Red Hat interface definitions
    #
    define install_configurations {

        $port_def = regsubst($name, '^(.*)', '/etc/sysconfig/network-scripts/ifcfg-\1')
        $port_src = regsubst($name, '^(.*)', 'puppet:///nodes/network-scripts/ifcfg-\1')

        file { $port_def:
            ensure => 'file',
            source => $port_src,
        }

    }

    install_configurations { $ports: ; }

}

#
# Class that completely disables IPV6 support on a system
#
class network::ipv6::disable {

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
        content => "# ZYV\n${modprobe_content}"
    }

    service { 'ip6tables':
        enable => 'false',
        ensure => 'stopped',
    }

    augeas::insert_comment { 'network':
        file => '/etc/sysconfig/network',
    }

    augeas { 'network':
        context => '/files/etc/sysconfig/network',
        changes => 'set NETWORKING_IPV6 "no"',
    }

}
