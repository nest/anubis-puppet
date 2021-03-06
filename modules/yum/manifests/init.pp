# ZYV

#
# Yum repositories on the virtualization server
#
class yum::server($repos_path) {

    if $repos_path == undef {
        fail('This class requires $repos_path to be passed!')
    }

    #
    # Make sure that the metadata generator is installed
    #
    package { 'createrepo':
        ensure => 'present',
    }

    #
    # Serve yum repositories
    #
    file { '/etc/httpd/conf.d/yum.conf':
        ensure => 'file',
        require => Class['apache::install'],
        notify => Class['apache::service'],
        content => "
            # ZYV
            #
            # Internal yum repositories
            #
            Alias /repos ${repos_path}
            ",
    }

    #
    # Better ignore SELinux contexts here, because the are set by the update script
    #
    file { $repos_path:
        ensure => 'directory',
        recurse => 'true',
        selinux_ignore_defaults => 'true',
    }

    #
    # This script re-generates repomd metadata for all repos upon updates
    #
    file { "${repos_path}/update-metadata":
        ensure => 'file',
        mode => '0755',
        require => File[$repos_path],
        source => 'puppet:///nodes/update-metadata',
        selinux_ignore_defaults => 'true',
    }

    #
    # It will be called whenever there is a file in the repos with a different
    # owner or permissions mask, which is what happens when files are uploaded on
    # the server and then moved by root into the repos, because mv retains the
    # ownership and permissions
    #
    exec { 'update-metadata':
        command => "${repos_path}/update-metadata",
        cwd => $repos_path,
        logoutput => 'true',
        refreshonly => 'true',
        require => [
            Package['createrepo'],
            File["${repos_path}/update-metadata"],
        ],
        subscribe => File[$repos_path],
        user => 'root',
    }

}

#
# Local yum repositories for Red Hat based hosts
#
class yum::repos::rhel {

    yumrepo { 'rhel-local-noarch':
        baseurl => 'http://puppet/repos/rhel-$releasever-local/noarch',
        descr => 'Red Hat Enterprise Linux $releasever - noarch - Local packages (ZYV)',
        enabled => '1',
        gpgcheck => '0',
    }

    yumrepo { 'rhel-local-binary':
        baseurl => 'http://puppet/repos/rhel-$releasever-local/$basearch',
        descr => 'Red Hat Enterprise Linux $releasever - $basearch - Local packages (ZYV)',
        enabled => '1',
        gpgcheck => '0',
    }
}

#
# Local yum repositories for Fedora based hosts
#
class yum::repos::fc {

    yumrepo { 'fc-local-noarch':
        baseurl => 'http://puppet/repos/fc-$releasever-local/noarch',
        descr => 'Fedora $releasever - noarch - Local packages (ZYV)',
        enabled => '1',
        gpgcheck => '0',
    }

    yumrepo { 'fc-local-binary':
        baseurl => 'http://puppet/repos/fc-$releasever-local/$basearch',
        descr => 'Fedora $releasever - $basearch - Local packages (ZYV)',
        enabled => '1',
        gpgcheck => '0',
    }
}

#
# Ban i386 packages from x86_64 systems
#
class yum::ban::i386 {

# Augeas 0.7 lenses do not support yum.conf comments (yet?)
#
#    augeas::insert_comment { 'yum_exclude_32bit':
#        file => '/etc/yum.conf',
#    }

    augeas { 'yum_ban_i386':
        context => '/files/etc/yum.conf/main',
        changes => [
            'set exclude "*.i?86"',
        ],
    }

#
# Activate on RHEL5 installations, should be no longer relevant to RHEL6
#

#    exec { 'yum_remove_i386':
#        command => '/bin/sh -c "yum remove \*.i\?86 && yum -y reinstall \*"',
#        refreshonly => 'true',
#        require => Augeas['yum_ban_i386'],
#        subscribe => Augeas['yum_ban_i386'],
#        user => 'root',
#    }

}

#
# Quasi-safe yum automatic updates run during the night
#
class yum::autoupdate {

    file { "${infra_config}/yum-autoupdate":
        ensure => 'file',
        mode => '0755',
        source => 'puppet:///common/yum-autoupdate',
    }

    $cron_hour   = fqdn_rand(4)
    $cron_minute = fqdn_rand(60)

    cron { 'yum-autoupdate':
        command => "${infra_config}/yum-autoupdate >/dev/null 2>&1",
        ensure => 'present',
        hour => $cron_hour,
        minute => $cron_minute,
        user => 'root',
        require => File["${infra_config}/yum-autoupdate"],
    }

}
