FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Install core packages
# DEBIAN_FRONTEND ensures package managers run w/o user input
# (NB: pip3 --no-cache-dir to stop pip from storing copies of packages)
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 python3-pip \
        hashcat \
        nmap \
        netcat-openbsd \
        smbclient \
        ncftp \
        gobuster \
    && pip3 install --no-cache-dir pwntools \
    && rm -rf /var/lib/apt/lists/*

USER vscode