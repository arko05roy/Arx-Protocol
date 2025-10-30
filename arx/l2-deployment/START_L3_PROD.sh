#!/usr/bin/env bash
set -euo pipefail

OP_ROOT="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"
L2_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
DEPLOY_CFG="$OP_ROOT/packages/contracts-bedrock/deploy-config/celo-sepolia.json"
L1_DEPLOYMENTS="$OP_ROOT/packages/contracts-bedrock/deployments/11142220-deploy.json"
WORKDIR="$OP_ROOT/.deployer"
LOGS="$L2_DIR/logs"

mkdir -p "$LOGS" "$L2_DIR/geth-data"

step() { echo "\n==== $* ====\n"; }

step "Preflight checks"
command -v docker >/dev/null || { echo "Docker is required"; exit 1; }

# Ensure premint exists in allocs.json (100,000 GAIA)
if [ -f "$L2_DIR/allocs.json" ]; then
  if ! jq -e 'has("0xABaF59180e0209bdB8b3048bFbe64e855074C0c4")' "$L2_DIR/allocs.json" >/dev/null; then
    jq '. + {"0xABaF59180e0209bdB8b3048bFbe64e855074C0c4":{"balance":"0x56bc75e2d630eb20000"}}' \
      "$L2_DIR/allocs.json" > "$L2_DIR/allocs.tmp" && mv "$L2_DIR/allocs.tmp" "$L2_DIR/allocs.json"
  fi
else
  printf '{"0xABaF59180e0209bdB8b3048bFbe64e855074C0c4":{"balance":"0x56bc75e2d630eb20000"}}' > "$L2_DIR/allocs.json"
fi

step "Generate genesis/rollup artifacts"
# Prefer op-deployer inspect if .deployer/state.json exists; else use op-node genesis l2
if [ -f "$WORKDIR/state.json" ]; then
  # op-deployer present? build if needed
  if [ ! -f "$OP_ROOT/op-deployer/bin/op-deployer" ]; then
    (cd "$OP_ROOT/op-deployer/cmd/op-deployer" && go build -o "$OP_ROOT/op-deployer/bin/op-deployer" .)
  fi
  "$OP_ROOT/op-deployer/bin/op-deployer" inspect genesis --workdir "$WORKDIR" 424242 > "$L2_DIR/genesis.json"
  "$OP_ROOT/op-deployer/bin/op-deployer" inspect rollup  --workdir "$WORKDIR" 424242 > "$L2_DIR/rollup.json"
else
  # Fallback to op-node genesis l2 (requires patched op-node and correct deploy-config)
  if [ ! -f "$OP_ROOT/op-node/bin/op-node" ]; then
    (cd "$OP_ROOT/op-node" && just op-node)
  fi
  "$OP_ROOT/op-node/bin/op-node" genesis l2 \
    --deploy-config "$DEPLOY_CFG" \
    --l1-deployments "$L1_DEPLOYMENTS" \
    --l1-rpc https://rpc.ankr.com/celo_sepolia \
    --l2-allocs "$L2_DIR/allocs.json" \
    --outfile.l2 "$L2_DIR/genesis.json" \
    --outfile.rollup "$L2_DIR/rollup.json"
fi

[ -s "$L2_DIR/genesis.json" ] && [ -s "$L2_DIR/rollup.json" ] || { echo "Artifact generation failed"; exit 1; }

echo "Artifacts ready:"
ls -lah "$L2_DIR/genesis.json" "$L2_DIR/rollup.json"

step "Stop existing services"
pkill -f "op-node/bin/op-node|op-batcher/bin/op-batcher|op-proposer/bin/op-proposer|simple-rpc-proxy.js" 2>/dev/null || true
docker rm -f celo-l3-geth 2>/dev/null || true

step "Initialize op-geth with new genesis"
rm -rf "$L2_DIR/geth-data"/*

docker run --rm \
  -v "$L2_DIR/geth-data":/geth-data \
  -v "$L2_DIR/genesis.json":/genesis.json:ro \
  us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest \
  init --datadir=/geth-data /genesis.json

docker run -d \
  --name celo-l3-geth \
  -p 8545:8545 -p 8546:8546 -p 8551:8551 -p 30303:30303 \
  -v "$L2_DIR/geth-data":/geth-data \
  -v "$L2_DIR/jwt-secret.txt":/jwt-secret.txt:ro \
  us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest \
  --datadir=/geth-data \
  --http --http.addr=0.0.0.0 --http.port=8545 --http.api=web3,eth,debug,net,engine --http.corsdomain="*" \
  --ws --ws.addr=0.0.0.0 --ws.port=8546 --ws.api=web3,eth,debug,net,engine --ws.origins="*" \
  --authrpc.addr=0.0.0.0 --authrpc.port=8551 --authrpc.jwtsecret=/jwt-secret.txt --authrpc.vhosts="*" \
  --syncmode=full --maxpeers=0 --networkid=424242 --nodiscover --rollup.disabletxpoolgossip >/dev/null

sleep 6

step "Start op-node"
nohup "$OP_ROOT/op-node/bin/op-node" \
  --l1=https://rpc.ankr.com/celo_sepolia \
  --l2=http://localhost:8551 \
  --l2.jwt-secret="$L2_DIR/jwt-secret.txt" \
  --rollup.config="$L2_DIR/rollup.json" \
  --rpc.addr=0.0.0.0 --rpc.port=9545 \
  --p2p.disable \
  --l1.trustrpc \
  --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7300 \
  > "$LOGS/op-node.log" 2>&1 &

sleep 10

step "Start op-batcher"
nohup "$OP_ROOT/op-batcher/bin/op-batcher" \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c \
  --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7301 \
  > "$LOGS/op-batcher.log" 2>&1 &

sleep 8

step "Start op-proposer"
nohup "$OP_ROOT/op-proposer/bin/op-proposer" \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --rollup-rpc=http://localhost:9545 \
  --game-factory-address=0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e \
  --proposal-interval=1m \
  --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 \
  --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7302 \
  > "$LOGS/op-proposer.log" 2>&1 &

sleep 12

step "Status"
OK=1
ps aux | grep -q "op-node/bin/op-node" || OK=0
ps aux | grep -q "op-batcher/bin/op-batcher" || OK=0
ps aux | grep -q "op-proposer/bin/op-proposer" || OK=0

if [ "$OK" -eq 1 ]; then
  echo "ALL RUNNING"
else
  echo "NOT ALL RUNNING"; fi

echo "\n-- op-node --"; tail -n 50 "$LOGS/op-node.log" || true

echo "\n-- op-batcher --"; tail -n 50 "$LOGS/op-batcher.log" || true

echo "\n-- op-proposer --"; tail -n 50 "$LOGS/op-proposer.log" || true
