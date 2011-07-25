# ZYV

#
# Virtualization server
#
node 'puppet.qa.nest-initiative.org' {

    include disable_ipv6
    include disable_services
    include efi_backup
    include fstab
    include internal_interface
    include iptables
    include logwatch
    include ntpdate
    include rc_local
    include site_ops
    include sudoers
    include yum_exclude_32bit
    include yum_repos_anubis

    include mail_server
    include puppet_server
    include ssh_server

}

