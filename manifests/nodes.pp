# ZYV

node 'puppet.qa.nest-initiative.org' {

    include fstab
    include sudoers
    include yum_repos_anubis

}

