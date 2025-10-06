# ---- Docker Config ----
VERSION ?= $(shell git rev-parse --short HEAD)
DOCKER_REGISTRY = docker.io/karstenjakobsen
IMAGE_PREFIX ?= shiplite-
TAG ?= devel-$(VERSION)
DOCKER_FILE ?= Dockerfile

# ---- Projects Config ----
PROJECTS = whoami hello-world traefik-ingress github-runner

# Default target
.PHONY: all
all: build deploy

# Build Docker images for all services
.PHONY: build
build:
	@for service in $(PROJECTS); do \
		$(MAKE) build-$$service; \
	done

# Build Docker image for a specific service
.PHONY: build-%
build-%:
	@echo "Building Docker image for $*..."
	docker build -t $(DOCKER_REGISTRY)/$(IMAGE_PREFIX)$*:$(TAG) -t $(DOCKER_REGISTRY)/$(IMAGE_PREFIX)$*:latest ./docker/$*

# Push Docker images for all services
.PHONY: push
push:
	@for service in $(PROJECTS); do \
		$(MAKE) push-$$service; \
	done

# Push Docker image for a specific service
.PHONY: push-%
push-%:
	@echo "Pushing Docker image for $*..."
	docker push $(DOCKER_REGISTRY)/$(IMAGE_PREFIX)$*:$(TAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE_PREFIX)$*:latest

.PHONY: login
login:
	@echo "Logging into Docker registry..."
	docker login $(DOCKER_REGISTRY)
	@echo "Docker login successful."

# Example: make ansible-services service=github-runner-01@edge01 check=true
.PHONY: ansible-services
ansible-services:
	@echo "Running Ansible playbook to deploy services..."
	cd ansible && \
	ansible-playbook -i hosts/dev/inventory.yml playbooks/services.yml --limit "$(service)" --diff $(if $(check),--check)

.PHONY: ansible-encrypt-dev
ansible-encrypt-dev:
	@echo "Encrypting secrets for development environment for all files in hosts/dev/secrets/"
	cd ansible && \
	for file in hosts/dev/secrets/*; do \
		ansible-vault encrypt --encrypt-vault-id dev $$file; \
	done

.PHONY: ansible-encrypt-prod
ansible-encrypt-prod:
	@echo "Encrypting secrets for production environment for all files in hosts/prod/secrets/"
	cd ansible && \
	for file in hosts/prod/secrets/*; do \
		ansible-vault encrypt --encrypt-vault-id prod $$file; \
	done

.PHONY: help
help:
	@echo "Available Targets:"
	@echo "  all						- Build and deploy all services"
	@echo "  login                              		- Docker login"
	@echo "  build [ <project> <project2> ...]   		- Build all Docker images for all services"
	@echo "  build-service-a [ build-service-b ...]    	- Build Docker image(s) for one or more services"
	@echo "  push [ <project> <project2> ...]   		- Push all Docker images for all services"
	@echo "  push-service-a [ push-service-b ...]    	- Push Docker image(s) for one or more services"
	@echo "  help                               		- Show this help message"
