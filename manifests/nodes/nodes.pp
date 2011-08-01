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
    include mail_server
    include puppet_server
    include storage

    class { 'interfaces': ports => ['em1', 'tap1'], tunctl => 'true', }
    class { 'web_server': default_listen => '192.168.1.1:80', }
    class { 'ssh_server': xauth => 'true', }

}

