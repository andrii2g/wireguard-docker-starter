# Security

1. Do not commit `.env`.
2. Remove `INIT_USERNAME` and `INIT_PASSWORD` from `.env` only after successful bootstrap and only for already-initialized deployments.
3. Keep `WG_UI_PORT` restricted by firewall or SSH tunnel.
4. Keep the Docker host updated.
5. Back up `WG_DATA_DIR`.
6. Treat `WG_DATA_DIR` as sensitive because it contains VPN keys and client configs.
7. Remove unused clients from the `wg-easy` UI.
8. Rotate client configs if a device is lost.
9. Avoid exposing the web UI publicly without additional protection.
10. Use a strong admin password.

## Optional SSH tunnel

```bash
ssh -L 51821:localhost:51821 user@your-server
```

Then open:

```text
http://localhost:51821
```

This works only if the Compose port is bound to localhost. A safer override file looks like this:

```yaml
services:
  wg-easy:
    ports:
      - "${WG_PORT}:51820/udp"
      - "127.0.0.1:${WG_UI_PORT}:51821/tcp"
```

The repository includes this override as [docker-compose.local-ui.yml](../docker-compose.local-ui.yml).
