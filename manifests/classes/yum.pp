# ZYV

#
# Local yum repositories for Red Hat based hosts
#
class yum_repos {

    yumrepo { 'rhel-local-noarch':
        baseurl => 'http://localhost/repos/rhel-$releasever-local/noarch',
        descr => 'Red Hat Enterprise Linux $releasever - noarch - Local packages',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/infra/repos'],
    }

    yumrepo { 'rhel-local-binary':
        baseurl => 'file:///srv/infra/repos/rhel-$releasever-local/$basearch',
        descr => 'Red Hat Enterprise Linux $releasever - $basearch - Local packages',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/infra/repos'],
    }
}

#
# Yum repositories on the virtualization server
#
class yum_server {

    #
    # Better ignore SELinux contexts here, because the are set by the update script
    #
    file { '/srv/infra/repos':
        ensure => 'directory',
        group => 'root',
        mode => '0644',
        owner => 'root',
        recurse => 'true',
        selinux_ignore_defaults => 'true',
    }

    #
    # This script re-generates repomd metadata for all repos upon updates
    #
    file { '/srv/infra/repos/update-metadata':
        ensure => 'file',
        group => 'root',
        mode => '0755',
        owner => 'root',
        require => File['/srv/infra/repos'],
        source => 'puppet:///nodes/update-metadata',
    }

    #
    # It will be called whenever there is a file in the repos with a different
    # owner or permissions mask, which is what happens when files are uploaded on
    # the server and then moved by root into the repos, because mv retains the
    # ownership and permissions
    #
    exec { 'update-metadata':
        command => '/srv/infra/repos/update-metadata',
        cwd => '/srv/infra/repos',
        logoutput => 'true',
        refreshonly => 'true',
        require => File['/srv/infra/repos/update-metadata'],
        subscribe => File['/srv/infra/repos'],
    }

}

#
# Ban i386 packages from x86_64 systems
#
class yum_ban_i386 {

# Augeus 0.7 lenses do not support yum.conf comments (yet?)
#
#    insert_comment { 'yum_exclude_32bit':
#        file => '/etc/yum.conf',
#    }

    augeas { 'yum_ban_i386':
        context => '/files/etc/yum.conf/main',
        changes => [
            'set exclude "*.i?86"',
        ],
    }

}
