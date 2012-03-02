# ZYV

#
# Miscelaneous libvirt settings
#
class libvirt::params {

    $guests = {

        #
        # Jenkins, the ci master host (RHEL6)
        #
        'jenkins' => {
            'arch'       => 'x86_64',
            'distro'     => 'rhel',
            'hostname'   => 'jenkins',
            'ip'         => '192.168.122.101',
            'mac'        => '52:54:00:c1:5c:c3',
            'releasever' => '6Server',
            'swap'       => true,
        },

        #
        # Build slaves
        #
        'fc_15_i386' => {
            'arch'       => 'i386',
            'distro'     => 'fc',
            'hostname'   => 'fc-15-i386',
            'ip'         => '192.168.122.111',
            'mac'        => '52:54:00:3c:77:9a',
            'releasever' => '15',
            'swap'       => false,
        },

        'fc_16_i386_1' => {
            'arch'       => 'i386',
            'distro'     => 'fc',
            'hostname'   => 'fc-16-i386-1',
            'ip'         => '192.168.122.121',
            'mac'        => '52:54:00:69:f2:a1',
            'releasever' => '16',
            'swap'       => false,
        },

        'fc_16_i386_2' => {
            'arch'       => 'i386',
            'distro'     => 'fc',
            'hostname'   => 'fc-16-i386-2',
            'ip'         => '192.168.122.122',
            'mac'        => '52:54:00:b3:ae:28',
            'releasever' => '16',
            'swap'       => false,
        },

        'fc_16_i386_3' => {
            'arch'       => 'i386',
            'distro'     => 'fc',
            'hostname'   => 'fc-16-i386-3',
            'ip'         => '192.168.122.123',
            'mac'        => '52:54:00:28:37:23',
            'releasever' => '16',
            'swap'       => false,
        },

        'windows_7_pro_x86_64' => {
            'hostname'   => 'windows-7-pro-x86_64',
            'ip'         => '192.168.122.131',
            'mac'        => '52:54:00:5b:48:1a',
        },

    }

}

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

    logical_volume { "vm_${libvirt::params::guests['jenkins']['hostname']}_main":
        ensure => 'present',
        volume_group => $infra_storage_fast_vg,
        size => '16G',
    }

    logical_volume { "vm_${libvirt::params::guests['jenkins']['hostname']}_swap":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '8G',
    }

    host { $libvirt::params::guests['jenkins']['hostname'] :
        ensure => 'present',
        ip => $libvirt::params::guests['jenkins']['ip'],
        host_aliases => "${libvirt::params::guests['jenkins']['hostname']}.${domain}",
     }

    libvirt::make_kickstart { $libvirt::params::guests['jenkins']['hostname']:
        ks_path => $kickstarts_path,
        ks_info => {
            selinux    => 'enforcing',
            firewall   => '--http',
            kernel     => '',
            packages   => '
                @server-policy
                -ntp
                -subscription-manager
            ',
            post => '',
        },
        ks_guest => $libvirt::params::guests['jenkins'],
    }

    logical_volume { "vm_${libvirt::params::guests['fc_15_i386']['hostname']}_main":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '16G',
    }

    logical_volume { "vm_${libvirt::params::guests['fc_16_i386_1']['hostname']}_main":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '24G',
    }

    logical_volume { "vm_${libvirt::params::guests['fc_16_i386_2']['hostname']}_main":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '24G',
    }

    logical_volume { "vm_${libvirt::params::guests['fc_16_i386_3']['hostname']}_main":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '24G',
    }

    logical_volume { "vm_${libvirt::params::guests['windows_7_pro_x86_64']['hostname']}_main":
        ensure => 'present',
        volume_group => $infra_storage_slow_vg,
        size => '96G',
    }

    host { $libvirt::params::guests['fc_15_i386']['hostname'] :
        ensure => 'present',
        ip => $libvirt::params::guests['fc_15_i386']['ip'],
        host_aliases => "${libvirt::params::guests['fc_15_i386']['hostname']}.${domain}",
     }

    host { $libvirt::params::guests['fc_16_i386_1']['hostname'] :
        ensure => 'present',
        ip => $libvirt::params::guests['fc_16_i386_1']['ip'],
        host_aliases => "${libvirt::params::guests['fc_16_i386_1']['hostname']}.${domain}",
     }

    host { $libvirt::params::guests['fc_16_i386_2']['hostname'] :
        ensure => 'present',
        ip => $libvirt::params::guests['fc_16_i386_2']['ip'],
        host_aliases => "${libvirt::params::guests['fc_16_i386_2']['hostname']}.${domain}",
     }

    host { $libvirt::params::guests['fc_16_i386_3']['hostname'] :
        ensure => 'present',
        ip => $libvirt::params::guests['fc_16_i386_3']['ip'],
        host_aliases => "${libvirt::params::guests['fc_16_i386_3']['hostname']}.${domain}",
     }

    host { $libvirt::params::guests['windows_7_pro_x86_64']['hostname'] :
        ensure => 'present',
        ip => $libvirt::params::guests['windows_7_pro_x86_64']['ip'],
        host_aliases => "${libvirt::params::guests['windows_7_pro_x86_64']['hostname']}.${domain}",
     }

    libvirt::make_kickstart { $libvirt::params::guests['fc_15_i386']['hostname']:
        ks_path => $kickstarts_path,
        ks_info => {
            selinux    => 'disabled',
            firewall   => '',
            kernel     => 'biosdevname=0',
            packages   => '
                @buildsys-build
                -ntp
            ',
            post => '
                rm -f /etc/udev/rules.d/70-persistent-net.rules
            ',
        },
        ks_guest => $libvirt::params::guests['fc_15_i386'],
    }

    libvirt::make_kickstart { $libvirt::params::guests['fc_16_i386_1']['hostname']:
        ks_path => $kickstarts_path,
        ks_info => {
            selinux    => 'disabled',
            biosboot   => 'true',
            firewall   => '',
            kernel     => 'biosdevname=0',
            packages   => '
                @buildsys-build
                -ntp
            ',
            post => '
                rm -f /etc/udev/rules.d/70-persistent-net.rules
            ',
        },
        ks_guest => $libvirt::params::guests['fc_16_i386_1'],
    }

    libvirt::make_kickstart { $libvirt::params::guests['fc_16_i386_2']['hostname']:
        ks_path => $kickstarts_path,
        ks_info => {
            selinux    => 'disabled',
            biosboot   => 'true',
            firewall   => '',
            kernel     => 'biosdevname=0',
            packages   => '
                @buildsys-build
                -ntp
            ',
            post => '
                rm -f /etc/udev/rules.d/70-persistent-net.rules
            ',
        },
        ks_guest => $libvirt::params::guests['fc_16_i386_2'],
    }

    libvirt::make_kickstart { $libvirt::params::guests['fc_16_i386_3']['hostname']:
        ks_path => $kickstarts_path,
        ks_info => {
            selinux    => 'disabled',
            biosboot   => 'true',
            firewall   => '',
            kernel     => 'biosdevname=0',
            packages   => '
                @buildsys-build
                -ntp
            ',
            post => '
                rm -f /etc/udev/rules.d/70-persistent-net.rules
            ',
        },
        ks_guest => $libvirt::params::guests['fc_16_i386_3'],
    }

}

#
# Creates personalized kickstart files from a template
#
define libvirt::make_kickstart($ks_path, $ks_info, $ks_guest) {

    file { "${ks_path}/${ks_guest['hostname']}-ks.cfg":
        content => template('default-ks.cfg.erb'),
        ensure => 'file',
        require => File[$ks_path],
        seltype => 'httpd_sys_content_t',
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

class libvirt::pypi {

    #
    # This directory contains PyPi packages
    #
    file { $pypi_path:
        ensure => 'directory',
        recurse => 'true',
        seltype => 'httpd_sys_content_t',
    }

    #
    # Serve PyPi repository
    #
    file { '/etc/httpd/conf.d/pypi.conf':
        ensure => 'file',
        require => [
            File[$pypi_path],
            Class['apache::install'],
        ],
        notify => Class['apache::service'],
        content => "
            # ZYV
            #
            # Internal pypi repository
            #
            Alias /pypi ${pypi_path}

            <Directory ${pypi_path}>
                Options +Indexes
            </Directory>
            ",
    }

}

class libvirt::networks {

    $klnts = $libvirt::params::guests

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
        content => template('network-default.xml.erb'),
        require => File["${infra_config}/libvirt"],
    }

    package { 'perl-XML-XPath':
        ensure => 'present',
    }

    file { "${infra_config}/libvirt/network-restart" :
        ensure => 'file',
        mode => '0755',
        source => 'puppet:///common/network-restart',
        require => [
            File["${infra_config}/libvirt"],
            Package['perl-XML-XPath'],
        ],
    }

    #
    # Re-init the network and re-attach all interfaces
    #
    exec { 'libvirt-define-network':
        command => "${infra_config}/libvirt/network-restart",
        cwd => "${infra_config}/libvirt",
        logoutput => 'true',
        refreshonly => 'true',
        require => [
            File["${infra_config}/libvirt/network-restart"],
            File[$libvirt_network],
        ],
        subscribe => File[$libvirt_network],
        user => 'root',
    }

    file { '/etc/libvirt/hooks':
        ensure => 'directory',
    }

    # http://wiki.libvirt.org/page/Networking#Forwarding_Incoming_Connections
    #
    # (NB: This method is a hack, and has one annoying flaw - if libvirtd is
    # restarted while the guest is running, all of the standard iptables rules
    # to support virtual networks that were added by libvirtd will be
    # reloaded, thus changing the order of the above FORWARD rule relative to
    # a reject rule for the network and rendering this setup non-working
    # until the guest is stopped & restarted. A better solution would be
    # welcome!)
    #
    file { '/etc/libvirt/hooks/qemu':
        ensure => 'file',
        mode => '0755',
        source => 'puppet:///nodes/libvirt/hooks/qemu',
        require => File['/etc/libvirt/hooks'],
    }

}
