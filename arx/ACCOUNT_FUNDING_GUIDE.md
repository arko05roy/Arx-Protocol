# Account Funding Guide

## Overview

This document explains which accounts need funding, how much, and what they're used for in your OP Stack rollup deployment.

---

## Account Summary

| Account | Address | Needs L1 Funds? | Role |
|---------|---------|-----------------|------|
| **Admin** | `0x89a26a33747b293430D4269A59525d5D0D5BbE65` | ⚠️ Sometimes | System owner, challenger, fee recipient |
| **Batcher** | `0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62` | ✅ YES (Most) | Submits transaction batches to L1 |
| **Proposer** | `0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47` | ✅ YES | Submits state root proposals to L1 |
| **Sequencer** | `0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49` | ❌ NO | Signs L2 blocks (no L1 txns) |

---

## Celo Sepolia (Testnet) Funding Requirements

### 1. Batcher Account: `0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62`

**Required Balance:** 10-50 CELO (testnet)

**Purpose:**
- Submits compressed batches of L2 transactions to Celo Sepolia L1
- Most active account - sends transactions continuously

**Transaction Frequency:**
- Every 1-5 minutes (depending on L2 activity)
- High frequency = high gas costs

**Monitoring:**
```bash
# Check balance
cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://rpc.ankr.com/celo_sepolia

# Monitor transactions
cast tx-count 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://rpc.ankr.com/celo_sepolia
```

**Refill When:** Balance drops below 5 CELO

---

### 2. Proposer Account: `0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47`

**Required Balance:** 5-20 CELO (testnet)

**Purpose:**
- Submits state root proposals to L1 DisputeGameFactory
- Enables withdrawal finalization

**Transaction Frequency:**
- Every 1-2 minutes (per your config: 60 second interval)
- Medium frequency

**Monitoring:**
```bash
# Check balance
cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 --rpc-url https://rpc.ankr.com/celo_sepolia

# Check latest proposal
# (View transactions on Celo Sepolia explorer)
```

**Refill When:** Balance drops below 3 CELO

---

### 3. Admin Account: `0x89a26a33747b293430D4269A59525d5D0D5BbE65`

**Required Balance:** 1-5 CELO (testnet)

**Purpose:**
- System owner (can upgrade contracts)
- Challenger (can dispute invalid state roots)
- Fee vault recipient (receives collected fees)
- Used for occasional admin operations

**Transaction Frequency:**
- Infrequent (only for admin tasks, upgrades, or disputes)

**Monitoring:**
```bash
# Check balance
cast balance 0x89a26a33747b293430D4269A59525d5D0D5BbE65 --rpc-url https://rpc.ankr.com/celo_sepolia
```

**Refill When:** Balance drops below 0.5 CELO

---

### 4. Sequencer Account: `0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49`

**Required L1 Balance:** 0 CELO

**Purpose:**
- Signs L2 blocks (operates only on L2, not L1)
- P2P sequencer address
- Receives sequencer fee vault funds on L2

**Why No L1 Funding Needed:**
- Only signs L2 blocks via op-geth
- Does not submit any transactions to L1
- All L1 operations handled by Batcher and Proposer

**Note:** This account may receive L2 fees, but doesn't need L1 funds.

---

## Celo Mainnet (Production) Funding Requirements

### Deployment Phase

**Deployer Account** (one-time):
- **Required:** 50-100 CELO
- **Purpose:** Deploy ~24 L1 smart contracts
- **When:** Only during initial mainnet deployment

### Operational Phase (Ongoing)

| Account | Monthly Estimate | Purpose |
|---------|------------------|---------|
| **Batcher** | 150-600 CELO/month | Continuous batch submissions |
| **Proposer** | 30-150 CELO/month | State root proposals every 2 min |
| **Admin** | 5-10 CELO | Occasional admin operations |

**Total Operational Cost:** ~$200-800 USD/month (at current CELO prices)

**Factors Affecting Costs:**
- L2 transaction volume (more txns = more batches)
- L1 gas prices on Celo
- Batch compression efficiency
- Proposal frequency

---

## How to Fund Accounts

### Testnet (Celo Sepolia)

**Option 1: Celo Faucet**
```bash
# Visit Celo faucet (if available)
# https://faucet.celo.org
# Enter your address
```

**Option 2: Transfer from Funded Account**
```bash
# If you have a funded wallet, transfer to accounts
cast send 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 \
  --value 10ether \
  --rpc-url https://rpc.ankr.com/celo_sepolia \
  --private-key <your-funded-wallet-key>
```

### Mainnet (Celo Mainnet)

**Purchase CELO:**
1. Buy CELO on exchange (Coinbase, Binance, etc.)
2. Withdraw to your wallet addresses
3. Distribute to operational accounts

**Recommended Distribution:**
- Batcher: 100 CELO initial (refill monthly)
- Proposer: 50 CELO initial (refill monthly)
- Admin: 10 CELO initial

---

## Monitoring & Alerts

### Set Up Balance Monitoring

Create a simple monitoring script:

```bash
#!/bin/bash
# monitor-balances.sh

RPC="https://rpc.ankr.com/celo_sepolia"
MIN_BATCHER=5000000000000000000  # 5 CELO in wei
MIN_PROPOSER=3000000000000000000 # 3 CELO in wei

BATCHER_BAL=$(cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url $RPC)
PROPOSER_BAL=$(cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 --rpc-url $RPC)

if [ "$BATCHER_BAL" -lt "$MIN_BATCHER" ]; then
  echo "⚠️  ALERT: Batcher balance low! Current: $(cast --to-unit $BATCHER_BAL ether) CELO"
fi

if [ "$PROPOSER_BAL" -lt "$MIN_PROPOSER" ]; then
  echo "⚠️  ALERT: Proposer balance low! Current: $(cast --to-unit $PROPOSER_BAL ether) CELO"
fi
```

### Automated Refilling (Advanced)

Consider setting up automated refilling:
- Use a separate "treasury" account with larger balance
- Create script that monitors accounts and auto-refills when low
- Use safe multi-sig for treasury account security

---

## Cost Optimization Strategies

### Reduce Batcher Costs
1. **Increase batch submission interval** (less frequent batches)
   - Edit: `op-batcher.env` → `OP_BATCHER_MAX_CHANNEL_DURATION`
   - Trade-off: Slower L1 finality

2. **Improve compression**
   - Edit: `op-batcher.env` → `OP_BATCHER_APPROX_COMPR_RATIO`
   - Better compression = smaller calldata = lower gas

3. **Increase batch size**
   - Edit: `op-batcher.env` → `OP_BATCHER_TARGET_L1_TX_SIZE_BYTES`
   - Larger batches = fewer transactions

### Reduce Proposer Costs
1. **Increase proposal interval**
   - Edit: `op-proposer.env` → `OP_PROPOSER_PROPOSAL_INTERVAL`
   - Trade-off: Slower withdrawal finalization

---

## Emergency Procedures

### If Batcher Runs Out of Funds
**Impact:** L2 transactions won't be posted to L1 (batches stop)
**L2 Status:** Continues producing blocks locally
**Fix:** Refill batcher wallet ASAP

### If Proposer Runs Out of Funds
**Impact:** State roots won't be proposed to L1
**L2 Status:** Continues operating normally
**Withdrawal Impact:** Withdrawals can't finalize
**Fix:** Refill proposer wallet

### If Both Run Out
**Impact:** L2 becomes "disconnected" from L1
**Data:** L2 data is safe, just not being posted
**Recovery:** Refill wallets and services will automatically resume

---

## Security Best Practices

### Testnet
✅ Use separate accounts from mainnet
✅ Keep private keys in `.envrc.celo-sepolia` (gitignored)
✅ Never use testnet keys on mainnet

### Mainnet
✅ Use hardware wallets for admin/owner accounts
✅ Use fresh addresses (never used elsewhere)
✅ Store keys in secure secrets manager (1Password, AWS Secrets Manager)
✅ Enable multi-sig for admin operations (advanced)
✅ Keep batcher/proposer keys on secure servers only
✅ Regular security audits

---

## Quick Reference

### Check All Balances (Testnet)
```bash
echo "Batcher:  $(cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://rpc.ankr.com/celo_sepolia | cast --to-unit - ether) CELO"
echo "Proposer: $(cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 --rpc-url https://rpc.ankr.com/celo_sepolia | cast --to-unit - ether) CELO"
echo "Admin:    $(cast balance 0x89a26a33747b293430D4269A59525d5D0D5BbE65 --rpc-url https://rpc.ankr.com/celo_sepolia | cast --to-unit - ether) CELO"
```

### Check All Balances (Mainnet)
```bash
echo "Batcher:  $(cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://forno.celo.org | cast --to-unit - ether) CELO"
echo "Proposer: $(cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 --rpc-url https://forno.celo.org | cast --to-unit - ether) CELO"
echo "Admin:    $(cast balance 0x89a26a33747b293430D4269A59525d5D0D5BbE65 --rpc-url https://forno.celo.org | cast --to-unit - ether) CELO"
```

### Get Testnet CELO Faucet
- Celo Faucet: https://faucet.celo.org
- Alternative: Ask in Celo Discord

---

## Summary

**For Current Celo Sepolia Testnet:**
1. Fund Batcher with 10-50 testnet CELO ✅
2. Fund Proposer with 5-20 testnet CELO ✅
3. Fund Admin with 1-5 testnet CELO (optional) ⚠️
4. Sequencer needs 0 L1 funds ❌

**Monitor these accounts weekly and refill when low.**
