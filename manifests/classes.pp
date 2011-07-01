# ZYV

class sudoers {

    file { "/etc/sudoers.d/admins":
        ensure => "file",
        group => "root",
        mode => 440,
        owner => "root",
        source => "puppet:///common/sudoers/admins",
    }

}
