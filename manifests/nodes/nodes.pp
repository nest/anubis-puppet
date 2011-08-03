# ZYV

$infra_path = '/srv/infra'

$infra_address  = '192.168.1.1'
$infra_subnet   = '192.168.1.0/24'

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
        nameservers => [
            '132.230.201.111',
            '132.230.200.200',
        ],
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
            inet_interfaces => "${infra_address}",
            mynetworks => "${infra_subnet} ${libvirt_subnet}",
            relayhost => '[smtp.uni-freiburg.de]:25',
        },
    }

}

node 'jenkins.qa.nest-initiative.org' {
}

