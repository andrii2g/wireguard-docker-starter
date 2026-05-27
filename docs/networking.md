# Networking

## VPS with public IP

Use:

```text
INIT_HOST=<server-public-ip-or-dns>
WG_PORT=51820
INIT_PORT=51820
```

Open the firewall:

```bash
sudo ufw allow 51820/udp
```

Optional UI access:

```bash
sudo ufw allow from <your-admin-ip> to any port 51821 proto tcp
```

Do not open the web UI to the whole internet unless you accept the risk.

## Home server behind router

Use:

```text
INIT_HOST=<public-ip-or-dynamic-dns-name>
WG_PORT=51820
INIT_PORT=51820
```

Important:

- `INIT_HOST` must be the router public IP or a public DNS name that points to it.
- Do not use `localhost`, the machine hostname, or a private LAN IP such as `192.168.1.50`.
- `INIT_PORT` must match `WG_PORT`.

Router forwarding:

```text
External UDP 51820 -> Ubuntu Docker host UDP 51820
```

Keep the Ubuntu host on a stable LAN IP.

Recommended:

1. Create a DHCP reservation on the router for the laptop or home PC running Docker.
2. Verify the LAN IP on the Ubuntu host before creating the router rule.
3. Forward only the WireGuard UDP port for normal VPN use.
4. Do not forward the web UI port unless you intentionally want remote admin access.

Example:

```text
Router public IP: 198.51.100.24
Ubuntu host LAN IP: 192.168.1.50
Forward: UDP 51820 -> 192.168.1.50:51820
Set:
INIT_HOST=198.51.100.24
WG_PORT=51820
INIT_PORT=51820
```

If the public IP changes often, use a dynamic DNS name instead of the raw IP.

## Split tunnel

This starter can seed initial VPN network defaults:

```text
INIT_IPV4_CIDR=10.8.0.0/24
INIT_IPV6_CIDR=fdcc:ad94:bacf:61a3::/64
```

After bootstrap, configure split-tunnel routing policy in the `wg-easy` UI. Any LAN subnet examples must match your actual LAN subnet.

## Full tunnel

For full-tunnel routing, configure the client routing policy in the `wg-easy` UI after bootstrap. Full tunnel sends all client IPv4 and IPv6 traffic through the VPN route.
