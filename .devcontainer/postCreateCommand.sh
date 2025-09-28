#!/bin/bash
set -e

sudo apt-get update && sudo apt-get install -y shellcheck git-crypt wget curl

pip3 install -r requirements.txt

pre-commit install

# Install trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Install minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl.sha256 kubectl

sudo touch /home/vscode/.ssh/known_hosts
sudo chown vscode:vscode /home/vscode/.ssh/known_hosts
sudo chmod 644 /home/vscode/.ssh/known_hosts

# Install pyenv
sudo curl -fsSL https://pyenv.run | bash

cat << 'EOF' >> ~/.zshrc

# Pyenv configuration
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

# Install github command line tool
curl -sS https://webi.sh/gh | sh

echo "Installing pre-commit hooks..."
pre-commit install

echo "Run pre-commit autoupdate..."
pre-commit autoupdate
pre-commit run --all

echo "Welcome to the jungle..."
