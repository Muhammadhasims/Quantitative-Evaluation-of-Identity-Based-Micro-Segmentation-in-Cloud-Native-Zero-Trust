# Limits (do not drop these in the paper)

- One Minikube node. Type B used 2 CPU and 5120 MB. This is not a production cluster.
- The attacker is one co-tenant pod. Seven fixed ports on Boutique and four on Bookinfo.
- Success means an application response. Timeout, reset, and curl exit 56 are failures.
- Latency is 50 sequential HTTP 200 calls, not a load generator. No claim that either mesh is faster.
- Bookinfo latency is omitted.
- SPIRE is not the mesh CA.
- Sidecar CPU from `kubectl top` is too coarse for a performance claim.
- Type A was not repeated on Bookinfo.
