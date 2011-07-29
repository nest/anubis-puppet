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
    # This directory contains varios boot media
    #
    file { '/srv/infra/isos':
        ensure => 'directory',
        group => 'root',
        mode => '0644',
        owner => 'root',
        recurse => 'true',
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
    file { '/etc/libvirt/qemu/networks/default.xml':
        ensure => 'file',
        source => 'puppet:///nodes/libvirt/qemu/networks/default.xml',
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
        },
    }

}

#
# Creates personalized kickstart files from a template
#
define make_kickstart($name, $prefix, $ks_info) {

    $hostname = "$name.$kickstarts_domain"

    file { "$kickstarts_path/$prefix-$name-ks.cfg":
        content => template('default-ks.cfg.erb'),
        ensure => 'present',
        group => 'root',
        mode => '0644',
        owner => 'root',
        seltype => 'httpd_sys_content_t',
    }

}

