# 🚀 CELO SEPOLIA L3 - QUICK START GUIDE

## ✅ Prerequisites (One-Time Setup)

### 1. Install Docker Desktop
- Download from: https://www.docker.com/products/docker-desktop
- Install and open Docker Desktop
- **No other packages needed**

### 2. Verify Installation
```bash
docker --version
```

---

## 🎯 START YOUR BLOCKCHAIN (One Command)

```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/START_L3_COMPLETE.sh
```

**This starts:**
- ✅ op-geth (Sequencer) - http://localhost:8545
- ✅ op-batcher (Batch Submitter to L1)
- ✅ op-proposer (State Root Submitter to L1)
- ✅ Monitoring Dashboard - http://localhost:3000

**Wait 30 seconds for full startup.**

---

## 📊 MONITOR YOUR BLOCKCHAIN (One Command)

**In a NEW terminal:**
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/MONITOR.sh
```

**This shows:**
- ✅ Real-time block height
- ✅ Transaction count
- ✅ Pending transactions
- ✅ Service status (op-geth, op-batcher, op-proposer)
- ✅ Error logs
- ✅ Network health

---

## 💰 YOUR ACCOUNT

```
Address:     0xABaF59180e0209bdB8b3048bFbe64e855074C0c4
Private Key: 0x9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad
Balance:     100,000 GAIA tokens
Chain ID:    424242
RPC:         http://localhost:8545
```

---

## 🧪 TEST YOUR BLOCKCHAIN

### Send a Transaction
```bash
cast send \
  --rpc-url http://localhost:8545 \
  --private-key 0x9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad \
  --value 1ether \
  0x89a26a33747b293430D4269A59525d5D0D5BbE65
```

### Deploy a Contract
```bash
forge create \
  --rpc-url http://localhost:8545 \
  --private-key 0x9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad \
  src/MyContract.sol:MyContract
```

### Check Balance
```bash
cast balance 0xABaF59180e0209bdB8b3048bFbe64e855074C0c4 \
  --rpc-url http://localhost:8545
```

---

## 🛑 STOP YOUR BLOCKCHAIN

```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/STOP_L3.sh
```

---

## 🔗 CONNECT IN METAMASK

1. Open MetaMask
2. Settings → Networks → Add Network
3. Fill in:
   - **Network Name**: Celo Sepolia L3
   - **RPC URL**: http://localhost:8545
   - **Chain ID**: 424242
   - **Currency Symbol**: GAIA
4. Click Save
5. Import account with your private key

---

## 📋 TROUBLESHOOTING

### "Transaction indexing is in progress"
- **Normal** - op-geth is indexing transactions
- **Solution**: Wait 30-60 seconds, then retry

### "Connection refused"
- **Problem**: op-geth not running
- **Solution**: Run START command again

### "Docker not found"
- **Problem**: Docker Desktop not running
- **Solution**: Open Docker Desktop from Applications

---

## ✨ That's It!

Your blockchain is ready to use. 🎉
