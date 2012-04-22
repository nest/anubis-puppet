# ZYV

$infra_path = '/srv/infra'
$infra_config = '/opt/config'

$infra_address  = '192.168.1.1'
$infra_subnet   = '192.168.1.0/24'

$infra_dns = [ '132.230.201.111', '132.230.200.200', ]

$infra_relayhost = '[smtp.uni-freiburg.de]:25'

$infra_time = 'time.uni-freiburg.de'

$infra_storage_slow_pv = '/dev/md1'
$infra_storage_slow_vg = 'vg_anubis_slow'

$infra_storage_fast_pv = '/dev/sda1'
$infra_storage_fast_vg = 'vg_anubis_fast'

$libvirt_server  = '192.168.122.1'
$libvirt_netmask = '255.255.255.0'
$libvirt_subnet  = '192.168.122.0/24'

$kickstarts_path = "${infra_path}/kickstarts"
$pypi_path = "${infra_path}/pypi"

#
# Virtualization server
#
node 'puppet.qa.nest-initiative.org' {

    include services::everybody

    #include puppet::client
    include puppet::server

    include yum::ban::i386
    include yum::repos::rhel

    class { 'yum::server':
        repos_path => "${infra_path}/repos",
    }

    include network::hosts::self
    include network::hosts::localhost

    class { 'network::resolver':
        nameservers => $infra_dns,
    }

    class { 'network::interfaces':
        ports => ['em1', 'tap1'],
        tunctl => 'true',
    }

    include network::ipv6::disable

    include services::disabled
    include services::git
    include services::iptables
    include services::logwatch
    include services::smartmontools

    include services::rhn_check

    class { 'services::ntpdate':
        ntp_server => $infra_time,
    }

    include users::admins
    include users::sudoers

    include libvirt::params
    include libvirt::paravirt
    include libvirt::storage
    include libvirt::networks
    include libvirt::machines
    include libvirt::kickstarts
    include libvirt::pypi

    include openssh
    include openssh::install::xauth

    class { 'apache':
        settings => {
            listen => "${infra_address}:80",
        }
    }

    class { 'postfix':
        settings => {
            mydomain => $domain,
            mydestination => $domain,
            inet_interfaces => $infra_address,
            mynetworks => "${infra_subnet} ${libvirt_subnet}",
            relayhost => $infra_relayhost,
        },
    }

}

node 'jenkins.qa.nest-initiative.org' {

    include services::everybody

    include puppet::client

    include yum::ban::i386
    include yum::repos::rhel

    class { 'network::resolver':
        nameservers => [ $libvirt_server, ],
    }

    include network::ipv6::disable

    include services::iptables

    include services::disabled
    include services::logwatch

    include services::rhn_check

    class { 'services::ntpdate':
        ntp_server => $infra_time,
    }

    include services::java

    include services::git

    include jenkins::install
    include jenkins::config
    include jenkins::service

    class { 'apache':
        settings => {
            listen => "*:80",
        }
    }

    include apache::redirect::https

    include users::admins
    include users::sudoers

    include openssh

    class { 'postfix':
        settings => {
            myorigin => $domain,
            relayhost => "${infra_address}:25",
        },
    }

}


node 'builder-fedora' {

    include services::everybody

    include puppet::client

    class { 'network::resolver':
        nameservers => [ $libvirt_server, ],
    }

    class { 'services::ntpdate':
        ntp_server => $infra_time,
    }

    include services::disabled

    include services::java
    include services::python

    include services::bzr
    include services::git
    include services::mercurial

    include jenkins::params
    include jenkins::slave::user
    include jenkins::slave::tmpfs

    include jenkins::builddeps::common
    include jenkins::builddeps::nest
    include jenkins::builddeps::mc

    include users::admins
    include users::sudoers

    include openssh

    include yum::autoupdate

    include yum::repos::fc

}

node 'builder-fedora-15' inherits 'builder-fedora' {
    include jenkins::builddeps::sumatra
    include jenkins::builddeps::pynn
}

node 'builder-fedora-16' inherits 'builder-fedora' {
    include jenkins::builddeps::sumatra
}

node 'fc-15-i386' inherits 'builder-fedora-15' {
}

node /^fc-16-i386-\d+$/ inherits 'builder-fedora-16' {
}
