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
    include mail_server
    include master_configuration
    include ntpdate
    include rc_local
    include ssh_server
    include yum_repos_anubis
    include yum_exclude_32bit

    include site_ops
    include sudoers

}

