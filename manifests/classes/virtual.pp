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
class libvirt {

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
        group => 'root',
        mode => '0644',
        owner => 'root',
        source => 'puppet:///nodes/libvirt/qemu/networks/default.xml',
    }

}

