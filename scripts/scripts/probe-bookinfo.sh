#!/bin/sh
set -u
echo "===== Bookinfo probe ====="
echo -n "productpage "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://productpage.bi-front.svc.cluster.local:9080/productpage
echo -n "details     "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://details.bi-back.svc.cluster.local:9080/details/0
echo -n "reviews     "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://reviews.bi-back.svc.cluster.local:9080/reviews/0
echo -n "ratings     "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://ratings.bi-data.svc.cluster.local:9080/ratings/0
