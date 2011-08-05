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
