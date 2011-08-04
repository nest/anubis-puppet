# ZYV

$infra_path = '/srv/infra'

$infra_address  = '192.168.1.1'
$infra_subnet   = '192.168.1.0/24'

$infra_dns = [ '132.230.201.111', '132.230.200.200', ]

$infra_relayhost = '[smtp.uni-freiburg.de]:25'

$infra_storage_slow_pv = '/dev/md1'
$infra_storage_slow_vg = 'vg_anubis_slow'

$infra_storage_fast_pv = '/dev/sda1'
$infra_storage_fast_vg = 'vg_anubis_fast'

$libvirt_server = '192.168.122.1'
$libvirt_subnet = '192.168.122.0/24'

$kickstarts_path = "${infra_path}/kickstarts"

#
# Virtualization server
#
node 'puppet.qa.nest-initiative.org' {

    #include puppet::client
    include puppet::server

    include yum::ban::i386
    include yum::repos::rhel

    class { 'yum::server':
        repos_path => "${infra_path}/repos",
    }

    include network::hosts::self
    include network::hosts::localhost

    class { 'network::resolver':
        nameservers => $infra_dns,
    }

    class { 'network::interfaces':
        ports => ['em1', 'tap1'],
        tunctl => 'true',
    }

    include network::ipv6::disable

    include services::disabled
    include services::git
    include services::iptables
    include services::logwatch
    include services::ntpdate

    include users::admins
    include users::sudoers

    include libvirt::storage
    include libvirt::networks
    include libvirt::machines
    include libvirt::kickstarts

    include openssh
    include openssh::install::xauth

    class { 'apache':
        settings => {
            listen => "${infra_address}:80",
        }
    }

    class { 'postfix':
        settings => {
            mydomain => $domain,
            mydestination => $domain,
            inet_interfaces => $infra_address,
            mynetworks => "${infra_subnet} ${libvirt_subnet}",
            relayhost => $infra_relayhost,
        },
    }

}

node 'jenkins.qa.nest-initiative.org' {

    include puppet::client

    include yum::ban::i386
    include yum::repos::rhel

    include network::hosts::self
    include network::hosts::localhost

    class { 'network::resolver':
        nameservers => [ $libvirt_server, ],
    }

    include network::ipv6::disable

    include users::admins
    include users::sudoers

    include openssh
    include openssh::install::xauth

}

