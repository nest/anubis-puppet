# ZYV

#
# Virtualization server
#
node 'puppet.qa.nest-initiative.org' {

    include disable_ipv6
    include disable_services
    include resolver
    include iptables
    include logwatch
    include ntpdate

    include site_ops
    include sudoers

    include yum_ban_i386
    include yum_repos
    include yum_server

    include libvirt
    include puppet_server
    include storage

    class { 'interfaces': ports => ['em1', 'tap1'], tunctl => 'true', }

    include openssh
    include openssh::install::xauth

    class { 'apache': default_listen => '192.168.1.1:80', }

    class { 'postfix':
        settings => {
            mydomain => $domain,
            mydestination => $domain,
            inet_interfaces => '192.168.1.1',
            mynetworks => '192.168.1.0/24 192.168.122.0/24',
            relayhost => '[smtp.uni-freiburg.de]:25',
        },
    }

}

node 'jenkins.qa.nest-initiative.org' {
#    '192.168.1.1:25'
}

