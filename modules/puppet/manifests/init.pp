# ZYV

#
# Puppet client configuration
#
class puppet::client {

    package { 'puppet':
        ensure => 'present',
    }

    service { 'puppet':
        enable => 'true',
        ensure => 'running',
    }

}

#
# Puppet server configuration
#
class puppet::server {

    package { 'puppet-server':
        ensure => 'present',
    }

    service { 'puppetmaster':
        enable => 'true',
        ensure => 'running',
    }

    #
    # Ensures that the master Puppet configuration is always up to date
    #

#    vcsrepo { '/etc/puppet':
#        ensure => 'latest',
#        provider => 'git',
#        require => Package['git'],
#        revision => 'HEAD',
#        source => 'git://git.zaytsev.net/anubis-puppet.git',
#    }

}
