# ZYV

class sudoers {

    file { "/etc/sudoers.d/admins":
        ensure => "file",
        group => "root",
        mode => "0440",
        owner => "root",
        source => "puppet:///common/sudoers/admins",
    }

}

class fstab {

    file { "/etc/fstab":
        ensure => "file",
        group => "root",
        mode => "0644",
        owner => "root",
        source => "puppet:///nodes/fstab",
    }

}

class mounts_anubis {

    file { "mount_efi_anubis":
        path => "/mnt/efi",
        ensure => "directory",
        group => "root",
        mode => "0644",
        owner => "root",
        recurse => false,
    }

}

class yum_repos_anubis {

    # Local yum repositories on anubis (puppet etc.)
    #
    # TODO: think of how to best get the files there
    #
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

    file { "/srv/repos":
        ensure => "directory",
        group => "root",
        mode => "0644",
        owner => "root",
        recurse => true,
    }

    file { "/srv/repos/update-metadata":
        ensure => "file",
        group => "root",
        mode => "0755",
        owner => "root",
        source => "puppet:///nodes/update-metadata",
    }

    exec { "update_metadata":
        command => "/srv/repos/update-metadata",
        cwd => "/srv/repos",
        logoutput => true,
        refreshonly => true,
        subscribe => File["/srv/repos"],
    }

}

