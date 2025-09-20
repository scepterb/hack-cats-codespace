FROM ubuntu:22.04

# common docker line that ensures package managers run w/o user input
ARG DEBIAN_FRONTEND=noninteractive

# Create a non-root user 'vscode' (Codespaces uses 'vscode' by convention)
RUN groupadd -r vscode && useradd -m -r -g vscode vscode

# Install core packages (edit/remove as you like)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl wget git ca-certificates apt-transport-https gnupg lsb-release \
    python3 python3-dev python3-pip python3-venv \
    nmap netcat-openbsd smbclient ncftp default-jre unzip jq \
    pkg-config libssl-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# Ensure pip and setuptools are up to date
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools

# Put install script into container and make it executable
COPY install-tools.sh /tmp/install-tools.sh
RUN chmod +x /tmp/install-tools.sh

# Allow non-root user to run the install script during devcontainer postCreate
RUN chown -R vscode:vscode /tmp/install-tools.sh

# Switch to non-root user for the workspace
USER vscode
WORKDIR /workspace

# Make the script available in the workspace so postCreateCommand can run it
RUN mkdir -p /workspace/.devcontainer && cp /tmp/install-tools.sh /workspace/.devcontainer/install-tools.sh

# Default shell
CMD [ "sleep", "infinity" ]