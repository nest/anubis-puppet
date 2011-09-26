# ZYV

#
# OpenSSH server class
#
class openssh {
    include openssh::params
    include openssh::install
    include openssh::config
    include openssh::service
}

class openssh::params {
    case "$operatingsystem" {
        /RedHat|Scientific|Fedora/: {
            $package_core = [
                'openssh',
                'openssh-server',
                'openssh-clients',
            ]
            $package_xauth = [
                'xorg-x11-xauth',
                'xorg-x11-fonts-misc',
                'liberation-mono-fonts',
                'liberation-sans-fonts',
                'liberation-serif-fonts',
            ]
            $service = 'sshd'
        }
        /Debian|Ubuntu/: {
            $package_core = [
                'openssh-server',
                'openssh-client',
            ]
            $package_xauth = [
                'xauth',
                'xfonts-base',
            ]
            $service = 'ssh'
        }
        default: { fail('Unsupported operating system') }
    }
}

class openssh::install {
    package { $openssh::params::package_core:
        ensure => 'present',
    }
}

class openssh::install::xauth {
    package { $openssh::params::package_xauth:
        ensure => 'present',
    }
}

class openssh::config {

    augeas::insert_comment { 'sshd_config':
        file => '/etc/ssh/sshd_config',
        require => Class['openssh::install'],
    }

    augeas { 'sshd_config':
        context => '/files/etc/ssh/sshd_config',
        changes => [
            'set PasswordAuthentication "no"',
            'set GSSAPIAuthentication "no"',
        ],
        notify => Class['openssh::service'],
        require => Class['openssh::install'],
    }

}

class openssh::service {
    service { 'openssh':
        name => $openssh::params::service,
        enable => 'true',
        ensure => 'running',
        require => [
            Class['openssh::install'],
            Class['openssh::config'],
        ]
    }
}
