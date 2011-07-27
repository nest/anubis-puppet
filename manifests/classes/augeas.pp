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
