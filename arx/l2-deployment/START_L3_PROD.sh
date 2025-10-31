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
# Build Bedrock contracts (needed for forge-artifacts)
# Note: contracts-bedrock is a Foundry project, not Node.js, so no pnpm install needed
(cd "$BEDROCK_DIR" && forge build)

# Build a small generator to emit full L2 allocs with predeploy code + user premints
GEN_SRC="$L2_DIR/cmd-allocs-gen.go"
cat > "$GEN_SRC" << 'EOF'
package main

import (
    "encoding/json"
    "fmt"
    "math/big"
    "os"
    "path/filepath"
    "strings"
    "github.com/ethereum/go-ethereum/common"
)

type ForgeAllocAccount struct {
    Balance string            `json:"balance,omitempty"`
    Nonce   string            `json:"nonce,omitempty"`
    Code    string            `json:"code,omitempty"`
    Storage map[string]string `json:"storage,omitempty"`
}
type ForgeAllocs map[string]ForgeAllocAccount

type DeployedBytecode struct {
    Object string `json:"object"`
}

type Artifact struct {
    DeployedBytecode DeployedBytecode `json:"deployedBytecode"`
}

func must(err error) { if err != nil { panic(err) } }

func readArtifactBytecode(root, subdir, contract string) string {
    p := filepath.Join(root, "forge-artifacts", subdir, contract+".json")
    b, err := os.ReadFile(p); must(err)
    var a Artifact
    must(json.Unmarshal(b, &a))
    bytecode := a.DeployedBytecode.Object
    if !strings.HasPrefix(bytecode, "0x") {
        bytecode = "0x" + bytecode
    }
    return strings.ToLower(bytecode)
}

func main() {
    bedrock := "/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/packages/contracts-bedrock"
    allocs := ForgeAllocs{}
    // Core subset of predeploys sufficient for genesis validation
    // Address map (name -> address) derived from Predeploys.sol
    pre := map[string]string{
        // All predeploys required by op-node
        "LEGACY_MESSAGE_PASSER":   "0x4200000000000000000000000000000000000000",
        "L1_MESSAGE_SENDER":       "0x4200000000000000000000000000000000000001",
        "DEPLOYER_WHITELIST":      "0x4200000000000000000000000000000000000002",
        "WETH":                    "0x4200000000000000000000000000000000000006",
        "L2_CROSS_DOMAIN_MESSENGER": "0x4200000000000000000000000000000000000007",
        "GAS_PRICE_ORACLE":        "0x420000000000000000000000000000000000000F",
        "L2_STANDARD_BRIDGE":      "0x4200000000000000000000000000000000000010",
        "SEQUENCER_FEE_VAULT":     "0x4200000000000000000000000000000000000011",
        "OPTIMISM_MINTABLE_ERC20_FACTORY": "0x4200000000000000000000000000000000000012",
        "L1_BLOCK_NUMBER":         "0x4200000000000000000000000000000000000013",
        "L2_ERC721_BRIDGE":        "0x4200000000000000000000000000000000000014",
        "L1_BLOCK_ATTRIBUTES":     "0x4200000000000000000000000000000000000015",
        "L2_TO_L1_MESSAGE_PASSER": "0x4200000000000000000000000000000000000016",
        "OPTIMISM_MINTABLE_ERC721_FACTORY": "0x4200000000000000000000000000000000000017",
        "PROXY_ADMIN":             "0x4200000000000000000000000000000000000018",
        "BASE_FEE_VAULT":          "0x4200000000000000000000000000000000000019",
        "L1_FEE_VAULT":            "0x420000000000000000000000000000000000001A",
        "OPERATOR_FEE_VAULT":      "0x420000000000000000000000000000000000001b",
        "SCHEMA_REGISTRY":         "0x4200000000000000000000000000000000000020",
        "EAS":                     "0x4200000000000000000000000000000000000021",
        "CROSS_L2_INBOX":          "0x4200000000000000000000000000000000000022",
        "L2_TO_L2_CROSS_DOMAIN_MESSENGER": "0x4200000000000000000000000000000000000023",
        "SUPERCHAIN_ETH_BRIDGE":   "0x4200000000000000000000000000000000000024",
        "ETH_LIQUIDITY":           "0x4200000000000000000000000000000000000025",
        "OPTIMISM_SUPERCHAIN_ERC20_FACTORY": "0x4200000000000000000000000000000000000026",
        "OPTIMISM_SUPERCHAIN_ERC20_BEACON": "0x4200000000000000000000000000000000000027",
        "SUPERCHAIN_TOKEN_BRIDGE": "0x4200000000000000000000000000000000000028",
        "GOVERNANCE_TOKEN":        "0x4200000000000000000000000000000000000042",
    }
    // Map predeploy names to artifact locations (sol filename, contract name)
    art := map[string][2]string{
        "LEGACY_MESSAGE_PASSER":   {"LegacyMessagePasser.sol", "LegacyMessagePasser"},
        "DEPLOYER_WHITELIST":      {"DeployerWhitelist.sol", "DeployerWhitelist"},
        "WETH":                    {"WETH.sol", "WETH"},
        "L2_CROSS_DOMAIN_MESSENGER": {"L2CrossDomainMessenger.sol", "L2CrossDomainMessenger"},
        "GAS_PRICE_ORACLE":        {"GasPriceOracle.sol", "GasPriceOracle"},
        "L2_STANDARD_BRIDGE":      {"L2StandardBridge.sol", "L2StandardBridge"},
        "SEQUENCER_FEE_VAULT":     {"SequencerFeeVault.sol", "SequencerFeeVault"},
        "OPTIMISM_MINTABLE_ERC20_FACTORY": {"OptimismMintableERC20Factory.sol", "OptimismMintableERC20Factory"},
        "L1_BLOCK_NUMBER":         {"L1BlockNumber.sol", "L1BlockNumber"},
        "L2_ERC721_BRIDGE":        {"L2ERC721Bridge.sol", "L2ERC721Bridge"},
        "L1_BLOCK_ATTRIBUTES":     {"L1Block.sol", "L1Block"},
        "L2_TO_L1_MESSAGE_PASSER": {"L2ToL1MessagePasser.sol", "L2ToL1MessagePasser"},
        "OPTIMISM_MINTABLE_ERC721_FACTORY": {"OptimismMintableERC721Factory.sol", "OptimismMintableERC721Factory"},
        "PROXY_ADMIN":             {"ProxyAdmin.sol", "ProxyAdmin"},
        "BASE_FEE_VAULT":          {"BaseFeeVault.sol", "BaseFeeVault"},
        "L1_FEE_VAULT":            {"L1FeeVault.sol", "L1FeeVault"},
        "OPERATOR_FEE_VAULT":      {"OperatorFeeVault.sol", "OperatorFeeVault"},
        "SCHEMA_REGISTRY":         {"SchemaRegistry.sol", "SchemaRegistry"},
        "EAS":                     {"EAS.sol", "EAS"},
        "GOVERNANCE_TOKEN":        {"GovernanceToken.sol", "GovernanceToken"},
        "CROSS_L2_INBOX":          {"CrossL2Inbox.sol", "CrossL2Inbox"},
        "L2_TO_L2_CROSS_DOMAIN_MESSENGER": {"L2ToL2CrossDomainMessenger.sol", "L2ToL2CrossDomainMessenger"},
        "SUPERCHAIN_ETH_BRIDGE":   {"SuperchainEthBridge.sol", "SuperchainEthBridge"},
        "ETH_LIQUIDITY":           {"EthLiquidity.sol", "EthLiquidity"},
        "OPTIMISM_SUPERCHAIN_ERC20_FACTORY": {"OptimismSuperchainERC20Factory.sol", "OptimismSuperchainERC20Factory"},
        "OPTIMISM_SUPERCHAIN_ERC20_BEACON": {"OptimismSuperchainERC20Beacon.sol", "OptimismSuperchainERC20Beacon"},
        "SUPERCHAIN_TOKEN_BRIDGE": {"SuperchainTokenBridge.sol", "SuperchainTokenBridge"},
    }
    for name, addr := range pre {
        m := ForgeAllocAccount{Balance: "0x0", Nonce: "0x0"}
        if a, ok := art[name]; ok {
            m.Code = readArtifactBytecode(bedrock, a[0], a[1])
        } else {
            // Predeploys without artifacts get minimal bytecode (contract that returns empty)
            // This is: PUSH1 0x00 PUSH1 0x00 RETURN (0x6000f3)
            m.Code = "0x6000f3"
        }
        allocs[addr] = m
    }
    // Fill in all predeploys from 0x4200000000000000000000000000000000000000 to 0x42000000000000000000000000000000000007ff
    // with minimal bytecode if not already present
    l2PredeployNamespace := new(big.Int)
    l2PredeployNamespace.SetString("4200000000000000000000000000000000000000", 16)
    for i := 0; i < 2048; i++ {
        addr := common.BigToAddress(new(big.Int).Or(l2PredeployNamespace, big.NewInt(int64(i))))
        addrStr := strings.ToLower(addr.Hex())
        if _, exists := allocs[addrStr]; !exists {
            allocs[addrStr] = ForgeAllocAccount{Balance: "0x0", Nonce: "0x0", Code: "0x6000f3"}
        }
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
pkill -9 -f "op-node/bin/op-node" 2>/dev/null || true
pkill -9 -f "op-batcher/bin/op-batcher" 2>/dev/null || true
pkill -9 -f "op-proposer/bin/op-proposer" 2>/dev/null || true
pkill -9 -f "simple-rpc-proxy.js" 2>/dev/null || true
sleep 2
docker stop celo-l3-geth 2>/dev/null || true
sleep 1
docker rm -f celo-l3-geth 2>/dev/null || true
# Kill any remaining processes on the ports
lsof -ti:8545 | xargs kill -9 2>/dev/null || true
lsof -ti:8546 | xargs kill -9 2>/dev/null || true
lsof -ti:8551 | xargs kill -9 2>/dev/null || true
lsof -ti:9545 | xargs kill -9 2>/dev/null || true
sleep 2

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

sleep 10

# Wait for geth to be ready
echo "Waiting for op-geth to be ready..."
for i in {1..30}; do
  if curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' | grep -q "result"; then
    echo "op-geth is ready"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done

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

sleep 15

step "Start op-batcher"
nohup "$OP_ROOT/op-batcher/bin/op-batcher" \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c \
  --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7301 \
  > "$LOGS/op-batcher.log" 2>&1 &

sleep 10

# Skip op-proposer for now as it requires L1 contracts to be deployed
# step "Start op-proposer"
# nohup "$OP_ROOT/op-proposer/bin/op-proposer" \
#   --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
#   --rollup-rpc=http://localhost:9545 \
#   --game-factory-address=0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e \
#   --proposal-interval=1m \
#   --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 \
#   --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7302 \
#   > "$LOGS/op-proposer.log" 2>&1 &

sleep 5

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
