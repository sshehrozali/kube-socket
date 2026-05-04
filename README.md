<p align="center">
  <img src="logo.png" alt="KubeSocket logo" width="320" />
</p>

# kubetracer

KubeTracer is a high-performance, cloud-native network monitor designed for transparent visibility into HTTP/gRPC traffic across Kubernetes nodes. Unlike proxy-based service meshes, KubeTracer operates with zero sidecars, requires no application restarts, and ensures near-zero overhead on your application pods.

By capturing traffic at the host-network interface, KubeTracer reassembles TCP streams to provide live observability—optimized for debugging distributed systems and monitoring inter-service communication.

## Repository layout

| Path | Purpose |
|------|---------|
| [`cmd/kubesocket`](cmd/kubesocket) | Main entrypoint |
| [`internal/kubesocket`](internal/kubesocket) | Capture and TCP assembly logic |
| [`deploy/kind`](deploy/kind) | [kind](https://kind.sigs.k8s.io/) cluster config and demo workloads |
| [`deploy/manifests`](deploy/manifests) | Example DaemonSet manifests (registry / local variants) |
| [`deploy/examples`](deploy/examples) | Optional load-test manifests |
| [`hack`](hack) | Development scripts (e.g. local kind provisioning) |
| [`docs`](docs) | Supplementary documentation |

Contributing, license, and security reporting: see [`CONTRIBUTING.md`](CONTRIBUTING.md), [`LICENSE`](LICENSE), and [`SECURITY.md`](SECURITY.md).

## Quick start

### Prerequisites

- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Setup

```bash
make kind-up
# or: ./hack/setup-kind.sh
```

### Test

```bash
# External traffic
curl http://localhost:32407

# Pod-to-pod traffic
kubectl exec -l app=curl -- curl -s http://10.244.1.2

# View logs
kubectl logs -l name=kubesocket --follow
```

### Cleanup

```bash
kind delete cluster
```

## Packet layout reference

For manual inspection of raw frames (Ethernet through TCP), see [docs/packet-offsets.md](docs/packet-offsets.md).
