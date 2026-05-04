# Contributing to KubeTracer

Thanks for helping improve KubeTracer. This document describes how we work and what to expect when you open issues or pull requests.

## Code of conduct

Participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). Be respectful and constructive.

## Getting started

1. Fork the repository and clone your fork.
2. Install [Go](https://go.dev/dl/) **1.23+** (see the `go` directive in `go.mod`).
3. Install [libpcap](https://www.tcpdump.org/) development headers — required because capture uses CGO (`github.com/google/gopacket/pcap`).
   - macOS: Xcode Command Line Tools / libpcap is usually available via the system or Homebrew.
   - Debian/Ubuntu: `sudo apt-get install -y libpcap-dev`.
4. Build and test from the repository root:

```bash
make build
make test
make vet
```

Optional: install [golangci-lint](https://golangci-lint.run/welcome/install/) and run `make lint`.

## Local Kubernetes demo

If you use [kind](https://kind.sigs.k8s.io/) and Docker, you can spin up the reference cluster and workloads:

```bash
make kind-up
# or: ./hack/setup-kind.sh
```

Manifests live under `deploy/kind/`. Production-style DaemonSet examples are under `deploy/manifests/`.

## Pull requests

- Open a PR against `main` with a clear description of the problem and the change.
- Keep changes focused; unrelated refactors belong in separate PRs.
- Ensure `make test` and `make vet` pass locally before requesting review.
- If your change is user-visible, update `README.md` or `docs/` as appropriate.

### Commit messages

Use clear, imperative subjects (for example: `fix: handle EOF in stream reader`). Conventional Commits are welcome but not strictly enforced.

## Reporting security issues

Do not open public issues for security vulnerabilities. See [SECURITY.md](SECURITY.md).

## Questions

Open an issue if something in this guide is unclear.
