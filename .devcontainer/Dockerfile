FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# common docker line that ensures package managers run w/o user input
ARG DEBIAN_FRONTEND=noninteractive

# Install core packages
# (NB: pip3 --no-cache-dir to stop pip from storing copies of packages)
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install -y \
        python3 python3-pip \
        hashcat \
        nmap \
        netcat-openbsd \
        smbclient \ 
        ncftp \
        gobuster \
    && pip3 install --no-cache-dir pwntools \
    && rm -rf /var/lib/apt/lists/*