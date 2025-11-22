#!/bin/bash

# Quick script to check all L1 account balances on Celo Sepolia

L1_RPC="https://rpc.ankr.com/celo_sepolia"

BATCHER_ADDR="0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62"
PROPOSER_ADDR="0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47"
ADMIN_ADDR="0x89a26a33747b293430D4269A59525d5D0D5BbE65"
SEQUENCER_ADDR="0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49"

echo "════════════════════════════════════════════════════════"
echo "💰 L1 Account Balances (Celo Sepolia)"
echo "════════════════════════════════════════════════════════"
echo ""

# Check if cast is installed
if ! command -v cast &> /dev/null; then
    echo "❌ Error: 'cast' not found"
    echo "   Install Foundry: https://book.getfoundry.sh/getting-started/installation"
    exit 1
fi

# Batcher
echo "🔄 Batcher Account"
echo "   Address: $BATCHER_ADDR"
BATCHER_BAL=$(cast balance $BATCHER_ADDR --rpc-url $L1_RPC 2>/dev/null)
if [ $? -eq 0 ]; then
    BATCHER_ETH=$(cast --to-unit $BATCHER_BAL ether 2>/dev/null)
    if (( $(echo "$BATCHER_BAL < 100000000000000000" | bc -l) )); then
        echo "   ⚠️  Balance: $BATCHER_ETH CELO (LOW - REFILL NEEDED!)"
    else
        echo "   ✅ Balance: $BATCHER_ETH CELO"
    fi
else
    echo "   ❌ Unable to fetch balance"
fi
echo ""

# Proposer
echo "📝 Proposer Account"
echo "   Address: $PROPOSER_ADDR"
PROPOSER_BAL=$(cast balance $PROPOSER_ADDR --rpc-url $L1_RPC 2>/dev/null)
if [ $? -eq 0 ]; then
    PROPOSER_ETH=$(cast --to-unit $PROPOSER_BAL ether 2>/dev/null)
    if (( $(echo "$PROPOSER_BAL < 50000000000000000" | bc -l) )); then
        echo "   ⚠️  Balance: $PROPOSER_ETH CELO (LOW - REFILL NEEDED!)"
    else
        echo "   ✅ Balance: $PROPOSER_ETH CELO"
    fi
else
    echo "   ❌ Unable to fetch balance"
fi
echo ""

# Admin
echo "🔐 Admin Account"
echo "   Address: $ADMIN_ADDR"
ADMIN_BAL=$(cast balance $ADMIN_ADDR --rpc-url $L1_RPC 2>/dev/null)
if [ $? -eq 0 ]; then
    ADMIN_ETH=$(cast --to-unit $ADMIN_BAL ether 2>/dev/null)
    echo "   ℹ️  Balance: $ADMIN_ETH CELO"
else
    echo "   ❌ Unable to fetch balance"
fi
echo ""

# Sequencer (shouldn't need L1 funds)
echo "⚡ Sequencer Account"
echo "   Address: $SEQUENCER_ADDR"
SEQUENCER_BAL=$(cast balance $SEQUENCER_ADDR --rpc-url $L1_RPC 2>/dev/null)
if [ $? -eq 0 ]; then
    SEQUENCER_ETH=$(cast --to-unit $SEQUENCER_BAL ether 2>/dev/null)
    echo "   ℹ️  Balance: $SEQUENCER_ETH CELO (not required for L1 ops)"
else
    echo "   ❌ Unable to fetch balance"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "💡 Need testnet CELO?"
echo "   • Celo Faucet: https://faucet.celo.org"
echo "   • Ask in Celo Discord: https://discord.gg/celo"
echo ""
echo "📖 More info: See ACCOUNT_FUNDING_GUIDE.md"
echo "════════════════════════════════════════════════════════"
