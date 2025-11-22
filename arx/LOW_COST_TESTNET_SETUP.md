# Low-Cost Testnet Setup - Optimized for Faucet Limits

## ✅ Configuration Optimized for Minimal CELO Usage!

Your sequencer has been **optimized to use MUCH LESS testnet CELO** - perfect for faucet limits!

---

## 💰 New Reduced Funding Requirements

### **Before Optimization:**
- Batcher: 10-50 CELO
- Proposer: 5-20 CELO
- **Total: 15-70 CELO** 😰

### **After Optimization:**
- **Batcher: 1-2 CELO** ✅
- **Proposer: 0.5-1 CELO** ✅
- **Total: 1.5-3 CELO** 🎉

**This is achievable with most testnet faucets!**

---

## 🔧 What Was Changed

### **Batcher (op-batcher.env):**

| Parameter | Before | After | Impact |
|-----------|--------|-------|--------|
| `MAX_CHANNEL_DURATION` | `1` | `50` | Batches every ~4 min instead of ~5 sec |
| `MAX_L1_TX_SIZE_BYTES` | `120000` | `128000` | Larger batches = fewer L1 txns |
| `TARGET_L1_TX_SIZE_BYTES` | `100000` | `120000` | Pack more data per txn |
| `POLL_INTERVAL` | Default (1s) | `10s` | Check less frequently |
| `NUM_CONFIRMATIONS` | Default (1) | `3` | Avoid wasted gas on reorgs |

**Result:** ~50-100x fewer L1 transactions = ~50-100x lower gas costs! 🚀

### **Proposer (op-proposer.env):**

| Parameter | Before | After | Impact |
|-----------|--------|-------|--------|
| `POLL_INTERVAL` | `12s` | `600s` (10 min) | State roots every 10 min instead of 12 sec |
| `NUM_CONFIRMATIONS` | `1` | `3` | Avoid wasted gas on reorgs |

**Result:** ~50x fewer L1 transactions = ~50x lower gas costs! 🚀

---

## 📊 Expected Behavior with Low-Cost Settings

### **Batch Submissions:**

**Frequency:** Every ~4 minutes (instead of every few seconds)

**What you'll see on explorer:**
```
Transaction 1: 10:00 AM
Transaction 2: 10:04 AM
Transaction 3: 10:08 AM
Transaction 4: 10:12 AM
...
```

**On low activity:** May batch even less frequently (that's good - saves gas!)

### **State Root Proposals:**

**Frequency:** Every ~10 minutes (instead of every 12 seconds)

**What you'll see on explorer:**
```
Proposal 1: 10:00 AM
Proposal 2: 10:10 AM
Proposal 3: 10:20 AM
...
```

---

## ⚖️ Trade-offs (What You Give Up)

### **Slower L1 Finality** (Not a Problem for Testnet!)

| Metric | Before | After | Impact |
|--------|--------|-------|--------|
| **Batch to L1** | ~5 seconds | ~4 minutes | L2→L1 finality slower |
| **Withdrawals** | Faster | Slower | Still works, just takes longer |
| **L1 Data Availability** | Near-instant | ~4 min delay | Still secure, just delayed |

**For testnet demos:** This is totally fine! You still get:
- ✅ Batches visible on Celo Sepolia explorer
- ✅ Public proof of data availability
- ✅ All the same security guarantees
- ✅ Just with less frequent submissions

### **What Still Works Perfectly:**

- ✅ L2 block production (still 2 second blocks!)
- ✅ L2 transactions (instant on your L2!)
- ✅ Batch visibility on explorer
- ✅ Data availability guarantees
- ✅ Withdrawal functionality (just slower)

---

## 💸 Cost Analysis

### **Gas Usage Estimates:**

**Batcher (per transaction):**
- Calldata cost: ~45,000 gas (for 120KB batch)
- Base cost: ~21,000 gas
- **Total: ~66,000 gas per batch**

**Proposer (per transaction):**
- State root submission: ~100,000 gas
- **Total: ~100,000 gas per proposal**

### **With Celo Sepolia Gas Prices:**

Assuming ~0.5 Gwei gas price on Celo Sepolia:

**Batcher:**
- Per batch: 66,000 × 0.5 Gwei = 0.000033 CELO
- Per day: ~360 batches/day × 0.000033 = **~0.012 CELO/day**
- **1 CELO lasts ~83 days!** 🎉

**Proposer:**
- Per proposal: 100,000 × 0.5 Gwei = 0.00005 CELO
- Per day: ~144 proposals/day × 0.00005 = **~0.007 CELO/day**
- **1 CELO lasts ~142 days!** 🎉

**Total: 1-2 CELO can run for weeks!**

---

## 🎯 How to Get Started

### **Step 1: Fund Minimal Amounts**

**Batcher:** `0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62`
- **Minimum:** 1 CELO
- **Recommended:** 2 CELO (for safety buffer)

**Proposer:** `0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47`
- **Minimum:** 0.5 CELO
- **Recommended:** 1 CELO (for safety buffer)

**Total needed: Just 2-3 CELO!** ✅

### **Where to Get Testnet CELO:**

**Option 1: Official Celo Faucet**
```
https://faucet.celo.org
```

**Option 2: Celo Discord Faucet**
```
1. Join: https://discord.gg/celo
2. Go to #faucet channel
3. Request testnet CELO
```

**Option 3: Alternative Faucets**
- https://faucet.triangleplatform.com/celo/alfajores
- https://stakely.io/faucet/celo-alfajores

**Note:** Some faucets may give Alfajores (older testnet). You need **Sepolia** testnet CELO.

### **Step 2: Check Balances**

```bash
./check-balances.sh
```

Should show:
```
🔄 Batcher Account
   ✅ Balance: 2.0 CELO

📝 Proposer Account
   ✅ Balance: 1.0 CELO
```

### **Step 3: Start Sequencer**

```bash
cd l2-deployment
./START_L3_COMPLETE.sh
```

### **Step 4: Monitor**

```bash
cd l2-deployment
./MONITOR.sh
```

**Note:** First batch may take 4-5 minutes to appear. This is normal!

---

## 📈 Monitoring Tips

### **Don't Panic If:**

❌ **"No batches after 1 minute"**
- ✅ **Expected!** Batches now submit every ~4 minutes

❌ **"No proposals after 30 seconds"**
- ✅ **Expected!** Proposals now submit every ~10 minutes

❌ **"Fewer transactions on explorer"**
- ✅ **Expected!** That's the point - less gas usage!

### **What to Watch For:**

✅ **Batcher logs show "Publishing transaction" every ~4 min**
✅ **Proposer logs show proposals every ~10 min**
✅ **L2 block number increasing every 2 seconds**
✅ **Account balances slowly decreasing (very slowly!)**

---

## 🔍 Verify Batches Still Appear

**Your batches WILL still appear on Celo Sepolia explorer!**

**Check here:**
```
https://sepolia.celoscan.io/address/0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62
```

**What you'll see:**
- ✅ Transactions every ~4 minutes (not every few seconds)
- ✅ Each transaction contains a larger batch of L2 data
- ✅ Still 100% public and verifiable!

**For demos:** Just explain you optimized for lower cost by batching less frequently.

---

## 🎨 Talking Points for Demos

### **When Showing Your Rollup:**

1. **"We've optimized for cost efficiency"**
   - Batch every 4 minutes instead of continuously
   - Larger batches = fewer L1 transactions
   - Same security, lower costs

2. **"All batches are still public"**
   - Every 4 minutes, new batch appears on Celo Sepolia
   - Anyone can verify our L2 data
   - Data availability guaranteed

3. **"L2 is still fast"**
   - 2-second block times on L2
   - Instant transaction confirmations
   - Only L1 finality is slower (by design, for cost savings)

4. **"This is perfect for testnet"**
   - Works with faucet limits
   - Can run for weeks on minimal CELO
   - Same architecture as production (just less frequent)

---

## 🚀 Production Mainnet Notes

### **For Celo Mainnet deployment:**

You can adjust these values based on your needs:

**High Activity / Need Fast Finality:**
- `MAX_CHANNEL_DURATION`: 5-10 (batch more frequently)
- `POLL_INTERVAL`: 60-120s (propose more frequently)
- **Cost:** Higher, but faster L1 finality

**Low Activity / Cost Optimized:**
- `MAX_CHANNEL_DURATION`: 50-100 (batch less frequently)
- `POLL_INTERVAL`: 300-600s (propose less frequently)
- **Cost:** Lower, but slower L1 finality

**Balanced (Recommended for Mainnet):**
- `MAX_CHANNEL_DURATION`: 20-30
- `POLL_INTERVAL`: 120-300s
- **Cost:** Moderate, reasonable finality

---

## 📊 Quick Reference

### **Current Low-Cost Settings:**

```bash
# Batcher
MAX_CHANNEL_DURATION=50        # ~4 min between batches
MAX_L1_TX_SIZE_BYTES=128000    # Larger batches
POLL_INTERVAL=10s              # Check every 10s
NUM_CONFIRMATIONS=3            # Wait for finality

# Proposer
POLL_INTERVAL=600s             # Propose every 10 min
NUM_CONFIRMATIONS=3            # Wait for finality
```

### **Funding Requirements:**

```
Batcher:  1-2 CELO (can last months!)
Proposer: 0.5-1 CELO (can last months!)
Total:    2-3 CELO ✅
```

### **Expected Behavior:**

```
Batches:   Every ~4 minutes
Proposals: Every ~10 minutes
L2 Blocks: Every 2 seconds (unchanged!)
```

---

## ✅ Summary

**You can now run your sequencer with:**
- ✅ Just 2-3 testnet CELO (achievable with faucets!)
- ✅ Batches still visible on Celo Sepolia explorer
- ✅ All security guarantees maintained
- ✅ Same L2 performance (2-second blocks)
- ✅ Can run for weeks/months without refilling

**Perfect for:**
- 🎯 Testnet deployments
- 🎯 Demos and presentations
- 🎯 Development and testing
- 🎯 Learning OP Stack

**Next step:** Fund 2-3 CELO and start your sequencer! 🚀
