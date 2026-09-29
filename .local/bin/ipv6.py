#!/usr/bin/env python3
#
# Finds the IPv6 address that macOS will use as the source for outgoing connections,
# which is the address a remote server's allow list needs to contain.
#
# macOS assigns several IPv6 addresses to each active interface:
#
#   - Link-local (fe80::)  — only valid on the local network segment, never routed.
#   - Loopback (::1)       — localhost.
#   - Unique-local / ULA (fc00::/7) — private addresses, like 192.168.x.x in IPv4.
#     Often seen on utun interfaces from VPN tunnels.
#   - Global (2000::/3)    — publicly routable, visible to remote machines.
#
# Among global addresses, macOS typically creates:
#
#   1. A stable address assigned via DHCPv6 or stable SLAAC. This address persists
#      across connections. It is recognizable by having a short interface identifier
#      (few hex digits after the /64 prefix), e.g. 2607:fea8:7c0:5000::540a.
#      This is the address others use to reach you (inbound).
#
#   2. Temporary privacy addresses (RFC 8981). macOS generates these with randomized
#      interface identifiers and PREFERS them for outgoing connections to resist
#      tracking. They rotate periodically.
#
# For a remote allow list, what matters is the SOURCE address of your outgoing
# connections — that's what the remote server sees. macOS uses a temporary privacy
# address for this, NOT the stable one. So the stable address won't work in an
# allow list even though it seems like the "right" choice.
#
# This script asks the OS kernel which source address it would select for an
# outgoing connection (via UDP socket connect to a public address, no data sent).
# This is the address to put in the remote allow list.
#
# Caveat: since macOS rotates temporary addresses, this address will eventually
# change. For a more durable allow list, consider allowing the entire /64 prefix
# (e.g. 2607:fea8:7c0:5000::/64). The /64 prefix itself is controlled by your ISP
# and may also change on router reboot or lease expiry.

import socket
import sys


def get_outgoing_ipv6_address():
    # Connect a UDP socket to a well-known public IPv6 address (Google DNS).
    # This triggers the kernel's source address selection without sending any data.
    # The OS picks the address it would actually use for outgoing traffic.
    sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
    try:
        sock.connect(("2001:4860:4860::8888", 80))
        addr = sock.getsockname()[0]
        return addr
    except OSError as e:
        print(f"No IPv6 connectivity: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        sock.close()


def main():
    addr = get_outgoing_ipv6_address()
    print(addr)


if __name__ == "__main__":
    main()
