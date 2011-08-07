# ZYV

#
# Virtualization host storage setup
#
class libvirt::storage {

    #
    # Basic LVM settings
    #
    physical_volume { [$infra_storage_fast_pv, $infra_storage_slow_pv] :
        ensure => 'present',
    }

    volume_group { $infra_storage_fast_vg :
        ensure => 'present',
        physical_volumes => $infra_storage_fast_pv,
    }

    volume_group { $infra_storage_slow_vg :
        ensure => 'present',
        physical_volumes => $infra_storage_slow_pv,
    }

    #
    # Custom fstab settings
    #
    file { '/etc/fstab':
        ensure => 'file',
        source => 'puppet:///nodes/fstab',
    }

    #
    # Custom elevator tweaks
    #
    # (move back to a proper class if more unrelated stuff is added)
    #
    file { '/etc/rc.d/rc.local':
        ensure => 'file',
        mode => '0755',
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
        mode => '0700',
        recurse => 'true',
        source => 'file:///boot/efi',
    }

    #
    # Directory that hosts various infrastructural content
    #
    file { $infra_path:
        ensure => 'directory',
    }

    #
    # This directory contains boot media
    #
    file { "${infra_path}/isos":
        ensure => 'directory',
        group => 'qemu',
        owner => 'qemu',
        recurse => 'true',
        selinux_ignore_defaults => 'true',
    }

}

#
# Virtualization-related settings
#
class libvirt::machines {

    #
    # Jenkins, the ci master host (RHEL6)
    #
    $jenkins_arch       = 'x86_64'
    $jenkins_distro     = 'rhel'
    $jenkins_hostname   = 'jenkins'
    $jenkins_ip         = '192.168.122.101'
    $jenkins_releasever = '6Server'
    $jenkins_swap       = true

    $fc_15_i386_arch       = 'i386'
    $fc_15_i386_distro     = 'fc'
    $fc_15_i386_hostname   = 'fc-15-i386'
    $fc_15_i386_ip         = '192.168.122.111'
    $fc_15_i386_releasever = '15'
    $fc_15_i386_swap       = false

    logical_volume { "vm_${jenkins_hostname}_main":
        ensure => 'present',
        volume_group => $infra_storage_fast_vg,
        size => '16G',
    }

    logical_volume { "vm_${jenkins_hostname}_swap":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '8G',
    }

    host { $jenkins_hostname :
        ensure => 'present',
        ip => $jenkins_ip,
        host_aliases => "${jenkins_hostname}.${domain}",
     }

    libvirt::make_kickstart { $jenkins_hostname:
        ks_path => $kickstarts_path,
        ks_info => {
            name       => $jenkins_hostname,
            firewall   => '--http',
            kernel     => '',
            net_ip     => $jenkins_ip,
            net_msk    => $libvirt_netmask,
            net_ns     => $libvirt_server,
            net_gw     => $libvirt_server,
            swap       => $jenkins_swap,
            distro     => $jenkins_distro,
            releasever => $jenkins_releasever,
            basearch   => $jenkins_arch,
            packages   => '

                @server-policy

                # Packages not needed on virtual hosts
                -ntp
                -smartmontools

                # We only use RHN Classic!
                -subscription-manager

            ',
            post => '',
        },
    }

    logical_volume { "vm_${fc_15_i386_hostname}_main":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '16G',
    }

    host { $fc_15_i386_hostname :
        ensure => 'present',
        ip => $fc_15_i386_ip,
        host_aliases => "${fc_15_i386_hostname}.${domain}",
     }

    libvirt::make_kickstart { $fc_15_i386_hostname:
        ks_path => $kickstarts_path,
        ks_info => {
            name       => $fc_15_i386_hostname,
            firewall   => '',
            kernel     => 'biosdevname=0',
            net_ip     => $fc_15_i386_ip,
            net_msk    => $libvirt_netmask,
            net_ns     => $libvirt_server,
            net_gw     => $libvirt_server,
            swap       => $fc_15_i386_swap,
            distro     => $fc_15_i386_distro,
            releasever => $fc_15_i386_releasever,
            basearch   => $fc_15_i386_arch,
            packages   => '
                @buildsys-build
                -ntp
                -smartmontools
            ',
            post => '
                rm -f /etc/udev/rules.d/70-persistent-net.rules
            ',
        },
    }

}

class libvirt::networks {

    #
    # libvirt default network definition
    #
    $libvirt_network = "${infra_config}/libvirt/network-default.xml"

    file { "${infra_config}/libvirt":
        ensure => 'directory',
        require => Class['services::everybody'],
    }

    file { $libvirt_network:
        ensure => 'file',
        source => 'puppet:///nodes/libvirt/network-default.xml',
        require => File["${infra_config}/libvirt"],
    }

    exec { 'libvirt-define-network':
        command => "virsh net-define ${libvirt_network} && virsh net-destroy default && virsh net-start default",
        cwd => "${infra_config}/libvirt",
        logoutput => 'true',
        refreshonly => 'true',
        require => File[$libvirt_network],
        subscribe => File[$libvirt_network],
        user => 'root',
    }

}

class libvirt::kickstarts {

    #
    # This directory contains kickstarts for RH-based distributions
    #
    file { $kickstarts_path:
        ensure => 'directory',
        recurse => 'true',
        seltype => 'httpd_sys_content_t',
    }

    #
    # Serve kickstarts repository
    #
    file { '/etc/httpd/conf.d/kickstarts.conf':
        ensure => 'file',
        require => [
            File[$kickstarts_path],
            Class['apache::install'],
        ],
        notify => Class['apache::service'],
        content => "
            # ZYV
            #
            # Internal kickstarts repository
            #
            Alias /kickstarts ${kickstarts_path}
            ",
    }

}

#
# Creates personalized kickstart files from a template
#
define libvirt::make_kickstart($ks_path, $ks_info) {

    file { "${ks_path}/${ks_info['name']}-ks.cfg":
        content => template('default-ks.cfg.erb'),
        ensure => 'file',
        require => File[$ks_path],
        seltype => 'httpd_sys_content_t',
    }

}

