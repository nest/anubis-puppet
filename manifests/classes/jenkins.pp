# ZYV


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
