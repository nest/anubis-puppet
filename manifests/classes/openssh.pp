# ZYV

#
# OpenSSH server class
#
class openssh($xauth = 'false') {
    include openssh::params
    include openssh::install
    include openssh::config
    include openssh::service
}

class openssh::params {
    case "$operatingsystem" {
        /RedHat|Fedora/: {
            $package = [
                'openssh',
                'openssh-server',
                'openssh-clients',
            ]
            $xauth = [
                'xorg-x11-xauth',
                'xorg-x11-fonts-misc',
                'liberation-mono-fonts',
                'liberation-sans-fonts',
                'liberation-serif-fonts',
            ]
            $service = 'sshd'
        }
        /Debian|Ubuntu/: {
            $package = [
                'openssh-server',
                'openssh-client',
            ]
            $xauth = [
                'xauth',
                'xfonts-base',
            ]
            $service = 'ssh'
        }
        default: { fail('Unsupported operating system') }
    }
}

class openssh::install {

    if $openssh::xauth == 'true' {
        $packages = [ $openssh::params::package, $openssh::params::xauth, ]
    } else {
        $packages = $openssh::params::package
    }

    package { $packages:
        ensure => 'present',
    }

}

class openssh::config {

    insert_comment { 'sshd_config':
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
