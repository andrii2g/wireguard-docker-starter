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

Router forwarding:

```text
External UDP 51820 -> Ubuntu Docker host UDP 51820
```

Keep the Ubuntu host on a stable LAN IP.

## Split tunnel

This starter can seed initial VPN network defaults:

```text
INIT_IPV4_CIDR=10.8.0.0/24
INIT_IPV6_CIDR=fdcc:ad94:bacf:61a3::/64
```

After bootstrap, configure split-tunnel routing policy in the `wg-easy` UI. Any LAN subnet examples must match your actual LAN subnet.

## Full tunnel

For full-tunnel routing, configure the client routing policy in the `wg-easy` UI after bootstrap. Full tunnel sends all client IPv4 and IPv6 traffic through the VPN route.
