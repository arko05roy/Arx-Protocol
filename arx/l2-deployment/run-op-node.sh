#!/bin/bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
exec /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-node/bin/op-node \
  --l1=https://rpc.ankr.com/celo_sepolia \
  --l2=http://localhost:8551 \
  --l2.jwt-secret=./jwt-secret.txt \
  --rollup.config=./rollup.json \
  --rpc.addr=0.0.0.0 \
  --rpc.port=9545 \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7300 \
  --p2p.disable \
  --l1.trustrpc \
  "$@"
