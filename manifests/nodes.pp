# ZYV

node 'puppet.qa.nest-initiative.org' {

    include efi_backup
    include fstab
    include rc_local
    include sudoers
    include yum_repos_anubis

}

