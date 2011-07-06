# ZYV

#
# Ensure that site admins are on the sudoers list
#
class sudoers {

    package { "sudo":
        ensure => "present",
    }

    file { "/etc/sudoers.d/admins":
        ensure => "file",
        group => "root",
        mode => "0440",
        owner => "root",
        source => "puppet:///common/sudoers/admins",
    }

}

#
# Custom fstab settings
#
class fstab {

    file { "/etc/fstab":
        ensure => "file",
        group => "root",
        mode => "0644",
        owner => "root",
        source => "puppet:///nodes/fstab",
    }

}

#
# Custom rc.local settings (i.e. elevator tweaks)
#
class rc_local {

    file { "/etc/rc.d/rc.local":
        ensure => "file",
        group => "root",
        mode => "0755",
        owner => "root",
        source => "puppet:///nodes/rc.local",
    }

}

#
# The EFI-based systems can only boot off a special vfat partition and for that
# reason software RAID1 is not supported in such configurations.
#
# to the second drive, so that in case if one of the hard drives in RAID fails,
# the system can still be booted off the second drive.
#
# The mount point for the backup partition is to be created from the kickstart
# during the system provisioning phase.
#
class efi_backup {

    file { "/mnt/efi":
        ensure => "directory",
        group => "root",
        mode => "0700",
        owner => "root",
        recurse => "true",
        source => "file:///boot/efi",
    }

}

#
# Local yum repositories on anubis (puppet etc.)
#
class yum_repos_anubis {

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

