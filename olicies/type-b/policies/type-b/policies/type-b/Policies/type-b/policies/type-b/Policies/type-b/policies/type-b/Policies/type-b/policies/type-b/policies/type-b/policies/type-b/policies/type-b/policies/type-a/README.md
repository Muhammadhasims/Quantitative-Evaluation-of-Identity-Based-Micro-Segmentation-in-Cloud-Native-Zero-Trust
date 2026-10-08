# Type A policy notes

Profile `minikube`. Linkerd is the PEP. SPIRE was an issuer demonstration. It was not the Linkerd certificate authority.

## L2

For the protected ports (Redis 6379, checkout 5050, payment 50051, and the other backend ports closed in the run):

- `Server` with `accessPolicy: deny`
- `MeshTLSAuthentication` naming the one service account that may call
- `AuthorizationPolicy` pointing at that `Server` and that identity

The unmeshed attacker is not that identity. Redis and the selected backends failed. The frontend stayed reachable, so path length stayed 1/7.

## L3

- `Server` `frontend-http` on port 8080, proxy protocol HTTP/1, access deny
- `HTTPRoute` for `GET /` requiring the frontend mesh identity
- `HTTPRoute` for `GET /cart` with an empty authentication list

Observed from `l3-client`: `GET /` = 200, `GET /cart` = 403.
Observed from the attacker: `GET /` = 403.
