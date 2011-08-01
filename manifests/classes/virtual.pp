# ZYV

#
# Virtualization host storage setup
#
class storage {

    #
    # Basic LVM settings
    #
    physical_volume { '/dev/sda1':
        ensure => 'present',
    }

    physical_volume { '/dev/md1':
        ensure => 'present',
    }

    volume_group { 'vg_anubis_fast':
        ensure => 'present',
        physical_volumes => '/dev/sda1',
    }

    volume_group { 'vg_anubis_slow':
        ensure => 'present',
        physical_volumes => '/dev/md1',
    }

    #
    # Custom fstab settings
    #
    file { '/etc/fstab':
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        source => 'puppet:///nodes/fstab',
    }

    #
    # Custom elevator tweaks
    #
    # (move back to a proper class if more unrelated stuff is added)
    #
    file { '/etc/rc.d/rc.local':
        ensure => 'file',
        group => 'root',
        mode => '0755',
        owner => 'root',
        source => 'puppet:///nodes/rc.local',
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
    file { '/mnt/efi':
        ensure => 'directory',
        group => 'root',
        mode => '0700',
        owner => 'root',
        recurse => 'true',
        source => 'file:///boot/efi',
    }

    #
    # Directory that hosts various infrastructural content
    #
    file { '/srv/infra':
        ensure => 'directory',
        group => 'root',
        mode => '0644',
        owner => 'root',
    }

    #
    # This directory contains boot media
    #
    file { '/srv/infra/isos':
        ensure => 'directory',
        group => 'qemu',
        mode => '0644',
        owner => 'qemu',
        recurse => 'true',
        selinux_ignore_defaults => 'true',
    }

}

#
# Virtualization-related settings
#

$kickstarts_path = '/srv/infra/kickstarts'
$kickstarts_domain = 'qa.nest-initiative.org'
$kickstarts_server = '192.168.122.1'

class libvirt {

    #
    # Defaults for all File resources in this class
    #
    File {
        group => 'root',
        mode => '0644',
        owner => 'root',
    }

    #
    # Storage for the virtual machine running Jenkins
    #
    logical_volume { 'vm_jenkins_main':
        ensure => 'present',
        volume_group => 'vg_anubis_fast',
        size => '16G',
    }

    logical_volume { 'vm_jenkins_swap':
        ensure => 'present',
        volume_group => 'vg_anubis_slow',
        size => '8G',
    }

    #
    # libvirt default network definition
    #
    $libvirt_network = '/tmp/config/libvirt/network-default.xml'

    file { [ '/tmp/config', '/tmp/config/libvirt', ]:
        ensure => 'directory',
    }

    file { "$libvirt_network":
        ensure => 'file',
        source => 'puppet:///nodes/libvirt/network-default.xml',
    }

    exec { 'libvirt-define-network':
        command => "virsh net-define $libvirt_network && virsh net-destroy default && virsh net-start default",
        cwd => '/tmp/config/libvirt',
        logoutput => 'true',
        refreshonly => 'true',
        require => File["$libvirt_network"],
        subscribe => File["$libvirt_network"],
    }

    #
    # This directory contains kickstarts for RH-based distributions
    #
    file { "$kickstarts_path":
        ensure => 'directory',
        recurse => 'true',
        seltype => 'httpd_sys_content_t',
    }

    #
    # Serve kickstarts repository
    #
    file { '/etc/httpd/conf.d/kickstarts.conf':
        ensure => 'file',
        require => Class['web_server::package'],
        notify => Class['web_server::service'],
        content => '
            # ZYV
            #
            # Internal kickstarts repository
            #
            Alias /kickstarts /srv/infra/kickstarts
            ',
    }

    #
    # Better ignore SELinux contexts here, because the are set by the update script
    #
    file { '/srv/infra/kickstarts':
        ensure => 'directory',
        group => 'root',
        mode => '0644',
        owner => 'root',
        recurse => 'true',
        seltype => 'httpd_sys_content_t',
    }

    #
    # Make a kickstart for jenkins, the ci master host (RHEL6)
    #
    make_kickstart { 'jenkins':
        name => 'jenkins',
        prefix => 'rhel',
        ks_info => {
            firewall => '--http',
            net_ip  => '192.168.122.101',
            net_msk => '255.255.255.0',
            net_ns  => "$kickstarts_server",
            net_gw  => "$kickstarts_server",
            releasever => '6Server',
            basearch => 'x86_64',
            packages => '

                # Packages not needed on virtual hosts
                -ntp
                -ntpdate
                -smartmontools

                # We only use RHN Classic!
                -subscription-manager

            ',
        },
    }

}

#
# Creates personalized kickstart files from a template
#
define make_kickstart($name, $prefix, $ks_info) {

    file { "$kickstarts_path/$prefix-$name-ks.cfg":
        content => template('default-ks.cfg.erb'),
        ensure => 'file',
        group => 'root',
        mode => '0644',
        owner => 'root',
        seltype => 'httpd_sys_content_t',
    }

}

