#!/bin/sh

DEFAULT_RESOURCES="po svc ing ds no"

resources=${1:-$DEFAULT_RESOURCES}

echo "watch '\
  for resource in $resources; do \
    echo \$e; \
    kubectl get \$resource \
      -A \
      $(if [ \$resource != \"svc\" ] && [ \$resource != \"ds\" ]; \
      then \
        echo \"-o=wide\"; \
      fi); \
    echo; \
  done\
'" | \
tr -s " " | \
sh 
