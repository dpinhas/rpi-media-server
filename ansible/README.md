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
│   │   ├── all/
│   │   │   ├── vars.yaml           # non-secret shared vars
│   │   │   ├── vault.yaml          # secrets, ansible-vault encrypted
│   │   │   └── vault.yaml.example  # template, safe to commit
│   │   └── storage_server.yaml
│   └── host_vars/
│       ├── pi0.yaml
│       └── pi1.yaml
├── roles/
│   ├── common/          # OS packages, dotfiles, locale, data dir, known_hosts
│   ├── docker/          # Docker install, repo clone, compose deploy
│   ├── nfs/             # SSD mount, NFS server/client (auto-detects role)
│   └── alertmanager/    # Alertmanager config + Telegram bot token
└── playbooks/
    └── deploy.yaml      # Single playbook, use --tags to scope
```

## Roles

| Role | Description | Tags |
|------|-------------|------|
| `common` | System packages, dotfiles, locale, data directory, GitHub host-key pinning | `common`, `packages`, `dotfiles`, `system`, `storage`, `ssh` |
| `docker` | Docker installation, repo clone, container deployment | `docker`, `install`, `repo`, `deploy` |
| `nfs` | SSD mount, NFS server exports or client mount (auto-detects) | `nfs`, `storage` |
| `alertmanager` | Renders `alertmanager.yml` and the Telegram bot token file. Runs only on the `monitoring` group. | `alertmanager`, `secrets` |

## Variables

Non-secret globals are in `inventory/group_vars/all/vars.yaml`. Host-specific
overrides go in `inventory/host_vars/<host>.yaml`.

## Secrets

There are two separate secret stores, by design:

| Store | Holds | Consumed by |
|-------|-------|-------------|
| `inventory/group_vars/all/vault.yaml` | Telegram bot token & chat id | Ansible, at template-render time |
| `docker/.env.private` | `DUCKDNS_TOKEN`, `TS_AUTH_KEY`, `SONARR_API_KEY`, `RADARR_API_KEY`, `BAZARR_API_KEY` | Docker Compose, at container runtime |

`docker/.env.private` is gitignored and lives only on the host — see
`docker/.env.private.example` for the full list of required variables (that
list is derived mechanically from the compose files).

### Vault workflow

```shell
cd ansible

# First time: create the vault from the template
cp inventory/group_vars/all/vault.yaml.example inventory/group_vars/all/vault.yaml
$EDITOR inventory/group_vars/all/vault.yaml          # put real values in
ansible-vault encrypt inventory/group_vars/all/vault.yaml

# Store the password locally (gitignored) so you need not retype it
printf '%s' 'your-vault-password' > .vault_pass
chmod 600 .vault_pass

# Later: edit or rotate
ansible-vault edit  inventory/group_vars/all/vault.yaml
ansible-vault rekey inventory/group_vars/all/vault.yaml
```

`vault.yaml` **is** committed, but only encrypted — that is what gives these
secrets a versioned, restorable home rather than existing solely on the Pis.
CI fails the build if it is ever committed in plaintext
(`.github/workflows/reviewdog.yml` :: `vault-encrypted`).

`vault_password_file` is deliberately **not** set in `ansible.cfg`, so plays
that need no secrets still run for someone without a vault. Pass it when
needed:

```shell
ansible-playbook playbooks/deploy.yaml -l pi1 --tags alertmanager \
  --vault-password-file .vault_pass
```

## Host key verification

`host_key_checking` is **enabled** in `ansible.cfg`. Seed the two Pis once,
from a trusted network position:

```shell
ssh-keyscan -H 192.168.68.10 192.168.68.11 >> ~/.ssh/known_hosts
```

Verify a fingerprint against what the Pi itself reports:

```shell
ssh pi@192.168.68.10 'ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub'
```

If a Pi is reimaged its key changes and connections fail loudly — that is
intended. Clear the stale entry with `ssh-keygen -R 192.168.68.10`, then
re-seed.

On the Pis themselves, the `common` role writes `~/.ssh/config` with
`github.com` pinned to `StrictHostKeyChecking yes` and its host keys
pre-seeded from GitHub's published metadata. This matters because
`scripts/auto_pull.sh` and pi0's `post-commit` hook fetch code over SSH and
then execute it via `docker compose up`.

## Alertmanager deployment note

The `alertmanager` role renders into the git checkout at
`{{ repo_path }}/config/alertmanager/`, which is the directory bind-mounted
into the container. It therefore runs **after** the `docker` role (which
clones the repo) and will fail with a clear message if the checkout is
missing. Both rendered files are gitignored, so the working tree stays clean.

Because the bot token previously lived inline in the committed
`alertmanager.yml`, pi1 needed no secrets at all. It does now: deploying
`--tags alertmanager` without a populated vault will fail the pre-flight
assertion rather than silently ship a broken config.
