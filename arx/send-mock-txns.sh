#!/bin/bash
set -e

TEST_KEY="0x9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad"
RECIPIENT="0x89a26a33747b293430D4269A59525d5D0D5BbE65"
RPC_URL="http://localhost:8545"

echo "================================================"
echo "Sending 20 NEW transactions to L2..."
echo "================================================"
echo ""

TX_HASHES=()

for i in {1..20}; do
  echo "Sending transaction $i..."

  TX_HASH=$(cast send $RECIPIENT \
    --value 0.01ether \
    --private-key $TEST_KEY \
    --rpc-url $RPC_URL \
    --legacy 2>&1 | grep "transactionHash" | awk '{print $2}' || echo "FAILED")

  if [ "$TX_HASH" != "FAILED" ] && [ ! -z "$TX_HASH" ]; then
    echo "  ✅ TX $i: $TX_HASH"
    TX_HASHES+=("$TX_HASH")
  else
    echo "  ❌ TX $i: Failed to send"
  fi

  sleep 0.1
done

echo ""
echo "================================================"
echo "✅ Sent ${#TX_HASHES[@]} transactions successfully!"
echo "================================================"
echo ""
echo "Transaction hashes:"
for hash in "${TX_HASHES[@]}"; do
  echo "  $hash"
done
