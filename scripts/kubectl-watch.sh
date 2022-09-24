#!/bin/bash

source scripts/config.sh || exit 1

resources=${1:-$KUBECTL_WATCH_DEFAULT_RESOURCES}

echo "watch '\
  for resource in $resources; do \
    echo \$resource; \
    kubectl get \$resource \
      -A \
      \$(if [ \$resource != \"svc\" ] && [ \$resource != \"ds\" ]; \
      then \
        echo \"-o=wide\"; \
      fi); \
    echo; \
  done\
'" | \
tr -s " " | \
sh
