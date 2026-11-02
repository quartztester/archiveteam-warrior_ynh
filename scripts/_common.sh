#!/bin/bash

# Nothing shared between scripts yet: the compose file (conf/) carries the
# app logic, and lifecycle scripts only orchestrate docker/systemd/nginx.

# CI restores land on a fresh container where docker.io and the compose
# plugin are gone; install and restore both need them (upgrade too).
_archiveteam_ensure_docker() {
    if ! systemctl is-active --quiet docker; then
        if ! command -v docker >/dev/null 2>&1; then
            ynh_script_progression "Installing Docker (docker.io)..."
            apt-get update -qq
            DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install docker.io
        fi
        systemctl enable --now docker
        for _ in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 2; done
        docker info >/dev/null 2>&1 || ynh_die --message="Docker installed but the daemon did not come up."
    fi

    if ! docker compose version >/dev/null 2>&1; then
        ynh_script_progression "Installing docker compose v2 CLI plugin..."
        mkdir -p /usr/local/lib/docker/cli-plugins
        ynh_setup_source --source_id=compose --dest_dir="/usr/local/lib/docker/cli-plugins"
        if [ -e "/usr/local/lib/docker/cli-plugins/docker-compose-linux-x86_64" ]; then
            mv "/usr/local/lib/docker/cli-plugins/docker-compose-linux-x86_64" /usr/local/lib/docker/cli-plugins/compose
        fi
        chmod 755 /usr/local/lib/docker/cli-plugins/compose
        # Debian's docker.io 20.10 (bookworm) only discovers dash-named CLI
        # plugins; newer CLIs want "compose". Hardlink = both work.
        ln -f /usr/local/lib/docker/cli-plugins/compose /usr/local/lib/docker/cli-plugins/docker-compose
    fi
}
