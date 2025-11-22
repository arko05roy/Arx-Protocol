# Arx Protocol - OP Stack Rollup on Celo Sepolia

## Overview

This is a **Layer 2 rollup** built on the OP Stack framework, settling to **Celo Sepolia** (testnet). The rollup uses a single centralized sequencer to process transactions and batch them to Celo Sepolia as the Layer 1 settlement layer.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│      Your L2 Rollup (Chain ID: 424242)          │
│                                                  │
│  • op-geth (execution layer)                    │
│  • op-batcher (posts batches to L1)             │
│  • op-proposer (posts state roots to L1)        │
│  • Single sequencer (centralized)               │
└─────────────────┬───────────────────────────────┘
                  │ Settles to
                  ▼
┌─────────────────────────────────────────────────┐
│    Celo Sepolia L1 (Chain ID: 11142220)         │
│                                                  │
│  • OptimismPortal (withdrawals)                 │
│  • SystemConfig (rollup config)                 │
│  • L1StandardBridge (asset bridge)              │
│  • DisputeGameFactory (fault proofs)            │
└─────────────────────────────────────────────────┘
```

---

## ✅ Batch Visibility on Celo Sepolia Explorer

**Your transaction batches WILL be publicly visible!**

Every batch your L2 submits to Celo Sepolia L1 will appear as a transaction on the public Celo Sepolia blockchain explorer.

**🔗 View Your Batches Here:**
```
https://sepolia.celoscan.io/address/0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62
```

**What you'll see:**
- ✅ All batch transactions submitted to Celo Sepolia
- ✅ Transaction hashes, timestamps, and gas used
- ✅ Calldata containing compressed L2 blocks
- ✅ Proof of data availability on L1

**Perfect for demos and showing others!** Each transaction represents a batch of L2 blocks being posted to L1 for data availability and finality.

📖 **Full Guide:** See [VERIFY_BATCHES_ON_CELO_SEPOLIA.md](VERIFY_BATCHES_ON_CELO_SEPOLIA.md) for detailed instructions.

---

## 📋 Quick Start

### Prerequisites

- [x] Docker installed
- [x] Node.js v18+ installed
- [x] Foundry (cast) installed: https://book.getfoundry.sh
- [x] Celo Sepolia testnet CELO for accounts

### 1. Fund Your Accounts

**🚀 ULTRA-OPTIMIZED FOR MINIMAL COST - Works with ANY Faucet!**

**Required accounts on Celo Sepolia:**
- **Batcher** (`0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62`): **0.3-0.5 CELO** ✅
- **Proposer** (`0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47`): **0.1-0.2 CELO** ✅

**Total: Just 0.5-1 CELO!** (Can last for MONTHS! 🎉)

Get testnet CELO from: https://faucet.celo.org

**Check balances:**
```bash
cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://rpc.ankr.com/celo_sepolia
cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 --rpc-url https://rpc.ankr.com/celo_sepolia
```

See: **[ACCOUNT_FUNDING_GUIDE.md](ACCOUNT_FUNDING_GUIDE.md)** for details.

### 2. Start the Sequencer

```bash
cd l2-deployment
./START_L3_COMPLETE.sh
```

This starts all services:
- ✅ op-geth (L2 execution)
- ✅ op-batcher (batch submitter)
- ✅ op-proposer (state root proposer)
- ✅ RPC proxy (rollup RPC)

### 3. Monitor the Sequencer

```bash
cd l2-deployment
./MONITOR.sh
```

**Live dashboard shows:**
- 🔧 Service status
- 💰 L1 account balances (with low balance alerts)
- 📈 L2 blockchain stats
- 🌐 Network connectivity
- 📝 Recent log activity

### 4. Verify L2 is Working

```bash
# Check L2 block number (should be increasing)
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Check L2 chain ID (should return 0x67932 = 424242)
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[ULTRA_LOW_COST_SETUP.md](ULTRA_LOW_COST_SETUP.md)** | 🚀 **START HERE: Ultra-optimized for 0.5-1 CELO total!** |
| **[VERIFY_BATCHES_ON_CELO_SEPOLIA.md](VERIFY_BATCHES_ON_CELO_SEPOLIA.md)** | ⭐ **How to see your batches on Celo Sepolia Explorer** |
| **[LOW_COST_TESTNET_SETUP.md](LOW_COST_TESTNET_SETUP.md)** | Previous optimization (2-3 CELO) |
| **[ACCOUNT_FUNDING_GUIDE.md](ACCOUNT_FUNDING_GUIDE.md)** | Which accounts need funding and how much |
| **[OPERATIONS_RUNBOOK.md](OPERATIONS_RUNBOOK.md)** | Complete operational guide (start/stop/troubleshoot) |
| **[CONFIG_VERIFICATION_SUMMARY.md](CONFIG_VERIFICATION_SUMMARY.md)** | Verification of all configuration files |
| **[CELO_MAINNET_MIGRATION_PLAN.md](CELO_MAINNET_MIGRATION_PLAN.md)** | How to migrate to Celo Mainnet |

---

## 🔑 Accounts & Roles

| Role | Address | Purpose | Needs L1 Funds? |
|------|---------|---------|-----------------|
| **Admin** | `0x89a26...BbE65` | System owner, fee recipient | Sometimes |
| **Batcher** | `0xd9fC5...00f62` | Submits batches to Celo Sepolia | ✅ YES (most) |
| **Proposer** | `0x79BF8...6Ed47` | Submits state roots to L1 | ✅ YES |
| **Sequencer** | `0xB24e7...0E49` | Signs L2 blocks | ❌ NO |

⚠️ **Security:** Private keys are in `.envrc.celo-sepolia` which is **gitignored**.

---

## 🌐 Network Details

### L1 (Celo Sepolia)

- **Chain ID:** 11142220
- **RPC:** https://rpc.ankr.com/celo_sepolia
- **Block Time:** 5 seconds
- **Explorer:** https://sepolia.celoscan.io

### L2 (Your Rollup)

- **Chain ID:** 424242
- **RPC:** http://localhost:8545 (HTTP), ws://localhost:8546 (WebSocket)
- **Block Time:** 2 seconds
- **Rollup RPC:** http://localhost:9545

---

## 📦 Deployed L1 Contracts

| Contract | Address | Purpose |
|----------|---------|---------|
| **OptimismPortalProxy** | `0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1` | Deposits & withdrawals |
| **SystemConfigProxy** | `0xC7D71BC3bF37C129fa12c81377B8566661435a96` | Rollup configuration |
| **L1StandardBridgeProxy** | `0x022B27F7F11Ce7841b53E8E00735C62c10B56dB6` | Asset bridge |
| **DisputeGameFactoryProxy** | `0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e` | Fault proofs |

Full list: `l2-deployment/addresses.json`

---

## 🚀 Common Commands

### Start Services

```bash
cd l2-deployment
./START_L3_COMPLETE.sh
```

### Stop Services

```bash
cd l2-deployment
./STOP_L3.sh
```

### Monitor Live

```bash
cd l2-deployment
./MONITOR.sh
```

### Check Logs

```bash
# Batcher
tail -f l2-deployment/logs/op-batcher.log

# Proposer
tail -f l2-deployment/logs/op-proposer.log

# op-geth
docker logs -f celo-l3-geth
```

### Check Account Balances

```bash
# All at once
./check-balances.sh

# Individual
cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://rpc.ankr.com/celo_sepolia
```

---

## 🔧 Troubleshooting

### Services Won't Start

**Check Docker:**
```bash
docker ps
docker logs celo-l3-geth
```

**Check Ports:**
```bash
lsof -i :8545  # L2 RPC
lsof -i :9545  # Rollup RPC
```

### Batcher Not Submitting

**Common causes:**
1. Insufficient funds (check balance)
2. L1 RPC connection issue
3. L2 RPC not reachable

**Solution:**
```bash
# Check batcher balance
cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://rpc.ankr.com/celo_sepolia

# Check logs
tail -f l2-deployment/logs/op-batcher.log
```

### Proposer Not Submitting

**Common causes:**
1. Insufficient funds
2. Proposal interval not reached
3. Incorrect game factory address

**Solution:**
```bash
# Check proposer balance
cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 --rpc-url https://rpc.ankr.com/celo_sepolia

# Check logs
tail -f l2-deployment/logs/op-proposer.log
```

**See:** [OPERATIONS_RUNBOOK.md](OPERATIONS_RUNBOOK.md) for complete troubleshooting guide.

---

## 🔐 Security

### ✅ What We've Secured

- [x] Private keys removed from git tracking
- [x] `.envrc.celo-sepolia` gitignored
- [x] JWT secrets gitignored
- [x] All `.env` files gitignored
- [x] Using separate testnet keys (not reused elsewhere)

### ⚠️ Before Mainnet

- [ ] Generate NEW wallets (never use testnet keys on mainnet!)
- [ ] Use hardware wallets for admin accounts
- [ ] Store keys in secrets manager (not .envrc files)
- [ ] Enable multi-sig for admin operations
- [ ] Set up automated monitoring & alerts
- [ ] Complete security audit

---

## 💰 Cost Estimates

### Testnet (Celo Sepolia)

**Free!** Just need testnet CELO from faucet.

### Mainnet (Celo Mainnet)

**One-time deployment:** 50-100 CELO (~$50-100 USD)

**Monthly operational costs:**
- Batcher: 150-600 CELO/month
- Proposer: 30-150 CELO/month
- **Total:** ~$200-800 USD/month

**Depends on:**
- L2 transaction volume
- L1 gas prices
- Batch/proposal frequency

See: [ACCOUNT_FUNDING_GUIDE.md](ACCOUNT_FUNDING_GUIDE.md) for cost optimization strategies.

---

## 🛣️ Roadmap

### Current: Celo Sepolia Testnet ✅

- [x] L1 contracts deployed
- [x] Genesis configuration generated
- [x] Sequencer configured
- [x] Documentation complete

### Next: Production Readiness

- [ ] Fund accounts with testnet CELO
- [ ] Start and test sequencer
- [ ] Test deposits (L1 → L2)
- [ ] Test withdrawals (L2 → L1)
- [ ] Monitor for 24-48 hours
- [ ] Stress test with transactions

### Future: Celo Mainnet Migration

- [ ] Generate production wallets
- [ ] Fund with mainnet CELO
- [ ] Deploy L1 contracts to Celo Mainnet
- [ ] Generate mainnet genesis
- [ ] Start production sequencer
- [ ] Announce publicly

See: [CELO_MAINNET_MIGRATION_PLAN.md](CELO_MAINNET_MIGRATION_PLAN.md)

---

## 🤔 FAQ

### Can I use a managed RaaS provider instead of self-hosting?

**No, not for Celo L1.** No major RaaS providers (Caldera, Conduit, Gelato, AltLayer) support Celo as a custom L1 settlement layer. They only support Ethereum mainnet/testnet.

**Options:**
1. Continue self-hosting (current setup)
2. Migrate to Ethereum L2 and use RaaS
3. Build L3 on Celo L2 (when shared sequencers are ready)

### Can I run the sequencer on Cloudflare Workers?

**No.** Cloudflare Workers cannot run stateful services like op-geth or op-node. The sequencer needs:
- Persistent database (blockchain state)
- Long-running processes
- Engine API (authenticated RPC)

**Use instead:** VPS (AWS, GCP, DigitalOcean), Kubernetes, or bare metal server.

### How do I migrate to Celo Mainnet?

See: **[CELO_MAINNET_MIGRATION_PLAN.md](CELO_MAINNET_MIGRATION_PLAN.md)**

**TL;DR:**
1. Create new wallets (don't reuse testnet keys!)
2. Update `.envrc.celo-mainnet`
3. Deploy L1 contracts to Celo Mainnet (Chain ID: 42220)
4. Generate new genesis
5. Start sequencer with mainnet config

### What if batcher/proposer runs out of funds?

**Impact:**
- L2 continues producing blocks locally
- Batches stop being posted to L1
- State roots stop being posted to L1
- Withdrawals can't finalize

**Solution:** Refill the account ASAP. Services will auto-resume.

**Prevention:** Set up balance monitoring alerts (see MONITOR.sh).

---

## 📞 Support & Resources

**Documentation:**
- Optimism Docs: https://docs.optimism.io
- OP Stack Specs: https://specs.optimism.io
- Celo Docs: https://docs.celo.org

**Community:**
- Optimism Discord: https://discord.optimism.io
- Celo Discord: https://discord.gg/celo

**Tools:**
- Foundry (cast): https://book.getfoundry.sh
- Celo Sepolia Explorer: https://sepolia.celoscan.io

---

## 📝 License

[Your license here]

---

## 🙏 Acknowledgments

Built on:
- [OP Stack](https://stack.optimism.io/) by Optimism
- [Celo](https://celo.org/) blockchain
- [Foundry](https://book.getfoundry.sh/) toolchain

---

**Status:** ✅ **READY FOR TESTING**

Start your sequencer and build on your L2! 🚀
