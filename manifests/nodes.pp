# ZYV

node 'puppet.qa.nest-initiative.org' {

    include fstab
    include mounts_anubis
    include sudoers
    include yum_repos_anubis

}

