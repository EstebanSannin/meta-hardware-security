# secure boot fixups to the Tezi recovery metadata
require ${@ 'tezi-run-metadata-secboot.inc' if 'hws-signed' in d.getVar('OVERRIDES').split(':') else ''}
