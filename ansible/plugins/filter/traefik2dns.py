# filter_plugins/traefik2dns.py
import re
from collections.abc import Mapping, Sequence

# Match Host(`www.example.com`) even with smart quotes or extra spaces
_HOST_RE = re.compile(
    r"Host\(`\s*[\"'‘’“”]?([^\"'‘’“”\)]+)[\"'‘’“”]?\s*`\)",
    re.IGNORECASE,
)

def _walk_and_collect(node, out, seen):
    """Recursively walk dicts/lists/tuples and collect hostnames in order, deduped."""
    if isinstance(node, str):
        for host in _HOST_RE.findall(node):
            h = host.strip()
            if h and h not in seen:
                seen.add(h)
                out.append(h)
    elif isinstance(node, Mapping):
        for v in node.values():
            _walk_and_collect(v, out, seen)
    elif isinstance(node, Sequence) and not isinstance(node, (bytes, bytearray)):
        for v in node:
            _walk_and_collect(v, out, seen)
    else:
        pass

def _subdomain_only(host: str) -> str:
    """
    Return the subdomain portion by removing the registrable domain
    as the last *two* labels (e.g., 'example.com'). If no subdomain exists,
    return ''.

    Notes:
    - Strips leading '*.' (wildcards) and any ':port'.
    - If you need correct handling for multi-part TLDs like 'co.uk',
      consider adding a PSL-based approach.
    """
    h = str(host).strip().lower()
    if not h:
        return ""
    # drop scheme if someone passed it accidentally
    if "://" in h:
        h = h.split("://", 1)[1]

    # strip wildcard and trailing dot, remove port if present
    h = h.lstrip("*.").rstrip(".").split(":", 1)[0]

    parts = [p for p in h.split(".") if p]
    if len(parts) <= 2:
        return ""  # no subdomain
    return ".".join(parts[:-2])

def traefik2dns(data):
    """
    Extract unique hostnames from Host(`...`) occurrences anywhere in the input,
    then return only their subdomain parts (last two labels removed).
    - Preserves first-seen order
    - De-duplicates
    """
    hosts, seen = [], set()
    _walk_and_collect(data, hosts, seen)

    out, seen_sub = [], set()
    for h in hosts:
        sub = _subdomain_only(h)
        if sub and sub not in seen_sub:
            seen_sub.add(sub)
            out.append(sub)
    return out

class FilterModule(object):
    def filters(self):
        return {
            'traefik2dns': traefik2dns
        }
