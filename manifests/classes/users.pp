# ZYV

#
# Ensure that site admins are on the sudoers list
#
class users::sudoers {

    package { 'sudo':
        ensure => 'present',
    }

    file { '/etc/sudoers.d/admins':
        ensure => 'file',
        mode => '0440',
        require => Package['sudo'],
        source => 'puppet:///common/sudoers/admins',
    }

}

define users::make_admin($user_name, $user_id, $ssh_key = 'undefined', $ensure = 'present') {

    if $ensure == 'absent' {
        Ssh_authorized_key["${user_name}"] -> User["${user_name}"] -> Group["${user_name}"]
    }

    user { "${user_name}":
        comment => 'Puppet-managed admin account',
        ensure => "${ensure}",
        gid => "${user_id}",
        groups => [
            'wheel',
        ],
        home => "/home/${user_name}",
        managehome => 'true',
        shell => '/bin/bash',
        uid => "${user_id}",
    }

    group { "${user_name}":
        ensure => "${ensure}",
        gid => "${user_id}",
        system => 'false',
    }

    ssh_authorized_key { "${user_name}":
        ensure => "${ensure}",
        key => "${ssh_key}",
        type => 'ssh-rsa',
        user => "${user_name}",
    }

}

class users::admins {

    users::make_admin { 'zaytsev':
        user_name => 'zaytsev',
        user_id => '501',
        ssh_key => 'AAAAB3NzaC1yc2EAAAABIwAAAgEApS91Y4DxkPTFX6izRa/ClYc0qhNHsZvybAipbZPXbjdR0CRTgR4ZIzCzgdGh5iZexP9Q4ULHeR9ozrnXg69xmOdAJqq2/A0XGAvJq4sj+W38nDZ5tgT/8So2kH1ifjwT3ItF16aHi1b6GenMh2cB9mXu3VTE0rvsoTNoykbrT+GjlVjBT1UbfcUAbIR8Lz6LA+xUApIuz+eSWbyLMsjZoO0B8NO9boAVqVsw8CzwSZQZET0b6ekhde0YoQky7areuGvhtwQZ3XADWhPmkVmK8bBAffgdTOy6czHugfeq1NrFYUL0hEvV62a3uQnyDlBZNU8raGKEA8dCMN1uTdv1DVxTabxdd5fSTpRxbizp60XFj/DrU1JzIQ4w5zNlyM9yK3s+YD/pCCfz/iySaKp6VMEOkZNY0WrvfuiEcNSkh3Ga+5Nx0Q3m3SN06irSX8UYuy7y7Z23YpSDqdxnUm4ibQ2x+RGbv3CY5YuVyHbAe930T/94MMg3/h47YILXsnawA1OeyYF7UgydEOihC/FzkQf41ejvOmqPmSDHDRJRbeP97yH6O9pXvkuJavRY5/897HZab+MnCLXeWAAHhJ5UvcQq0Te+S8FwQqp9q4mDNzqjpC0549kck8qts1lHAzKfK/LrZV4nD+Pc/8rENrnOqpodkvNjOLjPu5BYYjporK0=',
    }

    users::make_admin { 'wiebelt':
        user_name => 'wiebelt',
        user_id => '502',
        ensure => 'absent',
    }

}
