#!/usr/bin/env bash
set -euo pipefail

OP_ROOT="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"
L2_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
DEPLOY_CFG="$OP_ROOT/packages/contracts-bedrock/deploy-config/celo-sepolia.json"
L1_DEPLOYMENTS="$OP_ROOT/packages/contracts-bedrock/deployments/11142220-deploy.json"
WORKDIR="$OP_ROOT/.deployer"
LOGS="$L2_DIR/logs"
BEDROCK_DIR="$OP_ROOT/packages/contracts-bedrock"

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

step "Generate genesis/rollup artifacts (Option B: build allocs from Bedrock artifacts)"
# Install Foundry if missing
if ! command -v forge >/dev/null 2>&1; then
  curl -L https://foundry.paradigm.xyz | bash
  # Try direct foundryup path first
  if [ -x "$HOME/.foundry/bin/foundryup" ]; then
    "$HOME/.foundry/bin/foundryup" || true
  fi
  # shellcheck disable=SC1090
  [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" || true
  # shellcheck disable=SC1090
  [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" || true
  command -v foundryup >/dev/null 2>&1 && foundryup || true
fi
# Install pnpm if missing
if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm
fi
# Build Bedrock contracts (needed for forge-artifacts)
(cd "$BEDROCK_DIR" && pnpm install && forge build)

# Build a small generator to emit full L2 allocs with predeploy code + user premints
GEN_SRC="$L2_DIR/cmd-allocs-gen.go"
cat > "$GEN_SRC" << 'EOF'
package main

import (
    "encoding/json"
    "fmt"
    "os"
    "path/filepath"
    "strings"
)

type ForgeAllocAccount struct {
    Balance string            `json:"balance,omitempty"`
    Nonce   string            `json:"nonce,omitempty"`
    Code    string            `json:"code,omitempty"`
    Storage map[string]string `json:"storage,omitempty"`
}
type ForgeAllocs map[string]ForgeAllocAccount

type Artifact struct { DeployedBytecode string `json:"deployedBytecode"` }

func must(err error) { if err != nil { panic(err) } }

func readArtifactBytecode(root, subdir, contract string) string {
    p := filepath.Join(root, "forge-artifacts", subdir, contract+".json")
    b, err := os.ReadFile(p); must(err)
    var a Artifact
    must(json.Unmarshal(b, &a))
    return strings.ToLower(strings.TrimPrefix(a.DeployedBytecode, "0x"))
}

func main() {
    bedrock := "/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/packages/contracts-bedrock"
    allocs := ForgeAllocs{}
    // Core subset of predeploys sufficient for genesis validation
    // Address map (name -> address) derived from Predeploys.sol
    pre := map[string]string{
        // Essential predeploy set (extendable)
        "L2TO_L1_MESSAGE_PASSER": "0x4200000000000000000000000000000000000000",
        "L1_BLOCK":                "0x4200000000000000000000000000000000000015",
        "OPTIMISM_MINTABLE_ERC20_FACTORY": "0x4200000000000000000000000000000000000012",
        "GAS_PRICE_ORACLE":        "0x420000000000000000000000000000000000000F",
        "PROXY_ADMIN":             "0x4200000000000000000000000000000000000018",
        "SEQUENCER_FEE_VAULT":     "0x4200000000000000000000000000000000000011",
        "L2_STANDARD_BRIDGE":      "0x4200000000000000000000000000000000000010",
        "CROSS_DOMAIN_MESSENGER":  "0x4200000000000000000000000000000000000007",
        "PERMIT2":                 "0x4200000000000000000000000000000000000019",
    }
    // Map predeploy names to artifact locations (sol subdir, contract name)
    art := map[string][2]string{
        "L2TO_L1_MESSAGE_PASSER": {"L2/L2ToL1MessagePasser.sol", "L2ToL1MessagePasser"},
        "L1_BLOCK":                {"L2/L1Block.sol", "L1Block"},
        "OPTIMISM_MINTABLE_ERC20_FACTORY": {"universal/OptimismMintableERC20Factory.sol", "OptimismMintableERC20Factory"},
        "GAS_PRICE_ORACLE":        {"L2/GasPriceOracle.sol", "GasPriceOracle"},
        "PROXY_ADMIN":             {"universal/ProxyAdmin.sol", "ProxyAdmin"},
        "SEQUENCER_FEE_VAULT":     {"predeploys/SequencerFeeVault.sol", "SequencerFeeVault"},
        "L2_STANDARD_BRIDGE":      {"L2/L2StandardBridge.sol", "L2StandardBridge"},
        "CROSS_DOMAIN_MESSENGER":  {"L2/L2CrossDomainMessenger.sol", "L2CrossDomainMessenger"},
        "PERMIT2":                 {"libraries/Permit2.sol", "Permit2"},
    }
    for name, addr := range pre {
        m := ForgeAllocAccount{Balance: "0x0", Nonce: "0x0"}
        if a, ok := art[name]; ok {
            m.Code = readArtifactBytecode(bedrock, a[0], a[1])
        }
        allocs[strings.ToLower(addr)] = m
    }
    // Merge user premints
    allocs[strings.ToLower("0xABaF59180e0209bdB8b3048bFbe64e855074C0c4")] = ForgeAllocAccount{Balance: "0x56bc75e2d630eb20000", Nonce: "0x0"}
    allocs[strings.ToLower("0x89a26a33747b293430D4269A59525d5D0D5BbE65")] = ForgeAllocAccount{Balance: "0x56bc75e2d630eb20000", Nonce: "0x0"}
    allocs[strings.ToLower("0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62")] = ForgeAllocAccount{Balance: "0x2b5e3af16b1880000", Nonce: "0x0"}
    allocs[strings.ToLower("0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47")] = ForgeAllocAccount{Balance: "0x2b5e3af16b1880000", Nonce: "0x0"}
    allocs[strings.ToLower("0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49")] = ForgeAllocAccount{Balance: "0xb1a2bc2ec50000", Nonce: "0x0"}

    out, _ := json.MarshalIndent(allocs, "", "  ")
    must(os.WriteFile("/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/l2-allocs.json", out, 0644))
    fmt.Println("Wrote l2-allocs.json with", len(allocs), "accounts")
}
EOF

# Build and run generator
(cd "$L2_DIR" && go run ./cmd-allocs-gen.go)

# Use op-node to produce artifacts
if [ ! -f "$OP_ROOT/op-node/bin/op-node" ]; then
  (cd "$OP_ROOT/op-node" && just op-node)
fi
"$OP_ROOT/op-node/bin/op-node" genesis l2 \
  --deploy-config "$DEPLOY_CFG" \
  --l1-deployments "$L1_DEPLOYMENTS" \
  --l1-rpc https://rpc.ankr.com/celo_sepolia \
  --l2-allocs "$L2_DIR/l2-allocs.json" \
  --outfile.l2 "$L2_DIR/genesis.json" \
  --outfile.rollup "$L2_DIR/rollup.json"

[ -s "$L2_DIR/genesis.json" ] && [ -s "$L2_DIR/rollup.json" ] || { echo "Artifact generation failed"; exit 1; }

echo "Artifacts ready:"
ls -lah "$L2_DIR/genesis.json" "$L2_DIR/rollup.json"

# Prepare L1 chain-config for Celo Sepolia (genesis-style with blobSchedule)
step "Prepare L1 chain-config (Celo Sepolia)"
L1CFG="$L2_DIR/celo-sepolia-l1.json"
if [ ! -f "$L1CFG" ]; then
  cat > "$L1CFG" << 'JSON'
{
  "config": {
    "chainId": 11142220,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "arrowGlacierBlock": 0,
    "grayGlacierBlock": 0,
    "mergeNetsplitBlock": 0,
    "shanghaiTime": 0,
    "cancunTime": 0,
    "terminalTotalDifficulty": 0,
    "blobSchedule": {}
  }
}
JSON
fi

# Patch rollup forks to avoid L1 Beacon requirement (disable Ecotone+)
step "Patch rollup forks (disable Ecotone and later)"
if command -v jq >/dev/null 2>&1; then
  tmp=$(mktemp)
  jq '.ecotone_time = null | .fjord_time = null | .granite_time = null | .holocene_time = null | .isthmus_time = null | .jovian_time = null | .interop_time = null' \
    "$L2_DIR/rollup.json" > "$tmp" && mv "$tmp" "$L2_DIR/rollup.json"
else
  sed -i '' 's/"ecotone_time"\s*:\s*[0-9]\+/"ecotone_time": null/' "$L2_DIR/rollup.json" || true
  sed -i '' 's/"fjord_time"\s*:\s*[0-9]\+/"fjord_time": null/' "$L2_DIR/rollup.json" || true
  sed -i '' 's/"granite_time"\s*:\s*[0-9]\+/"granite_time": null/' "$L2_DIR/rollup.json" || true
  sed -i '' 's/"holocene_time"\s*:\s*[0-9]\+/"holocene_time": null/' "$L2_DIR/rollup.json" || true
  sed -i '' 's/"isthmus_time"\s*:\s*[0-9]\+/"isthmus_time": null/' "$L2_DIR/rollup.json" || true
  sed -i '' 's/"jovian_time"\s*:\s*[0-9]\+/"jovian_time": null/' "$L2_DIR/rollup.json" || true
  sed -i '' 's/"interop_time"\s*:\s*[0-9]\+/"interop_time": null/' "$L2_DIR/rollup.json" || true
fi

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
  --rollup.l1-chain-config="$L1CFG" \
  --sequencer.enabled \
  --ignore-missing-pectra-blob-schedule \
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
