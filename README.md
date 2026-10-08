# Quantitative Evaluation of Identity-Based Micro-Segmentation in Cloud-Native Zero Trust

**Muhammad Hasim S** and **Dr. Muneer Ahmad Dar**
NIELIT (Deemed to be University)

This repository is the artifact for the paper of the same name. It records the policy ladder, the probe method, and the measured outcomes. It does not contain the Online Boutique or Bookinfo application source. Those are upstream projects.

Before the paper is submitted, set this repository to **Public**. A private repository returns 404 to a reviewer. Use this URL in the paper:

https://github.com/Muhammadhasims/Quantitative-Evaluation-of-Identity-Based-Micro-Segmentation-in-Cloud-Native-Zero-Trust

## Question

How much of a fixed attacker's east-west path is blocked as policy becomes finer, and what does the next step cost in latency and number of policy objects?

## What was measured

One unmeshed, unprivileged pod (`nicolaka/netshoot`, namespace `default`, no sidecar) on the same Minikube node as the application. It uses in-cluster DNS, then `curl` or `nc`. It is a co-tenant foothold, not an Internet client.

A probe **succeeds** only if an application response is obtained (any HTTP code, including 400 or 500, or a protocol mismatch such as Redis `+PONG`). It **fails** on timeout, TCP reset, curl error, or policy deny. Curl HTTP code `000` is a failure. Curl exit 56 (connection reset before an HTTP status) is also a failure.

| Level | Control | What it does not do |
|---|---|---|
| L0 | Flat network. No NetworkPolicy. No mesh. | — |
| L1 | Namespace split and default-deny NetworkPolicy | No identity, no HTTP path |
| L2 | Service identity and mutual TLS | Does not split one identity by URL |
| L3 | Per-request HTTP path rule | Does not reopen a path the attacker already lost |

Two stacks on **Online Boutique** (N = 7 probes):

| Stack | Profile | PEP | PE | Identity issuer |
|---|---|---|---|---|
| Type A | `minikube` | Linkerd sidecar | Linkerd policy objects | SPIRE demo only; not the Linkerd CA |
| Type B | `typeb` | Istio sidecar | Open Policy Agent at L3 | SPIRE; not the Istio CA |

Type B only was repeated on **Istio Bookinfo** (N = 4). Online Boutique was scaled to zero first so only one application ran on the 8 GB node.

## Results

### Online Boutique (seven probes)

| Level | Type A path | Type B path | Type A radius | Type B radius |
|---|---:|---:|---:|---:|
| L0 | 7/7 | 7/7 | 100% | 100% |
| L1 | 1/7 | 1/7 | ≈14% | ≈14% |
| L2 | 1/7 | 0/7 | ≈14% | 0% |
| L3 | 0/7 | 0/7 | 0% | 0% |

L1 is the large step on both stacks: six of seven probes fail; only the front service remains. Type B reaches radius 0 at L2 because `PeerAuthentication` STRICT rejects the unmeshed caller, including on the frontend. Type A still leaves the frontend reachable at L2 and closes it at L3 (HTTP 403).

Authorised client `l3-client` at L3:

| Probe | Type A | Type B |
|---|---|---|
| `GET /` | 200 | 200 |
| `GET /cart` | 403 | 403 |
| attacker `GET /` | 403 | 000 |
| Redis from attacker | blocked | blocked |
| p50 / p95 (ms), 50× HTTP 200 `GET /` | 16.2 / 81.4 | 18.3 / 68.0 |

L0 shop-page baseline on the same method: average 14.4 ms, p95 46.0 ms. Neither mesh is claimed to be faster.

### Bookinfo, Type B only (four probes)

| Level | Path | Radius | Attacker on productpage | Authorised |
|---|---:|---:|---|---|
| L0 | 4/4 | 100% | 200 | — |
| L1 | 1/4 | 25% | 200 | — |
| L2 | 0/4 | 0% | 000 | — |
| L3 | 0/4 | 0% | 000 | 200 / 403 |

L3 authorised pair, 8 October 2026:

    allow:200    GET /productpage
    deny:403     GET /api/v1/products
    attacker:000 curl exit 56 (reset before an HTTP status)

25% is 1/4. It is not the Boutique figure of about 14% (1/7). Bookinfo latency is not reported.

## Versions

| Piece | Version |
|---|---|
| Host | Ubuntu 26.04, Docker driver |
| Minikube | v1.39.0 |
| Kubernetes | v1.37.0 |
| Type B node | 2 CPU, 5120 MB, profile `typeb` |
| Istio | 1.31.1, demo profile |
| OPA | openpolicyagent/opa:0.70.0-envoy, gRPC 9191 |
| Attacker image | nicolaka/netshoot |

## What this repository does not claim

- Not a multi-node or production cluster.
- Not a full ATT&CK campaign. Techniques used: T1046, T1018, T1021, and T1552.001 at L0.
- SPIRE was not the mesh certificate authority.
- Sidecar readings of about 1 mCPU and 3 MiB are too coarse for a performance claim.
- Policy-object counts: 0 at L0, 6 NetworkPolicies at L1, about 15–21 mesh objects at L2/L3.

## Upstream applications

- Online Boutique: https://github.com/GoogleCloudPlatform/microservices-demo
- Bookinfo: https://istio.io/latest/docs/examples/bookinfo/
