# ZYV

#
# OpenSSH server class
#
case "$operatingsystem" {
    /RedHat|Fedora/: { $ssh_packages = [ 'openssh', 'openssh-server', 'openssh-clients', ] }
    /Debian|Ubuntu/: { $ssh_packages = [ 'openssh-server', 'openssh-client', ] }
    default: { fail('Unsupported operating system') }
}

class ssh_server($xauth = 'false') {

    if $xauth == 'true' {
        case "$operatingsystem" {
            /RedHat|Fedora/: { $ssh_packages += [ 'xorg-x11-xauth', 'xorg-x11-fonts-misc', 'liberation-mono-fonts', 'liberation-sans-fonts', 'liberation-serif-fonts', ] }
            /Debian|Ubuntu/: { $ssh_packages += [ 'xauth', ] }
        }
    }

    package { $ssh_packages:
        ensure => 'present',
    }

    service { 'sshd':

        name => "${operatingsystem}" ? {
            /RedHat|Fedora/ => 'sshd',
            /Debian|Ubuntu/ => 'ssh',
            default => undef,
        },

        enable => 'true',
        ensure => 'running',
        require => Augeas['sshd_config'],

    }

    insert_comment { 'sshd_config':
        file => '/etc/ssh/sshd_config',
    }

    augeas { 'sshd_config':

        context => '/files/etc/ssh/sshd_config',

        changes => [
            'set PasswordAuthentication "no"',
            'set GSSAPIAuthentication "no"',
        ],

        notify => Service['sshd'],
        require => Package[$ssh_packages],

    }

}
