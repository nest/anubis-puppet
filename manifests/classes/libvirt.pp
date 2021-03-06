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
            m => {
                'arch'       => 'x86_64',
                'distro'     => 'rhel',
                'os'         => 'redhat',
                'hostname'   => 'jenkins',
                'ip'         => '192.168.122.101',
                'mac'        => '52:54:00:c1:5c:c3',
                'releasever' => '6Server',
                'swap'       => true,
                'selinux'    => 'enforcing',
                'biosboot'   => 'false',
                'storage'    => {
                    'vm_jenkins_main' => { ensure => 'present', size => '48G', volume_group => $infra_storage_fast_vg, },
                    'vm_jenkins_swap' => { ensure => 'present', size => '8G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => '',
                'ks_firewall'=> '--enabled --ssh --http',
                'ks_post'    => '',
                'ks_packages'=> '
                    @server-policy
                    -ntp
                    -subscription-manager
                ',
            },
        },

        #
        # Build slaves
        #

        'fc_17_i386_1' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-17-i386-1',
                'ip'         => '192.168.122.141',
                'mac'        => '52:54:00:a2:82:8d',
                'releasever' => '17',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-17-i386-1_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_1' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-1',
                'ip'         => '192.168.122.151',
                'mac'        => '52:54:00:c7:51:7b',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-1_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_2' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-2',
                'ip'         => '192.168.122.152',
                'mac'        => '52:54:00:00:36:2a',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-2_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_3' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-3',
                'ip'         => '192.168.122.153',
                'mac'        => '52:54:00:a0:13:c6',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-3_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_4' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-4',
                'ip'         => '192.168.122.154',
                'mac'        => '52:54:00:bb:69:cd',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-4_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_5' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-5',
                'ip'         => '192.168.122.155',
                'mac'        => '52:54:00:e8:f3:73',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-5_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_6' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-6',
                'ip'         => '192.168.122.156',
                'mac'        => '52:54:00:d4:2b:77',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-6_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_7' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-7',
                'ip'         => '192.168.122.157',
                'mac'        => '52:54:00:e4:c0:8c',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-7_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_8' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-8',
                'ip'         => '192.168.122.158',
                'mac'        => '52:54:00:e7:12:e2',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-8_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'fc_18_i386_9' => {
            m => {
                'arch'       => 'i386',
                'distro'     => 'fc',
                'os'         => 'redhat',
                'hostname'   => 'fc-18-i386-9',
                'ip'         => '192.168.122.159',
                'mac'        => '52:54:00:ec:11:21',
                'releasever' => '18',
                'swap'       => false,
                'selinux'    => 'disabled',
                'biosboot'   => 'true',
                'storage'    => {
                    'vm_fc-18-i386-9_main' => { ensure => 'present', size => '24G', volume_group => $infra_storage_slow_vg, },
                },
                'ks_kernel'  => 'biosdevname=0',
                'ks_firewall'=> '--enabled --ssh',
                'ks_packages'=> '
                    @buildsys-build
                    -ntp
                ',
                'ks_post'    => '
                    rm -f /etc/udev/rules.d/70-persistent-net.rules
                ',
            },
        },

        'windows_7_pro_x86_64' => {
            m => {
                'os'         => 'windows',
                'hostname'   => 'windows-7-pro-x86_64',
                'ip'         => '192.168.122.131',
                'mac'        => '52:54:00:5b:48:1a',
                'storage'    => {
                    'vm_windows-7-pro-x86_64_main' => { ensure => 'present', size => '96G', volume_group => $infra_storage_slow_vg, },
                },
            },
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

    create_resources(libvirt::guest, $libvirt::params::guests)

}

define libvirt::guest($m) {

    host { $m['hostname'] :
        ensure => 'present',
        ip => $m['ip'],
        host_aliases => "${m['hostname']}.${domain}",
     }

    create_resources(logical_volume, $m['storage'])

    if $m['os'] == "redhat" {
        libvirt::make_kickstart { $m['hostname']:
            preseed => $m,
        }
    }

}

#
# Creates personalized kickstart files from a template
#
define libvirt::make_kickstart($preseed) {

    file { "${kickstarts_path}/${preseed['hostname']}-ks.cfg":
        content => template('default-ks.cfg.erb'),
        ensure => 'file',
        require => File[$kickstarts_path],
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

#
# Requires subscription to RHEL Server Supplementary!
#
class libvirt::paravirt {
    package { 'virtio-win':
        ensure => 'present',
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
