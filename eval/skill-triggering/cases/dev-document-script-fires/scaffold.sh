#!/bin/bash
# A Node project with sales data, so the script has something to read.
mkdir -p data scripts
printf '{ "name": "sales-tools", "private": true, "type": "module" }\n' > package.json
printf 'date,region,amount\n2026-09-02,North,1200\n2026-09-03,South,800\n' > data/sales.csv
