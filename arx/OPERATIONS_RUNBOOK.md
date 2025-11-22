# OP Stack Rollup Operations Runbook

## Quick Reference

| Component | Command | Port | Health Check |
|-----------|---------|------|--------------|
| **op-geth** | Docker container `celo-l3-geth` | 8545 (HTTP), 8546 (WS), 8551 (Auth) | `curl -X POST http://localhost:8545 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'` |
| **op-batcher** | Background process | 7301 (metrics) | Check logs: `tail -f l2-deployment/logs/op-batcher.log` |
| **op-proposer** | Background process | 7302 (metrics) | Check logs: `tail -f l2-deployment/logs/op-proposer.log` |
| **RPC Proxy** | Node.js process | 9545 | `curl http://localhost:9545` |

---

## Starting the Sequencer Stack

### Complete Start (All Services)

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
./START_L3_COMPLETE.sh
```

This script starts:
1. op-geth (execution layer)
2. RPC proxy (rollup RPC for batcher/proposer)
3. op-batcher (batch submitter)
4. op-proposer (state root proposer)

### Individual Service Start

**Start op-geth only:**
```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
docker-compose up -d
# Or manually:
# docker start celo-l3-geth
```

**Start op-batcher:**
```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-batcher/bin
nohup ./op-batcher \
  --l1-eth-rpc https://rpc.ankr.com/celo_sepolia \
  --l2-eth-rpc http://localhost:8545 \
  --rollup-rpc http://localhost:9545 \
  --private-key <batcher-private-key> \
  > ~/logs/op-batcher.log 2>&1 &
```

**Start op-proposer:**
```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-proposer/bin
nohup ./op-proposer \
  --l1-eth-rpc https://rpc.ankr.com/celo_sepolia \
  --rollup-rpc http://localhost:9545 \
  --private-key <proposer-private-key> \
  --game-factory-address <game-factory-address> \
  > ~/logs/op-proposer.log 2>&1 &
```

---

## Stopping the Sequencer Stack

### Complete Stop (All Services)

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
./STOP_L3.sh
```

### Individual Service Stop

**Stop op-geth:**
```bash
docker stop celo-l3-geth
# Or docker-compose down
```

**Stop op-batcher:**
```bash
pkill -f "op-batcher/bin/op-batcher"
```

**Stop op-proposer:**
```bash
pkill -f "op-proposer/bin/op-proposer"
```

**Stop RPC proxy:**
```bash
pkill -f "simple-rpc-proxy.js"
```

---

## Monitoring

### Live Dashboard

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
./MONITOR.sh
```

**Shows:**
- Service status (running/stopped)
- L1 account balances with low balance alerts
- L2 blockchain stats (block number, gas price, balances)
- Network connectivity (L1 and L2 RPC)
- Recent log activity and errors

### Check Logs

**Batcher logs:**
```bash
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-batcher.log
```

**Proposer logs:**
```bash
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-proposer.log
```

**op-geth logs:**
```bash
docker logs -f celo-l3-geth
```

### Check Metrics

**op-batcher metrics:**
```bash
curl http://localhost:7301/metrics
```

**op-proposer metrics:**
```bash
curl http://localhost:7302/metrics
```

---

## Health Checks

### L2 RPC Health

```bash
# Check if L2 is producing blocks
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Check chain ID
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
# Should return: "0x67932" (424242 in hex)
```

### L1 Connectivity

```bash
# Check L1 RPC (Celo Sepolia)
curl -X POST https://rpc.ankr.com/celo_sepolia \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Account Balances

```bash
# Batcher balance (needs to be > 5 CELO)
cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 \
  --rpc-url https://rpc.ankr.com/celo_sepolia

# Proposer balance (needs to be > 3 CELO)
cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 \
  --rpc-url https://rpc.ankr.com/celo_sepolia

# Admin balance
cast balance 0x89a26a33747b293430D4269A59525d5D0D5BbE65 \
  --rpc-url https://rpc.ankr.com/celo_sepolia
```

---

## Common Issues & Solutions

### Issue: op-geth not producing blocks

**Symptoms:**
- `eth_blockNumber` returns same value repeatedly
- No new blocks in logs

**Diagnosis:**
```bash
docker logs celo-l3-geth | tail -50
```

**Possible Causes & Fixes:**

1. **JWT secret mismatch**
   ```bash
   # Verify JWT secret exists and matches
   cat /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/jwt-secret.txt
   # Ensure op-node/batcher/proposer use same JWT
   ```

2. **Database corruption**
   ```bash
   # Stop op-geth
   docker stop celo-l3-geth

   # Backup data
   cp -r l2-deployment/geth-data l2-deployment/geth-data.backup

   # Reinitialize (WARNING: loses state)
   # Only do this if you can re-sync from L1
   docker-compose down -v
   docker-compose up -d
   ```

3. **Sequencer not connected**
   ```bash
   # Check if op-node/RPC proxy is running
   ps aux | grep "simple-rpc-proxy.js"

   # Restart RPC proxy
   cd l2-deployment
   ./START_L3_COMPLETE.sh
   ```

---

### Issue: Batcher not submitting batches

**Symptoms:**
- Batcher logs show no activity
- No transactions from batcher address on Celo Sepolia

**Diagnosis:**
```bash
tail -f l2-deployment/logs/op-batcher.log
```

**Possible Causes & Fixes:**

1. **Insufficient funds**
   ```bash
   # Check batcher balance
   cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 \
     --rpc-url https://rpc.ankr.com/celo_sepolia

   # Fund if needed (use faucet or transfer)
   ```

2. **L1 RPC connection issues**
   ```bash
   # Test L1 RPC
   curl -X POST https://rpc.ankr.com/celo_sepolia \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

   # Try alternative RPC in op-batcher.env:
   # OP_BATCHER_L1_ETH_RPC=https://forno.celo.org
   ```

3. **L2 RPC not reachable**
   ```bash
   # Check L2 RPC from batcher's perspective
   curl http://localhost:8545

   # Verify op-geth is running
   docker ps | grep celo-l3-geth
   ```

4. **Nonce issues**
   ```bash
   # Check logs for "nonce too low" errors
   grep "nonce" l2-deployment/logs/op-batcher.log

   # If stuck, restart batcher (it will auto-recover nonce)
   pkill -f op-batcher
   # Then restart via START_L3_COMPLETE.sh
   ```

---

### Issue: Proposer not submitting state roots

**Symptoms:**
- Proposer logs show no proposals
- No transactions from proposer address on Celo Sepolia

**Diagnosis:**
```bash
tail -f l2-deployment/logs/op-proposer.log
```

**Possible Causes & Fixes:**

1. **Insufficient funds**
   ```bash
   # Check proposer balance
   cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 \
     --rpc-url https://rpc.ankr.com/celo_sepolia

   # Fund if needed
   ```

2. **Game factory address incorrect**
   ```bash
   # Verify game factory address in op-proposer.env matches deployment
   cat l2-deployment/addresses.json | jq '.DisputeGameFactoryProxy'

   # Should match OP_PROPOSER_GAME_FACTORY_ADDRESS in env
   ```

3. **Proposal interval not reached**
   ```bash
   # Check proposal interval in op-proposer.env
   # OP_PROPOSER_PROPOSAL_INTERVAL=60s

   # Wait for interval to pass before expecting proposals
   ```

---

### Issue: L2 RPC returns errors

**Symptoms:**
- RPC calls return errors
- `curl http://localhost:8545` fails

**Diagnosis:**
```bash
# Check if port is listening
lsof -i :8545

# Check op-geth status
docker ps | grep celo-l3-geth
docker logs celo-l3-geth | tail -50
```

**Possible Causes & Fixes:**

1. **op-geth not running**
   ```bash
   docker start celo-l3-geth
   # Or
   cd l2-deployment && docker-compose up -d
   ```

2. **Port conflict**
   ```bash
   # Check what's using port 8545
   lsof -i :8545

   # Kill conflicting process or change port in docker-compose.yml
   ```

3. **Firewall blocking**
   ```bash
   # Allow port 8545 (macOS example)
   # System Preferences > Security & Privacy > Firewall > Firewall Options
   ```

---

### Issue: High L1 gas costs

**Symptoms:**
- Batcher/proposer wallets draining quickly
- High gas fees on Celo Sepolia

**Optimization Strategies:**

1. **Increase batch submission interval**
   ```bash
   # Edit op-batcher.env
   # OP_BATCHER_MAX_CHANNEL_DURATION=1 → 5 (less frequent batches)

   # Restart batcher
   pkill -f op-batcher
   cd l2-deployment && ./START_L3_COMPLETE.sh
   ```

2. **Increase batch size**
   ```bash
   # Edit op-batcher.env
   # OP_BATCHER_TARGET_L1_TX_SIZE_BYTES=100000 → 120000
   ```

3. **Increase proposal interval**
   ```bash
   # Edit op-proposer.env
   # OP_PROPOSER_PROPOSAL_INTERVAL=60s → 120s (2 minutes)

   # Restart proposer
   pkill -f op-proposer
   cd l2-deployment && ./START_L3_COMPLETE.sh
   ```

---

## Backup & Recovery

### Backup L2 Data

```bash
# Stop op-geth
docker stop celo-l3-geth

# Backup geth data
tar -czf geth-data-backup-$(date +%Y%m%d).tar.gz \
  /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/geth-data

# Restart op-geth
docker start celo-l3-geth
```

### Backup Configuration

```bash
# Backup all config files
tar -czf config-backup-$(date +%Y%m%d).tar.gz \
  .envrc.celo-sepolia \
  l2-deployment/genesis.json \
  l2-deployment/rollup.json \
  l2-deployment/addresses.json \
  l2-deployment/op-batcher.env \
  l2-deployment/op-proposer.env \
  optimism/optimism/packages/contracts-bedrock/deploy-config/celo-sepolia.json
```

### Restore from Backup

```bash
# Stop all services
cd l2-deployment && ./STOP_L3.sh

# Restore geth data
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
rm -rf geth-data
tar -xzf geth-data-backup-YYYYMMDD.tar.gz

# Restore configs
tar -xzf config-backup-YYYYMMDD.tar.gz

# Restart services
./START_L3_COMPLETE.sh
```

### Re-sync from L1 (Last Resort)

If L2 data is corrupted and no backup available:

```bash
# Stop all services
./STOP_L3.sh

# Remove L2 data
rm -rf geth-data

# Reinitialize with genesis
docker-compose down -v
docker-compose up -d

# L2 will re-sync from L1 batches
# This may take time depending on chain history
```

---

## Upgrading Components

### Upgrade op-geth

```bash
# Stop op-geth
docker stop celo-l3-geth

# Pull latest image
docker pull us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest

# Restart
docker start celo-l3-geth
```

### Upgrade op-batcher / op-proposer

```bash
# Stop services
pkill -f op-batcher
pkill -f op-proposer

# Pull latest Optimism monorepo
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism
git pull origin main

# Rebuild binaries
cd op-batcher
make op-batcher

cd ../op-proposer
make op-proposer

# Restart services
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
./START_L3_COMPLETE.sh
```

---

## Security Checklist

### Before Mainnet Deployment

- [ ] Generate fresh wallet addresses (never used elsewhere)
- [ ] Use hardware wallets for admin/owner accounts
- [ ] Store private keys in secrets manager (not .envrc files)
- [ ] Enable 2FA on all infrastructure accounts
- [ ] Set up monitoring alerts for low balances
- [ ] Configure automated backups (daily)
- [ ] Test disaster recovery procedure
- [ ] Audit smart contract deployments
- [ ] Set up multi-sig for admin operations (recommended)
- [ ] Document emergency procedures
- [ ] Test withdrawal process end-to-end

### Ongoing Security

- [ ] Monitor account balances weekly
- [ ] Review logs for suspicious activity
- [ ] Keep op-stack software updated
- [ ] Rotate RPC endpoints if needed
- [ ] Audit permissions on contract proxies
- [ ] Monitor L1 transactions from batcher/proposer
- [ ] Set up alerts for failed transactions
- [ ] Backup L2 data regularly

---

## Performance Tuning

### Optimize for Low Latency

```bash
# Reduce L2 block time (in deploy config)
"l2BlockTime": 1  # 1 second blocks (default: 2)

# Increase batcher frequency
OP_BATCHER_POLL_INTERVAL=500ms  # Default: 1s
```

### Optimize for Low Cost

```bash
# Increase batch size
OP_BATCHER_TARGET_L1_TX_SIZE_BYTES=120000

# Less frequent batches
OP_BATCHER_MAX_CHANNEL_DURATION=10

# Less frequent proposals
OP_PROPOSER_PROPOSAL_INTERVAL=300s  # 5 minutes
```

### Optimize for High Throughput

```bash
# Increase L2 gas limit
"l2BlockGasLimit": 50000000  # Default: 30000000

# Larger batch buffer
OP_BATCHER_MAX_L1_TX_SIZE_BYTES=128000
```

---

## Troubleshooting Commands Quick Reference

```bash
# Check all service statuses
docker ps | grep celo-l3-geth
ps aux | grep op-batcher | grep -v grep
ps aux | grep op-proposer | grep -v grep
ps aux | grep simple-rpc-proxy | grep -v grep

# Check all RPC endpoints
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq
curl -s -X POST http://localhost:9545 || echo "RPC proxy not responding"
curl -s -X POST https://rpc.ankr.com/celo_sepolia -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq

# Check all account balances
cast balance 0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62 --rpc-url https://rpc.ankr.com/celo_sepolia
cast balance 0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47 --rpc-url https://rpc.ankr.com/celo_sepolia
cast balance 0x89a26a33747b293430D4269A59525d5D0D5BbE65 --rpc-url https://rpc.ankr.com/celo_sepolia

# Tail all logs simultaneously
tail -f l2-deployment/logs/op-batcher.log l2-deployment/logs/op-proposer.log

# Check metrics
curl -s http://localhost:7301/metrics | grep -E 'batcher_|batch_'
curl -s http://localhost:7302/metrics | grep -E 'proposer_|proposal_'
```

---

## Migration to Celo Mainnet

See: `CELO_MAINNET_MIGRATION_PLAN.md`

**Quick Steps:**
1. Create new mainnet wallets (don't reuse testnet keys!)
2. Fund wallets with mainnet CELO
3. Update `.envrc.celo-mainnet` with production keys
4. Deploy L1 contracts to Celo Mainnet
5. Generate new genesis with mainnet L1 deployment
6. Start sequencer with mainnet configuration
7. Test thoroughly before announcing publicly

---

## Support & Resources

**Documentation:**
- Optimism Docs: https://docs.optimism.io
- OP Stack Specs: https://specs.optimism.io
- Celo Docs: https://docs.celo.org

**Get Help:**
- Optimism Discord: https://discord.optimism.io
- Celo Discord: https://discord.gg/celo

**Tools:**
- Foundry (cast): https://book.getfoundry.sh
- Celo Explorer: https://celoscan.io
- Celo Sepolia Explorer: https://sepolia.celoscan.io

---

**Last Updated:** 2025-01-XX
**Maintained By:** Arx Protocol Team
