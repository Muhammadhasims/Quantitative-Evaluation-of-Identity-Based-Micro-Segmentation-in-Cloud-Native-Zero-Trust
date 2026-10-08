#!/bin/sh
set -u
kubectl exec -n bi-front l3-client -c l3-client -- \
  curl -s -o /dev/null -w "allow:%{http_code}\n" --connect-timeout 8 \
  http://productpage.bi-front.svc.cluster.local:9080/productpage
kubectl exec -n bi-front l3-client -c l3-client -- \
  curl -s -o /dev/null -w "deny:%{http_code}\n" --connect-timeout 8 \
  http://productpage.bi-front.svc.cluster.local:9080/api/v1/products
kubectl exec attacker -- \
  curl -s -o /dev/null -w "attacker:%{http_code}\n" --connect-timeout 5 \
  http://productpage.bi-front.svc.cluster.local:9080/productpage
