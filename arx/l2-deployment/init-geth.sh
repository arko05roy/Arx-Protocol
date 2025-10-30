#!/bin/bash

# Initialize op-geth with L2 genesis configuration

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
GETH_DATA="$DEPLOYMENT_DIR/geth-data"
GENESIS_FILE="$DEPLOYMENT_DIR/genesis.json"

echo "🔧 Initializing op-geth with L2 genesis..."
echo ""

# Create minimal genesis file for L2
cat > "$GENESIS_FILE" << 'EOF'
{
  "config": {
    "chainId": 424242,
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
    "shanghaiBlock": 0,
    "cancunBlock": 0,
    "terminalTotalDifficulty": 0,
    "terminalTotalDifficultyPassed": true,
    "optimismSuperchainHardforks": true
  },
  "difficulty": "0x0",
  "gasLimit": "0x1c9c380",
  "alloc": {
    "0x89a26a33747b293430D4269A59525d5D0D5BbE65": {
      "balance": "0x56bc75e2d630eb20000"
    },
    "0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62": {
      "balance": "0x56bc75e2d630eb20000"
    },
    "0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47": {
      "balance": "0x56bc75e2d630eb20000"
    },
    "0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49": {
      "balance": "0x56bc75e2d630eb20000"
    }
  }
}
EOF

echo "✅ Genesis file created: $GENESIS_FILE"
echo ""

# Stop existing container
echo "Stopping existing op-geth container..."
docker stop celo-l3-geth 2>/dev/null || true
docker rm celo-l3-geth 2>/dev/null || true
sleep 2

# Clean geth data
echo "Cleaning geth data directory..."
rm -rf "$GETH_DATA"/*
mkdir -p "$GETH_DATA"

# Initialize geth with genesis
echo "Initializing geth with genesis..."
docker run --rm \
  -v "$GETH_DATA:/geth-data" \
  -v "$GENESIS_FILE:/genesis.json:ro" \
  us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest \
  init --datadir=/geth-data /genesis.json

if [ $? -eq 0 ]; then
    echo "✅ Geth initialized successfully"
    echo ""
    echo "Starting op-geth container..."
    
    # Start op-geth with initialized data
    docker run -d \
      --name celo-l3-geth \
      -p 8545:8545 \
      -p 8546:8546 \
      -p 8551:8551 \
      -p 30303:30303 \
      -v "$GETH_DATA:/geth-data" \
      -v "$DEPLOYMENT_DIR/jwt-secret.txt:/jwt-secret.txt:ro" \
      us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest \
      --datadir=/geth-data \
      --http \
      --http.addr=0.0.0.0 \
      --http.port=8545 \
      --http.api=web3,eth,debug,net,engine \
      --http.corsdomain="*" \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.port=8546 \
      --ws.api=web3,eth,debug,net,engine \
      --ws.origins="*" \
      --authrpc.addr=0.0.0.0 \
      --authrpc.port=8551 \
      --authrpc.jwtsecret=/jwt-secret.txt \
      --authrpc.vhosts="*" \
      --syncmode=full \
      --maxpeers=0 \
      --networkid=424242 \
      --nodiscover \
      --rollup.disabletxpoolgossip \
      --rollup.sequencerhttp=http://localhost:8545
    
    if [ $? -eq 0 ]; then
        echo "✅ op-geth container started"
        echo ""
        echo "Waiting for geth to start..."
        sleep 5
        
        echo "Testing connectivity..."
        CHAIN_ID=$(curl -s -X POST http://localhost:8545 \
          -H "Content-Type: application/json" \
          -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' | jq -r '.result' 2>/dev/null || echo "error")
        
        if [ "$CHAIN_ID" = "0x67a2e" ]; then
            echo "✅ op-geth responding with correct chain ID (424242)"
        else
            echo "⚠️  Chain ID: $CHAIN_ID (expected: 0x67a2e)"
        fi
    else
        echo "❌ Failed to start op-geth container"
        exit 1
    fi
else
    echo "❌ Failed to initialize geth"
    exit 1
fi

echo ""
echo "✅ op-geth initialization complete!"
echo ""
echo "Endpoints:"
echo "  HTTP RPC:    http://localhost:8545"
echo "  WebSocket:   ws://localhost:8546"
echo "  Engine RPC:  http://localhost:8551"
