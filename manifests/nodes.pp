# ZYV

#
# Virtualization server
#
node 'puppet.qa.nest-initiative.org' {

    include disable_ipv6
    include disable_services
    include iptables
    include logwatch
    include ntpdate
    include site_ops
    include sudoers
    include yum_exclude_32bit
    include yum_repos_anubis

    include storage
    include internal_interface
    include mail_server
    include puppet_server

    class { 'ssh_server': xauth => 'true' }

}

