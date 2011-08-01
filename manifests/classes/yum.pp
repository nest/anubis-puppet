# ZYV

#
# Local yum repositories for Red Hat based hosts
#
class yum_repos {

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
# Yum repositories on the virtualization server
#
$yum_repos_path = '/srv/infra/repos'

class yum_server {

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
        require => Class['web_server::package'],
        notify => Class['web_server::service'],
        content => "
            # ZYV
            #
            # Internal yum repositories
            #
            Alias /repos ${yum_repos_path}
            ",
    }

    #
    # Better ignore SELinux contexts here, because the are set by the update script
    #
    file { "${yum_repos_path}":
        ensure => 'directory',
        recurse => 'true',
        selinux_ignore_defaults => 'true',
    }

    #
    # This script re-generates repomd metadata for all repos upon updates
    #
    file { "${yum_repos_path}/update-metadata":
        ensure => 'file',
        mode => '0755',
        require => File["${yum_repos_path}"],
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
        command => "${yum_repos_path}/update-metadata",
        cwd => "${yum_repos_path}",
        logoutput => 'true',
        refreshonly => 'true',
        require => [
            Package['createrepo'],
            File["${yum_repos_path}/update-metadata"],
        ],
        subscribe => File["${yum_repos_path}"],
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
