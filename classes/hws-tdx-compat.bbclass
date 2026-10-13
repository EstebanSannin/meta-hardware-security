# Transitional compatibility with meta-toradex-security names.
#
# This class lets configurations written for meta-toradex-security keep working
# while they migrate to the hws names (see MIGRATION.md). It is optional: the
# legacy wrapper classes (tdx-signed, tdx-encrypted, ...) inherit it, and it can
# also be enabled globally with:
#
#   INHERIT += "hws-tdx-compat"
#
# It must be inherited before any hws-* class (list it first in INHERIT), so the
# legacy values are already mapped when the hws classes evaluate their
# parse-time conditionals.
#
# What it does:
#
# - Variables: for each "LEGACY:NEW" pair in HWS_TDX_COMPAT_VARS, everything set
#   on the legacy name (value, :append/:prepend/:remove, override-qualified
#   assignments such as TDX_X:tdx-signed) is moved to the new name, and a
#   deprecation warning is shown once per legacy variable actually used. If the
#   new variable is also set, the new one wins and the legacy one is ignored.
#   Afterwards the legacy name is kept as an alias of the new one
#   (LEGACY = "${NEW}"), so code that reads the legacy name keeps working.
#   Only the variables listed in the table are touched; other TDX_* variables
#   (e.g. defined by other layers) are left alone.
#
# - Overrides: for each "CLASS:LEGACY" pair in HWS_TDX_COMPAT_OVERRIDES, the
#   legacy override is added to DISTROOVERRIDES whenever CLASS (the hws class
#   that owns the new override) is inherited.
#
# This class is transitional and will be removed in a future release.

# Variable rename table: whitespace-separated "LEGACY:NEW" pairs. Each rename
# group appends its own block below.
HWS_TDX_COMPAT_VARS ?= ""

# Override rename table: whitespace-separated "CLASS:LEGACY_OVERRIDE" pairs;
# LEGACY_OVERRIDE is added to DISTROOVERRIDES when CLASS is inherited.
HWS_TDX_COMPAT_OVERRIDES ?= ""

# Signing classes and overrides
HWS_TDX_COMPAT_OVERRIDES += "\
    hws-signed:tdx-signed \
    hws-signed-dmverity:tdx-signed-dmverity \
"

def hws_tdx_compat_pairs(d):
    pairs = []
    for item in (d.getVar('HWS_TDX_COMPAT_VARS') or '').split():
        old, sep, new = item.partition(':')
        if not sep or not old or not new:
            bb.fatal("hws-tdx-compat: malformed entry '%s' in HWS_TDX_COMPAT_VARS" % item)
        pairs.append((old, new))
    return pairs

def hws_tdx_compat_is_used(d, var):
    """Return True if anything other than the compat alias is set on 'var'."""
    base = d.getVar(var, False, parsing=True)
    if base is not None and base != d.getVarFlag(var, 'hws_tdx_compat_alias', False):
        return True
    for op in (':append', ':prepend', ':remove'):
        if d.getVarFlag(var, op, False):
            return True
    return bool(d.overridedata.get(var))

def hws_tdx_compat_move(d, old, new, prefer_legacy):
    alias = '${%s}' % new

    if hws_tdx_compat_is_used(d, old):
        if not prefer_legacy and hws_tdx_compat_is_used(d, new):
            bb.warn("hws-tdx-compat: both %s and %s are set; %s is ignored." % (old, new, old))
        else:
            bb.warn("hws-tdx-compat: variable %s is deprecated, use %s instead "
                    "(see MIGRATION.md)." % (old, new))
            # Drop the alias (if any) so it is not moved onto the new name.
            if d.getVar(old, False, parsing=True) == d.getVarFlag(old, 'hws_tdx_compat_alias', False):
                d.delVarFlag(old, '_content')
            # renameVar() resets the override index of the destination; keep
            # the override-qualified assignments already made on the new name
            # (e.g. layer defaults such as NEW:mx8-generic-bsp).
            keep = list(d.overridedata.get(new, []))
            d.renameVar(old, new)
            if keep:
                merged = d.overridedata.setdefault(new, [])
                for entry in keep:
                    if entry not in merged:
                        merged.append(entry)

    # Keep the legacy name readable as an alias of the new one.
    d.delVar(old)
    d.setVar(old, alias)
    d.setVarFlag(old, 'hws_tdx_compat_alias', alias)

def hws_tdx_compat_map(d, prefer_legacy):
    for old, new in hws_tdx_compat_pairs(d):
        hws_tdx_compat_move(d, old, new, prefer_legacy)

def hws_tdx_compat_hws_classes(d):
    return [c for c in (d.getVar('__inherit_cache', False) or [])
            if os.path.basename(c).startswith('hws-') and
            not os.path.basename(c).startswith('hws-tdx-')]

def hws_tdx_compat_parse(d):
    late = hws_tdx_compat_hws_classes(d)
    if late:
        bb.warn("hws-tdx-compat: inherited after %s; inherit it first so that "
                "legacy variables are seen by parse-time conditionals."
                % ", ".join(os.path.basename(c) for c in late))
    hws_tdx_compat_map(d, prefer_legacy=bool(late))
    return ""

def hws_tdx_compat_overrides(d):
    res = ""
    for item in (d.getVar('HWS_TDX_COMPAT_OVERRIDES') or '').split():
        cls, sep, legacy = item.partition(':')
        if not sep or not cls or not legacy:
            bb.fatal("hws-tdx-compat: malformed entry '%s' in HWS_TDX_COMPAT_OVERRIDES" % item)
        if bb.data.inherits_class(cls, d):
            res += ":" + legacy
    return res

def hws_tdx_compat_deprecated_class(d, old, new):
    bb.warn("hws-tdx-compat: class %s is deprecated, use %s instead (see MIGRATION.md)." % (old, new))
    return ""

# Map legacy variables set so far (configuration files and classes inherited
# before this one) at parse time, so parse-time conditionals in hws classes see
# them. This include never includes anything: it is used because its argument
# is expanded on the real datastore (an immediate ":=" assignment would expand
# on a copy).
include ${@hws_tdx_compat_parse(d)}

# Map legacy variables set later at recipe level (recipes and bbappends); these
# are visible to task code but not to parse-time conditionals.
python __anonymous() {
    hws_tdx_compat_map(d, prefer_legacy=True)
}

DISTROOVERRIDES .= "${@hws_tdx_compat_overrides(d)}"
