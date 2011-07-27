# ZYV

#
# Local yum repositories on anubis (puppet etc.)
#
class yum_repos_anubis {

    #
    # TODO: think of how to best get the files there
    #
    yumrepo { 'rhel-6-local-noarch':
        baseurl => 'file:///srv/infra/repos/rhel-6-local/noarch',
        descr => 'rhel-6-local-noarch',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/infra/repos'],
    }

    yumrepo { 'rhel-6-local-x86_64':
        baseurl => 'file:///srv/infra/repos/rhel-6-local/x86_64',
        descr => 'rhel-6-local-x86_64',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/infra/repos'],
    }

    file { '/srv/infra/repos':
        ensure => 'directory',
        group => 'root',
        mode => '0644',
        owner => 'root',
        recurse => 'true',
        selinux_ignore_defaults => 'true',
    }

    file { '/srv/infra/repos/update-metadata':
        ensure => 'file',
        group => 'root',
        mode => '0755',
        owner => 'root',
        require => File['/srv/infra/repos'],
        source => 'puppet:///nodes/update-metadata',
    }

    exec { 'update_metadata':
        command => '/srv/infra/repos/update-metadata',
        cwd => '/srv/infra/repos',
        logoutput => 'true',
        refreshonly => 'true',
        require => File['/srv/infra/repos/update-metadata'],
        subscribe => File['/srv/infra/repos'],
    }

}

#
# Yum settings
#
class yum_exclude_32bit {

# Augeus 0.7 lenses do not support yum.conf comments (yet?)
#
#    insert_comment { 'yum_exclude_32bit':
#        file => '/etc/yum.conf',
#    }

    augeas { 'yum_exclude_32bit':
        context => '/files/etc/yum.conf/main',
        changes => [
            'set exclude "*.i?86"',
        ],
    }

}
