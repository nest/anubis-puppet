# ZYV

class jenkins::params {

    $ramdisk = '/mnt/ram'
    $ramsize = '2G'

}

class jenkins::install {

    package { 'jenkins':
        ensure => 'present',
        require => Class['services::java'],
    }

    exec { 'jenkins':
        command => 'rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
        logoutput => 'true',
        refreshonly => 'true',
        subscribe => Package['jenkins'],
        user => 'root',
    }

}

class jenkins::config {
     file { '/etc/sysconfig/jenkins':
         ensure => 'file',
         mode => '0600',
         notify => Class['jenkins::service'],
         require => Class['jenkins::install'],
         source => 'puppet:///nodes/sysconfig/jenkins',
     }
}

class jenkins::service {
    service { 'jenkins':
        enable => 'true',
        ensure => 'running',
        require => [
            Class['jenkins::config'],
            Class['jenkins::install'],
        ]
    }
}

class jenkins::slave::user {
}

class jenkins::slave::tmpfs {

    file { $jenkins::params::ramdisk :
        ensure => 'directory',
        group => 'jenkins',
        mode => '0755',
        owner => 'jenkins',
        recurse => 'false',
    }

    mount { $jenkins::params::ramdisk :
        atboot => 'true',
        device => 'tmpfs',
        dump => '0',
        ensure => 'mounted',
        fstype => 'tmpfs',
        options => "size=${jenkins::params::ramsize}",
        pass => '0',
        remounts => 'true',
        require => File[$jenkins::params::ramdisk],
    }

}
