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

    users::make_user { 'jenkins':
        user_name => 'jenkins',
        user_id => '1501',
        ssh_key => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAv9sgjXe/WVln7WLksLE+rpzjfaQUaMGS77zhUdtiK01/+FmkH1ZruNZ4M3HCjRS2P+sOt0P7qyTeGyraMNYok3RbOLO+mwh/T+hsVd7gI40mz+NDgCVtU89VTzdlei8XNvyqwjl9UEmnm1P87h7AsUrOHvfs+JhYFudUGgOkIaQhX47B3siF7YBZZ3pYeXdSJUHtAh7xFdtBEFbpcLC+SWIjpbjz5n/j+M7yc/soWrfJ2ZZa0B/GEp676qaLrxR0nxBWUddppSNZDJIyPreCPRPGPDjfYEVebmsIYIsqXwttWd7ADoqGVDaCMUY8wWv+bmbzVrxMmO5POTTdncWPL8AHEJfcuibraNlp5PKIcWD8al58ODiwtx+vm7p99d2h7VnVyNyS6TlHkPRC7i1Xe1C8Wvth0QLNGe/dTSKV6ehcf4PKUtBmUwE8uT1xcRqWS4X11RwZUN6/mRFJnjXVysusR+rd1WPHyUqSLZu2hnL05F3Zisi/6y3rGZNaJP+nm3DMR/TLWAGaRWgbG3AiZM1/zL239YVIIUoS26ziLUxcqNsXhu0W3m1SluStyJfdN9dQv9IRdtKqtN4slDIp9+rLqmPoAHSUcN1/y5X3qgCb3iUXmpv9gRhwEYnJfnjqfxvRHHjZaOWxYkMjgp3FngJ47fYkMAIUTQPcKwga//s=',
    }

}

class jenkins::slave::tmpfs {

    file { $jenkins::params::ramdisk :
        ensure => 'directory',
        mode => '1777',
        recurse => 'false',
        require => Class['jenkins::slave::user'],
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

class jenkins::builddeps::nest {

    $packages = [

        'autoconf',
        'automake',
        'libtool',
        'libtool-ltdl-devel',

        'gsl-devel',
        'numpy',
        'openmpi-devel',
        'python-devel',
        'readline-devel',

    ]

    package { $packages :
        ensure => 'present',
    }

}

class jenkins::builddeps::sumatra {

    $packages = [

        'Django',
        'django-tagging',

        'python-coverage',
        'python-httplib2',
        'python-nose',
        'python-setuptools',
        'python-simplejson',

        'GitPython',
        'pysvn',

        'mpi4py',

    ]

    package { $packages :
        ensure => 'present',
    }

}
