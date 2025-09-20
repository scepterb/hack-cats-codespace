#!/usr/bin/env bash
set -euo pipefail

echo "Running post-create install script..."

# Update and install more tools as non-root user via sudo if needed.
# Codespaces provides sudo for the 'vscode' user by default.
sudo apt-get update

# 1) hashcat (CPU-only in Codespaces; GitHub-hosted machines usually don't expose GPUs)
sudo apt-get install -y --no-install-recommends hashcat || echo "hashcat apt install failed; check availability"

# 2) rustscan - install from release .deb (fallback to cargo / snap if necessary)
TMPDIR=$(mktemp -d)
pushd "$TMPDIR" >/dev/null
RUSTSCAN_DEB="rustscan_amd64.deb"
# try to download the latest release deb from GitHub - may need update later
if curl -sL -o "$RUSTSCAN_DEB" "https://github.com/RustScan/RustScan/releases/latest/download/rustscan_amd64.deb"; then
  sudo dpkg -i "$RUSTSCAN_DEB" || sudo apt-get -f install -y
else
  echo "Could not download rustscan deb; skipping. You can install rustscan manually."
fi
popd >/dev/null
rm -rf "$TMPDIR"

# 3) gobuster - try apt, else build from release
if ! command -v gobuster >/dev/null 2>&1; then
  if sudo apt-get install -y gobuster; then
    echo "gobuster installed via apt"
  else
    echo "gobuster apt install unavailable; attempting binary download"
    # Gobuster official releases may be fetched and placed into /usr/local/bin
    # Replace version as needed
    GOBUSTER_VER="3.1.0"
    ARCH="linux-amd64"
    URL="https://github.com/OJ/gobuster/releases/download/v${GOBUSTER_VER}/gobuster_${GOBUSTER_VER}_${ARCH}.tar.gz"
    TMP=$(mktemp -d)
    if curl -sL -o "${TMP}/g.tar.gz" "$URL"; then
      sudo tar -C /usr/local/bin -xzf "${TMP}/g.tar.gz" --strip-components=1
      echo "gobuster installed to /usr/local/bin"
    else
      echo "Failed to download gobuster tarball; please install gobuster in your Codespace."
    fi
    rm -rf "$TMP"
  fi
fi

# 4) mongo shell (mongosh) - npm global install fallback
if ! command -v mongosh >/dev/null 2>&1; then
  # Try apt via MongoDB repo (skipped here for simplicity) or npm
  if command -v npm >/dev/null 2>&1; then
    sudo npm install -g mongosh || echo "npm install mongosh failed"
  else
    echo "npm not found; skipping mongosh install."
  fi
fi

# 5) pwntools + python utilities
python3 -m pip install --user --no-cache-dir pwntools ropgadget capstone unicorn sqlmap

# 6) sqlmap - install via pip or git clone as fallback
if ! command -v sqlmap.py >/dev/null 2>&1 && ! command -v sqlmap >/dev/null 2>&1; then
  # pip installation
  python3 -m pip install --user --no-cache-dir sqlmap
  # If still not available, clone to ~/tools/sqlmap
  if ! command -v sqlmap.py >/dev/null 2>&1; then
    mkdir -p ~/tools
    if git clone --depth=1 https://github.com/sqlmapproject/sqlmap.git ~/tools/sqlmap; then
      echo "sqlmap cloned to ~/tools/sqlmap; call it via python3 ~/tools/sqlmap/sqlmap.py"
    fi
  fi
fi

# 7) netcat already provided by netcat-openbsd; ncftp was apt-installed earlier
# 8) smbclient provided by smbclient; samba server is not necessary for clients

# 9) niceties: add ~/tools to PATH in .bashrc
if ! grep -q 'export PATH="$HOME/tools:$PATH"' ~/.bashrc 2>/dev/null; then
  echo 'export PATH="$HOME/tools:$PATH"' >> ~/.bashrc
fi

echo "Post-create install script finished. Please restart the shell or open a new terminal."