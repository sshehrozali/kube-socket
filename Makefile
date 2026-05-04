# --- KubeTracer Build Configuration ---
DOCKER_USER  ?= shehrozdevhub
IMAGE_NAME   ?= kubetracer
VERSION      ?= v1.0.1
PLATFORMS    ?= linux/amd64,linux/arm64
BUILDER_NAME ?= kubetracer-builder

FULL_IMAGE_NAME = $(DOCKER_USER)/$(IMAGE_NAME)

.PHONY: help build test vet lint build-local kind-up release clean

# Default target: show help
help:
	@echo "================================================================"
	@echo "KubeTracer Build System"
	@echo "================================================================"
	@echo "Usage:"
	@echo "  make test         - Run unit tests (requires libpcap for CGO)"
	@echo "  make vet          - Run go vet"
	@echo "  make lint         - Run golangci-lint (install binary separately)"
	@echo "  make build        - Build kubetracer binary to ./bin/kubetracer"
	@echo "  make build-local  - Build Docker image for current architecture"
	@echo "  make kind-up      - Local kind cluster + demo (see hack/setup-kind.sh)"
	@echo "  make release      - Build & Push Multi-Arch (AMD64/ARM64) to Hub"
	@echo "  make clean        - Remove local build artifacts"
	@echo "================================================================"

build:
	@mkdir -p bin
	CGO_ENABLED=1 go build -trimpath -ldflags="-s -w" -o bin/kubetracer ./cmd/kubetracer

test:
	CGO_ENABLED=1 go test ./...

vet:
	go vet ./...

lint:
	golangci-lint run

kind-up:
	./hack/setup-kind.sh

docker-login:
	@echo "Logging into Docker Hub..."
	docker login

# 1. Local Build (Fastest for testing on your current machine)
build-local:
	@echo "Building locally for current architecture..."
	docker build -t $(FULL_IMAGE_NAME):latest .
	@echo "Local build complete: $(FULL_IMAGE_NAME):latest"

# 2. Multi-Arch Release
release: docker-login
	@echo "Setting up Docker Buildx..."
	# Create and use a new builder instance if it doesn't exist
	docker buildx create --name $(BUILDER_NAME) --use || docker buildx use $(BUILDER_NAME)
	docker buildx inspect --bootstrap
	
	@echo "Starting Multi-Arch build for $(PLATFORMS)..."
	# This command builds both versions, creates the manifest, and pushes to Hub
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(FULL_IMAGE_NAME):$(VERSION) \
		-t $(FULL_IMAGE_NAME):latest \
		--push .
	
	@echo "Successfully pushed $(FULL_IMAGE_NAME):$(VERSION) to Docker Hub"
	@echo "Cleaning up builder..."
	docker buildx rm $(BUILDER_NAME)

# 3. Clean up
clean:
	@echo "Cleaning up build artifacts..."
	rm -rf bin/
	docker rmi $(FULL_IMAGE_NAME):latest || true
