# Raspberry-Pi Media Server

This repository provides two different setups for running a media server on Raspberry Pi: one using Kubernetes and another using Docker. You can choose the setup that suits your needs and environment.

## Docker Setup

The Docker setup is designed to run on a single Raspberry Pi. It provides a media server setup using Docker containers. It includes the following applications:

- Jackett: API support for your favorite torrent trackers.
- Sonarr: Smart PVR for newsgroup and BitTorrent users.
- Radarr: A fork of Sonarr to work with movies.
- Bazarr: Companion application to Sonarr and Radarr that manages and downloads subtitles.
- Transmission: Fast, easy, and free BitTorrent client.
- Jellyfin: The open-source media server for streaming and organizing media.
- Traefik: A modern HTTP reverse proxy and load balancer that makes deploying microservices easy.
- AdGuard Home: Network-wide ad and tracker blocking DNS server.
- Tailscale: Securely access your Raspberry Pi and other devices from anywhere.

To set up the media server using Docker, follow the instructions in the [docker](docker/) directory.

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


