# Ubuntu Docker Install

## If Docker is already installed

Verify the host setup:

```bash
docker --version
docker compose version
docker info
```

## If Docker is not installed

Use Docker's official Ubuntu installation guide:
[Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

Convenience commands before following the official guide:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
```

This project does not install Docker automatically. Docker is a host prerequisite.
