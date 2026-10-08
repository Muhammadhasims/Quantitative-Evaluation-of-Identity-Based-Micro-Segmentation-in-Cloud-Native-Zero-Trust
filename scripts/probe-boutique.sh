#!/bin/sh
set -u
echo "===== Boutique probe ====="
echo -n "frontend      "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 3 http://frontend.frontend-ns:80/
echo -n "cart          "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 3 http://cartservice.backend-ns:7070
echo -n "checkout      "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 3 http://checkoutservice.backend-ns:5050
echo -n "catalog       "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 3 http://productcatalogservice.backend-ns:3550
echo -n "payment       "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 3 http://paymentservice.backend-ns:50051
echo -n "shipping      "; curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 3 http://shippingservice.backend-ns:50051
echo -n "redis         "; echo -e "PING\r\n" | nc -w 3 redis-cart.data-ns 6379; echo "exit:$?"
