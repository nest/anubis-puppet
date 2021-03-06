# ZYV

class jenkins::params {

    $ramdisk = '/mnt/ram'
    $ramsize = '6G'

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
        noverifyhosts => 'true',
    }

}

class jenkins::slave::ssh_key {

    file { '/home/jenkins/.ssh/id_rsa':
        group => 'jenkins',
        owner => 'jenkins',
        ensure => 'file',
        mode => '0600',
        require => Class['jenkins::slave::user'],
        source => 'puppet:///common/id_rsa',
    }

    file { '/home/jenkins/.ssh/id_rsa.pub':
        group => 'jenkins',
        owner => 'jenkins',
        ensure => 'file',
        mode => '0644',
        require => Class['jenkins::slave::user'],
        source => 'puppet:///common/id_rsa.pub',
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

class jenkins::builddeps::common {

    if $operatingsystem == 'Fedora' {
        case $operatingsystemrelease {
            15, 16, 17: {
                $pkg_ipython = 'ipython'
            }
            18: {
                $pkg_ipython = 'python-ipython'

                package { [ 'python3-ipython', 'python3-matplotlib', 'python3-matplotlib-tk' ] :
                    ensure => 'present',
                }

                # NEST ConnPlotter tutorial needs this
                package { [ 'texlive-multirow', 'texlive-pdfcrop' ] :
                    ensure => 'present',
                }

            }
            default: { fail('Unsupported version of Fedora') }
        }
    }

    $packages = [

        # Clang
        'clang-analyzer',
        'indent',

        # Required by Topographica
        'xorg-x11-server-Xvfb',

        'pylint',
        'pyflakes',

        # Required by NEST, PyNN and Topographica
        'python-devel',

        'numpy',
        'scipy',

        'python-virtualenv',

        'python-matplotlib',
        'python-matplotlib-tk',

        # Required by Sumatra and PyNN
        'python-coverage',
        'python-nose',
        'python-setuptools',

        # Required by Sumatra and PyNN
        'mpi4py-openmpi',

        # Nice to have
        $pkg_ipython,

        # Python 3 stack
        'python3',
        'python3-devel',

        'python3-numpy',
        'python3-scipy',

        'python3-nose',
        'python3-coverage',

        'python3-Cython',

        # Needed for documentation, e.g. NEST examples
        'texlive',
        'texlive-latex',

        'ghostscript',

    ]

    package { $packages :
        ensure => 'present',
    }

}

class jenkins::builddeps::java {

    if $operatingsystem == 'Fedora' {
        case $operatingsystemrelease {
            15, 16: { $java_openjdk_devel = 'java-1.6.0-openjdk-devel' }
            17, 18: { $java_openjdk_devel = 'java-1.7.0-openjdk-devel' }
            default: { fail('Unsupported version of Fedora') }
        }
    } else {
        fail('Unsupported build slave operating system')
    }

    $packages = [

        $java_openjdk_devel,
        'vecmath',

    ]

    package { $packages :
        ensure => 'present',
    }

}

class jenkins::builddeps::nest {

    $packages = [

        'autoconf',
        'automake',
        'libtool',
        'libtool-ltdl-devel',

        'gsl-devel',
        'openmpi-devel',
        'readline-devel',

        'Cython',

    ]

    package { $packages :
        ensure => 'present',
    }

}

class jenkins::builddeps::sumatra {

    if $operatingsystem == 'Fedora' {
        case $operatingsystemrelease {
            15, 16, 17: {
                $pkg_django = 'Django'
                $pkg_django_tagging = 'django-tagging'
            }
            18: {
                $pkg_django = 'python-django'
                $pkg_django_tagging = 'python-django-tagging'
            }
            default: { fail('Unsupported version of Fedora') }
        }
    }

    $packages = [

        $pkg_django,
        $pkg_django_tagging,

        'python-httplib2',
        'python-simplejson',

        'GitPython',
        'pysvn',

    ]

    package { $packages :
        ensure => 'present',
    }

}

class jenkins::builddeps::pynn {

    $packages = [

        'python-cheetah',
        'python-jinja2',
        'python-mock',

# Installed from within the build job locally
#        'nrn',
#        'python-nest',

    ]

    package { $packages :
        ensure => 'present',
    }

}

class jenkins::builddeps::mc {

    $packages = [

        # Required by autopoint :-(
        'cvs',

        'e2fsprogs-devel',
        'gettext-devel',
        'glib2-devel',
        'gpm-devel',
        'groff',
        'libssh2-devel',
        'slang-devel',
        'ncurses-devel',

        'check',
        'check-devel',

    ]

    package { $packages :
        ensure => 'present',
    }

}

class jenkins::builddeps::topographica {

    $packages = [

        'tkinter',
        'gmpy',

        'python-imaging',
        'python-imaging-tk',

    ]

    package { $packages :
        ensure => 'present',
    }

}
