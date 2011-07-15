# ZYV

#
# Virtualization server
#
node 'puppet.qa.nest-initiative.org' {

    include efi_backup
    include fstab
    include mail_server
    include master_configuration
    include rc_local
    include yum_repos_anubis

    include site_ops
    include sudoers

}

