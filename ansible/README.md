# Ansible Deployment

Ansible roles and playbooks for setting up and deploying Raspberry Pi media server infrastructure.

## Architecture

- **pi0** — Storage server + media/home automation services (Docker Compose)
- **pi1** — Monitoring stack (Prometheus, Grafana, Alertmanager)

## Prerequisites

- Ansible installed on your local machine
- SSH key-based access to Pi hosts as `pi` user
- Install Ansible collections:

```shell
cd ansible
ansible-galaxy install -r requirements.yaml
```

## Quick Start

All commands run from the `ansible/` directory:

```shell
cd ansible

# Full deployment on pi0
ansible-playbook playbooks/deploy.yaml -l pi0

# OS setup only
ansible-playbook playbooks/deploy.yaml -l pi0 --tags common

# Docker deploy only
ansible-playbook playbooks/deploy.yaml -l pi0 --tags docker

# Redeploy containers only
ansible-playbook playbooks/deploy.yaml -l pi0 --tags deploy

# NFS only
ansible-playbook playbooks/deploy.yaml -l pi0 --tags nfs
```

## Structure

```
ansible/
├── ansible.cfg
├── requirements.yaml
├── inventory/
│   ├── hosts.yaml
│   ├── group_vars/
│   │   ├── all.yaml
│   │   └── storage_server.yaml
│   └── host_vars/
│       ├── pi0.yaml
│       └── pi1.yaml
├── roles/
│   ├── common/          # OS packages, dotfiles, locale, data dir
│   ├── docker/          # Docker install, repo clone, compose deploy
│   └── nfs/             # SSD mount, NFS server/client (auto-detects role)
└── playbooks/
    └── deploy.yaml      # Single playbook, use --tags to scope
```

## Roles

| Role | Description | Tags |
|------|-------------|------|
| `common` | System packages, dotfiles, locale, data directory | `common`, `packages`, `dotfiles`, `system`, `storage` |
| `docker` | Docker installation, repo clone, container deployment | `docker`, `install`, `repo`, `deploy` |
| `nfs` | SSD mount, NFS server exports or client mount (auto-detects) | `nfs`, `storage` |

## Variables

Global variables are in `inventory/group_vars/all.yaml`. Host-specific overrides go in `inventory/host_vars/<host>.yaml`.

Secrets (Tailscale keys, API keys, DuckDNS tokens) should be in `docker/.env.private` which is gitignored.
