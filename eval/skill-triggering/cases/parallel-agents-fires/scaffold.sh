#!/bin/bash
# Five independent services, each with its own dependency manifest.
for s in auth billing catalog orders search; do
  mkdir -p "services/$s"
  printf '{ "name": "%s", "dependencies": { "express": "^4.17.1", "lodash": "^4.17.15" } }\n' "$s" \
    > "services/$s/package.json"
done
