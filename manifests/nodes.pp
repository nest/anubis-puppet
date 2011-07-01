# ZYV

node 'puppet.qa.nest-initiative.org' {

    include sudoers

    yumrepo { "rhel-6-local-noarch":
        baseurl => "file:///srv/repos/rhel-6-local/noarch",
        descr => "rhel-6-local-noarch",
        enabled => 1,
        gpgcheck => 0,
    }

    yumrepo { "rhel-6-local-x86_64":
        baseurl => "file:///srv/repos/rhel-6-local/x86_64",
        descr => "rhel-6-local-x86_64",
        enabled => 1,
        gpgcheck => 0,
    }

}

