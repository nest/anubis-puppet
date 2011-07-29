# ZYV

#
# Virtualization server
#
node 'puppet.qa.nest-initiative.org' {

    include disable_ipv6
    include disable_services
    include hosts
    include iptables
    include logwatch
    include ntpdate

    include site_ops
    include sudoers

    include yum_ban_i386
    include yum_repos
    include yum_server

    include interfaces
    include libvirt
    include mail_server
    include puppet_server
    include storage
    include web_server

    class { 'ssh_server': xauth => 'true' }

}

