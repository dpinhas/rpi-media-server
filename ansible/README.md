# Raspberry Pi Setup and Deployment with Ansible

This repository contains Ansible playbooks and tasks for setting up and deploying a Raspberry Pi using best practices. It includes tasks for preparing the Pi, installing and deploying Docker containers, and configuring storage.

## Prerequisites

Before running the Ansible playbooks, ensure you have the following prerequisites:

- Ansible installed on your local machine
- SSH access to the Raspberry Pi(s) with the `pi` user

## Getting Started

1. Clone this repository to your local machine:

```shell
git clone git@github.com:dpinhas/rpi-media-server.git
```

2. Modify the inventory file `hosts` to include the IP addresses or hostnames of your Raspberry Pis under the `rpi` group.

3. Customize the variables in `main.yaml` according to your requirements. You can specify the locale, data path, and other configuration options.

4. Install requirements for it by running:

```shell
ansible-galaxy install -r requirements.yaml
```

5. Run the playbook:

```shell
ansible-playbook main.yaml -l pi0 -e perform_raspberry_pi_setup=true -e deploy_docker_containers=true
```

This will execute the tasks to prepare the Raspberry Pi and install/deploy Docker containers based on your configuration.

## Playbook Structure

- `setup_raspberry_pi.yaml`: Prepares the Raspberry Pi by updating packages, installing dependencies, customizing shell and Vim settings, and configuring SSH.

- `deploy_docker_containers.yaml`: Installs Docker, adds the `pi` user to the Docker group, clones a GitHub repository, deploys Docker containers, and sets up cron jobs.

## Customization

- Modify the variables in `setup_raspberry_pi.yaml` and `deploy_docker_containers.yaml` to adjust the configuration according to your needs.

- Additional tasks and playbooks can be added as separate YAML files and included in the main playbook (`main.yaml`).

