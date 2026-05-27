# Troubleshooting

## Container does not start

```bash
docker compose ps
docker compose logs --tail=200 wg-easy
```

## Client cannot connect

Checklist:

1. `INIT_HOST` resolves to the server.
2. UDP `WG_PORT` is open on the server firewall.
3. The router forwards UDP `WG_PORT` to the Docker host.
4. Compose maps `"${WG_PORT}:51820/udp"`.
5. Client config endpoint uses the expected hostname and port.
6. Mobile or corporate networks are not blocking UDP.

## Client connects but has no internet

Checklist:

1. Confirm the intended routing mode in the `wg-easy` UI for that client.
2. `net.ipv4.ip_forward=1` is configured through Compose sysctls.
3. The host firewall allows forwarding.
4. The server has outbound internet access.
5. Any configured DNS servers are reachable by VPN clients.

## Web UI cannot be opened

Checklist:

1. The container is running.
2. `WG_UI_PORT` is mapped.
3. The host firewall allows TCP `WG_UI_PORT`.
4. The browser uses `http://`, not `https://`, unless a reverse proxy was configured separately.

## Changed `.env` but nothing changed

Recreate the container:

```bash
./scripts/restart.sh
```

or:

```bash
docker compose up -d --force-recreate
```

Remember that `INIT_*` values only affect the first bootstrap. Changing them later does not reconfigure an existing deployment.
