# WireGuard Docker Starter

## What this is

This repository provides a small `wg-easy` v15 starter for running WireGuard on Ubuntu with Docker Compose. Initial deployment is driven by `.env`, and ongoing administration happens in the `wg-easy` web UI.

## Prerequisites

- Ubuntu 22.04 LTS or newer
- Docker Engine
- Docker Compose plugin (`docker compose`)
- A public IP address or DNS name that VPN clients can reach

If Docker is not installed yet, follow the official Docker Engine installation docs for Ubuntu:
[Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

## Quick start

```bash
git clone https://github.com/andrii2g/wireguard-docker-starter.git
cd wireguard-docker-starter

cp .env.example .env
nano .env

./scripts/up.sh
```

Open `http://SERVER_IP:51821`

## Configuration

Required `.env` values:

- `WG_PORT`
- `WG_UI_PORT`
- `TZ`
- `INSECURE=true`
- `INIT_ENABLED=true`
- `INIT_USERNAME`
- `INIT_PASSWORD`
- `INIT_HOST`
- `INIT_PORT`
- `WG_DATA_DIR`

Rules:

- `INIT_PORT` must equal `WG_PORT`.
- `INIT_*` values are used only during the first container start.
- After bootstrap, server and client management happens in the `wg-easy` UI.
- For already-initialized deployments, `INIT_USERNAME` and `INIT_PASSWORD` may be removed from `.env`.

## Start

```bash
./scripts/up.sh
```

To restart after `.env` changes:

```bash
./scripts/restart.sh
```

## Open the UI

By default this starter exposes the UI over plain HTTP:

```text
http://SERVER_IP:51821
```

This is convenient but less secure than using a reverse proxy or localhost-only binding. Restrict access with a firewall, SSH tunnel, or an override file.

To bind the UI to localhost only:

```bash
docker compose -f docker-compose.yml -f docker-compose.local-ui.yml up -d
```

## Create your first VPN client

1. Open the `wg-easy` web UI.
2. Sign in with the bootstrap admin credentials from `.env`.
3. Create a new client.
4. Download the generated config or scan the QR code.

## Full tunnel vs split tunnel

This starter seeds only the initial VPN network settings via `INIT_*`. Routing choices for clients should be configured in the `wg-easy` UI after bootstrap.

- Full tunnel: route all client traffic through the VPN.
- Split tunnel: route only selected traffic or networks through the VPN.

## Firewall and router setup

For a VPS:

```bash
sudo ufw allow 51820/udp
sudo ufw allow from <your-admin-ip> to any port 51821 proto tcp
```

For a home server behind a router:

- Set `INIT_HOST` to your router public IP or a dynamic DNS name.
- Do not set `INIT_HOST` to `localhost`, the laptop hostname, or a private LAN IP like `192.168.x.x`.
- Forward external UDP `WG_PORT` to the Ubuntu host UDP `WG_PORT`.
- Ensure the host has a stable LAN IP.
- Prefer a DHCP reservation on the router so the laptop or PC always gets the same LAN address.
- Do not forward `WG_UI_PORT` from the router unless you intentionally want remote admin access to the web UI.

Example:

```text
INIT_HOST=myhomevpn.ddns.net
WG_PORT=51820
INIT_PORT=51820
```

Router forwarding example:

```text
UDP 51820 on the router -> 192.168.1.50:51820 on the Ubuntu host
```

## Useful commands

```bash
./scripts/up.sh
./scripts/down.sh
./scripts/restart.sh
./scripts/logs.sh
./scripts/status.sh
docker compose pull
docker compose up -d
```

## Backup

```bash
tar -czf wg-easy-backup-$(date +%Y%m%d).tar.gz ./data/wireguard
```

Restore:

```bash
mkdir -p ./data
tar -xzf wg-easy-backup-YYYYMMDD.tar.gz
docker compose up -d
```

## Security notes

- Do not commit `.env`.
- Remove `INIT_USERNAME` and `INIT_PASSWORD` from `.env` only after successful bootstrap and only for already-initialized deployments.
- Keep `WG_UI_PORT` restricted by firewall or an SSH tunnel.
- Prefer [docker-compose.local-ui.yml](docker-compose.local-ui.yml) if you do not need remote browser access to the UI.
- Treat `WG_DATA_DIR` as sensitive because it contains WireGuard keys and client configs.
- Avoid exposing the web UI publicly without additional protection.

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md).

## License

MIT. See [LICENSE](LICENSE).
