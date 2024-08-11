# Raspberry-Pi Media Server

This repository provides two different setups for running a media server on Raspberry Pi: one using Kubernetes and another using Docker. You can choose the setup that suits your needs and environment.

## Docker Setup

The Docker setup is designed to run on a single Raspberry Pi. It provides a comprehensive media server setup using Docker containers. It includes the following applications:

- **Jackett**: API support for your favorite torrent trackers.
- **Sonarr**: Smart PVR for newsgroup and BitTorrent users.
- **Radarr**: A fork of Sonarr to work with movies.
- **Bazarr**: Companion application to Sonarr and Radarr that manages and downloads subtitles.
- **Transmission**: Fast, easy, and free BitTorrent client.
- **Jellyfin**: The open-source media server for streaming and organizing media.
- **Traefik**: A modern HTTP reverse proxy and load balancer that makes deploying microservices easy.
- **AdGuard Home**: Network-wide ad and tracker blocking DNS server.
- **Tailscale**: Securely access your Raspberry Pi and other devices from anywhere.
- **Prometheus**: Monitoring system and time series database.
- **Grafana**: Open-source analytics and monitoring solution.
- **Blackbox Exporter**: Exporter for blackbox probing of endpoints.
- **Homebridge**: HomeKit bridge for connecting home automation devices.
- **Node Exporter**: Exporter for hardware and OS metrics.
- **cAdvisor**: Container advisor for Docker metrics.
- **Ping Exporter**: Exporter for network ping metrics.

### To set up the media server using Docker, follow the instructions in the `docker` directory.

## Makefile

The `Makefile` in this repository provides commands for managing Docker Compose services. Below is a summary of the available targets and their functionalities.

### Variables

- `DOCKER_COMPOSE_DIR`: Directory where the Docker Compose files are located (default: `docker`).
- `HOSTNAME`: The hostname of the Raspberry Pi.
- `DOCKER_COMPOSE_FILE`: The Docker Compose file to use (default: `docker-compose.yaml`).
- `ENV_FILE`: Environment file (default: `.env`).

### Targets

- `docker_start`: **Start** the Docker Compose services.
- `docker_stop`: **Stop** the Docker Compose services.
- `docker_restart`: **Restart** Docker Compose services or a specific service. If no service is provided, all services are restarted.
- `docker_pull`: **Pull** the latest images.
- `docker_cleanup`: **Remove** stopped containers and unused images.
- `help`: Display a help message with available targets.

### Example Commands

To start the Docker Compose services, run the command:

```bash
make docker_start
```

To stop the Docker Compose services, run:
```bash
make docker_stop
```

To restart a specific service, use:
```bash
make docker_restart service=<service_name>
```

To pull the latest images, execute:
```bash
make docker_pull
```

To clean up stopped containers and unused images, run:
```bash
make docker_cleanup

```
For more details and to see all available targets, use:
```bash
make help
```

## Kubernetes Setup

The Kubernetes setup allows you to run the media server on top of a Kubernetes cluster, either on a remote cluster or on a Raspberry Pi with k3s. It includes the following pods:

- Jackett
- Sonarr
- Radarr
- Transmission
- Jellyfish

To deploy the media server on Kubernetes, follow the instructions in the [kubernetes](kubernetes/) directory.

## Ansible Setup

If you prefer using Ansible for automating the setup and deployment of your Raspberry Pi media server, this repository also includes Ansible playbooks and tasks. The Ansible setup allows you to configure and deploy the media server easily.

To use Ansible for setting up and deploying the media server, follow the instructions in the [ansible](docs/ansible.md) directory.

## Contributing

Contributions to this project are welcome! If you have any improvements, bug fixes, or new features to add, please open an issue or submit a pull request.


