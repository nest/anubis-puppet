# ZYV

$infra_path = '/srv/infra'

$infra_address  = '192.168.1.1'
$infra_subnet   = '192.168.1.0/24'

$libvirt_subnet = '192.168.122.0/24'

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

    include disable_ipv6
    include disable_services
    include resolver
    include iptables
    include logwatch
    include ntpdate

    include site_ops
    include sudoers

    include storage
    include libvirt

    class { 'interfaces': ports => ['em1', 'tap1'], tunctl => 'true', }

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

