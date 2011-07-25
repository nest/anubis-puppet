# ZYV

#
# Use Augeas to insert a comment tag at the top of the file, if it does not
# already exist
#
# Most useful to indicate that the file is managed by Puppet
#
define insert_comment($file, $comment = 'ZYV: Managed by Puppet', $lens_comment = '#comment', $load_path = undef) {

    augeas { "${file}: comment tag":
        context => "/files${file}",
        changes => [
            "ins ${lens_comment} before *[1]",
            "set ${lens_comment}[1] '${comment}'",
        ],
        onlyif => "match ${lens_comment}[.='${comment}'] size == 0",
        load_path => $load_path,
    }

}

#
# Ensure that site admins are on the sudoers list
#
class sudoers {

    package { 'sudo':
        ensure => 'present',
    }

    file { '/etc/sudoers.d/admins':
        ensure => 'file',
        group => 'root',
        mode => '0440',
        owner => 'root',
        require => Package['sudo'],
        source => 'puppet:///common/sudoers/admins',
    }

}

#
# Custom fstab settings
#
class fstab {

    file { '/etc/fstab':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        source => 'puppet:///nodes/fstab',
    }

}

#
# Distribute default firewall settings
#
class iptables {

    file { '/etc/sysconfig/iptables':
        ensure => 'file',
        group => 'root',
        mode => '0600',
        notify => Service['iptables'],
        owner => 'root',
        source => 'puppet:///nodes/sysconfig/iptables',
    }

    service { 'iptables':
        enable => 'true',
        ensure => 'running',
    }

}

#
# Class that completely disables IPV6 support on a system
#
class disable_ipv6 {

    # https://access.redhat.com/kb/docs/DOC-8711
    #
    # - Disabling IPv6 support in Red Hat Enterprise Linux 6
    #
    # options ipv6 disable=1
    #
    # - Disabling IPv6 support in Red Hat Enterprise Linux 5
    #
    # alias ipv6 off
    # alias net-pf-10 off
    # options ipv6 disable=1
    #
    # - Disabling IPv6 support in Red Hat Enterprise Linux 4
    #
    # alias ipv6 off
    # alias net-pf-10 off
    #

    #
    # Extend via facter to support multiple platforms some day
    #
    $modprobe_content = 'options ipv6 disable=1'

    file { '/etc/modprobe.d/disable-ipv6.conf':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        content => "# ZYV\n${modprobe_content}"
    }

    service { 'ip6tables':
        enable => 'false',
        ensure => 'stopped',
    }

    insert_comment { 'network':
        file => '/etc/sysconfig/network',
    }

    augeas { 'network':
        context => '/files/etc/sysconfig/network',
        changes => 'set NETWORKING_IPV6 "no"',
    }

}

#
# Interface on the virtualization host, that the services that need to be
# accessible to the virtual machines, but not to the outside network have to
# listen (e.g. Postfix)
#
# For now, activation needs a reboot to not to complicate the configuration
#
class internal_interface {

    package { 'tunctl':
        ensure => 'present',
    }

    file { '/etc/sysconfig/network-scripts/ifcfg-tap1':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        require => Package['tunctl'],
        source => 'puppet:///nodes/network-scripts/ifcfg-tap1',
    }

}


#
# Custom rc.local settings (i.e. elevator tweaks)
#
class rc_local {

    file { '/etc/rc.d/rc.local':
        ensure => 'file',
        group => 'root',
        mode => '0755',
        owner => 'root',
        source => 'puppet:///nodes/rc.local',
    }

}

#
# The EFI-based systems can only boot off a special vfat partition and for that
# reason software RAID1 is not supported in such configurations.
#
# This class makes sure that the main EFI boot partition is backed up to to the
# second drive as it changes, so that in case if one of the hard drives in the
# RAID array fails, the system can still boot off the second drive.
#
# The mount point for the backup partition is to be created from the kickstart
# during the system provisioning phase.
#
class efi_backup {

    file { '/mnt/efi':
        ensure => 'directory',
        group => 'root',
        mode => '0700',
        owner => 'root',
        recurse => 'true',
        source => 'file:///boot/efi',
    }

}

#
# Ensures that the master Puppet configuration is always up to date
#
class master_configuration {

    package { 'git':
        ensure => 'present',
    }

#    vcsrepo { '/etc/puppet':
#        ensure => 'latest',
#        provider => 'git',
#        require => Package['git'],
#        revision => 'HEAD',
#        source => 'git://git.zaytsev.net/anubis-puppet.git',
#    }

}

#
# Class that sets up a smart-hosting postfix on the virtualization server
#

$email_domain = 'qa.nest-initiative.org'

$email_zaytsev = 'yury.zaytsev@bcf.uni-freiburg.de'
$email_wiebelt = 'wiebelt@bcf.uni-freiburg.de'

$email_root = "${email_zaytsev}"

class mail_server {

    package { 'postfix':
        ensure => 'present',
    }

    service { 'postfix':
        enable => 'true',
        ensure => 'running',
        require => [
            Augeas['main.cf'],
            Package['postfix'],
        ]
    }

    insert_comment { 'main.cf':
        file => '/etc/postfix/main.cf',
    }

    augeas { 'main.cf':

        context => '/files/etc/postfix/main.cf',
        changes => [

            'set inet_protocols "ipv4"',
            'set inet_interfaces "127.0.0.1, 192.168.1.1"',

            "set mydomain '${email_domain}'",

            'set myorigin "$mydomain"',
            'set myhostname "$mydomain"',
            'set mydestination "$mydomain, puppet, puppet.$mydomain, localhost, localhost.localdomain, localhost4, localhost4.localdomain4"',

            'set mynetworks_style "host"',
            'set mynetworks "127.0.0.0/8, 192.168.1.0/24, 192.168.122.0/24"',

            'set relayhost "[smtp.uni-freiburg.de]:25"',

            'set smtp_tls_security_level "may"',
            'set smtp_tls_CAfile "/etc/pki/tls/certs/ca-bundle.crt"',
        ],

        notify => Service['postfix'],
        require => Package['postfix'],

    }

    mailalias { 'root':
        ensure => 'present',
        recipient => "${email_root}",
    }

    mailalias { 'zaytsev':
        ensure => 'present',
        recipient => "${email_zaytsev}",
    }

    mailalias { 'wiebelt':
        ensure => 'present',
        recipient => "${email_wiebelt}",
    }

}


#
# OpenSSH server class
#
class ssh_server {

    case "$operatingsystem" {
        /RedHat|Fedora/: { $ssh_packages = [ 'openssh', 'openssh-server', 'openssh-clients', ] }
        /Debian|Ubuntu/: { $ssh_packages = [ 'openssh-server', 'openssh-client', ] }
        default: { fail('Unsupported operating system') }
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

#
# Local yum repositories on anubis (puppet etc.)
#
class yum_repos_anubis {

    #
    # TODO: think of how to best get the files there
    #
    yumrepo { 'rhel-6-local-noarch':
        baseurl => 'file:///srv/repos/rhel-6-local/noarch',
        descr => 'rhel-6-local-noarch',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/repos'],
    }

    yumrepo { 'rhel-6-local-x86_64':
        baseurl => 'file:///srv/repos/rhel-6-local/x86_64',
        descr => 'rhel-6-local-x86_64',
        enabled => '1',
        gpgcheck => '0',
        require => File['/srv/repos'],
    }

    file { '/srv/repos':
        ensure => 'directory',
        group => 'root',
        mode => '0644',
        owner => 'root',
        recurse => 'true',
    }

    file { '/srv/repos/update-metadata':
        ensure => 'file',
        group => 'root',
        mode => '0755',
        owner => 'root',
        require => File['/srv/repos'],
        source => 'puppet:///nodes/update-metadata',
    }

    exec { 'update_metadata':
        command => '/srv/repos/update-metadata',
        cwd => '/srv/repos',
        logoutput => 'true',
        refreshonly => 'true',
        require => File['/srv/repos/update-metadata'],
        subscribe => File['/srv/repos'],
    }

}

#
# Yum settings
#
class yum_exclude_32bit {

    insert_comment { 'yum_exclude_32bit':
        file => '/etc/yum.conf',
    }

    augeas { 'yum_exclude_32bit':
        context => '/files/etc/yum.conf/main',
        changes => [
            'set exclude "*.i?86"',
        ],
    }

}

#
# Services that should be disabled by default
#
class disable_services {

    $services_to_disable = [
        'avahi-daemon',
        'iscsi',
        'iscsid',
        'kdump',
        'netfs',
        'nfs',
        'nfslock',
        'rpcbind',
        'rpcgssd',
        'rpcidmapd',
    ]

    service { $services_to_disable:
        enable => 'false',
        ensure => 'stopped',
    }

}

#
# Keeps system time in sync with a local time server
#
# According to the RHEL hardening guide it is more secure to update the time
# every once in a while with ntpdate as opposed to running a full blown ntp
# server
#
class ntpdate {

    package { 'ntpdate':
        ensure => 'present',
    }

    cron { 'ntpdate':
        command => '/usr/sbin/ntpdate time.uni-freiburg.de && /usr/sbin/hwclock --systohc',
        ensure => 'present',
        hour => '3',
        minute => '30',
        user => 'root',
    }

}

