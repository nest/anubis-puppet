# ZYV

import 'nodes/*.pp'
import 'classes/*.pp'

#
# Set the default execution path
#
Exec {
    path => [
        '/usr/local/bin',
        '/bin',
        '/usr/bin',
        '/usr/local/sbin',
        '/usr/sbin',
        '/sbin',
    ],
}

