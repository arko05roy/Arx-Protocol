# Next Steps Implementation Guide

**Based on**: @[arx/Op.md] and @[arx/docs-op]  
**Status**: Services Running ✅  
**Next Phase**: Deploy Applications & Monitoring

---

## 📋 What's Left to Implement

### Phase 8: Deploy Your Apps (Op.md Step 18)

#### Step 1: Deploy Custom Smart Contracts to L3

```bash
# Set L3 RPC endpoint
export L3_RPC=http://localhost:8545
export DEPLOYER_PRIVATE_KEY=f0071a1eef433a24b6603da004f67c6aad2513718c54ec0c70504a88de4edb88

# Using Foundry
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx
forge create \
  --rpc-url $L3_RPC \
  --private-key $DEPLOYER_PRIVATE_KEY \
  src/MyCustomLogic.sol:MyCustomLogic

# Or using Hardhat
npx hardhat run scripts/deploy.js --network celo-l3
```

#### Step 2: Test Your L3

```bash
# Send a test transaction
cast send \
  --rpc-url $L3_RPC \
  --private-key $DEPLOYER_PRIVATE_KEY \
  0xYOUR_CONTRACT_ADDRESS \
  "customFunction(uint256)" \
  100

# Check balance
cast call \
  --rpc-url $L3_RPC \
  0xYOUR_CONTRACT_ADDRESS \
  "balances(address)(uint256)" \
  0xYOUR_ADDRESS

# Monitor L3 blocks
cast block latest --rpc-url $L3_RPC

# Check if transactions are being batched to Celo
cast logs \
  --rpc-url https://rpc.ankr.com/celo_sepolia \
  --address 0xff00000000000000000000000000000000424242 \
  --from-block latest
```

---

### Phase 9: Set Up Monitoring and Management (Op.md Step 20)

#### Option 1: Use the New Continuous Monitor Script

```bash
# Make monitor script executable
chmod +x /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh

# Run the monitor (never-ending process)
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
```

**Features:**
- ✅ Continuous monitoring (checks every 30 seconds)
- ✅ Auto-restart on crash
- ✅ Detailed logging with timestamps
- ✅ Error tracking and reporting
- ✅ Graceful shutdown on SIGINT/SIGTERM
- ✅ Status summary every 5 minutes

#### Option 2: Docker-based Monitoring (Op.md Step 20)

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment

# Create docker-compose for monitoring
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  node_exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
EOF

# Create Prometheus config
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'op-node'
    static_configs:
      - targets: ['localhost:7300']
  
  - job_name: 'op-batcher'
    static_configs:
      - targets: ['localhost:7301']
  
  - job_name: 'op-proposer'
    static_configs:
      - targets: ['localhost:7302']
EOF

# Start monitoring stack
docker-compose up -d

# Access dashboards
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

---

## 🚀 Quick Implementation Checklist

### Immediate Actions (Now)

- [ ] Start continuous monitor:
  ```bash
  bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
  ```

- [ ] Verify L3 is responding:
  ```bash
  curl -X POST http://localhost:9545 \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
  ```

- [ ] Check service logs:
  ```bash
  tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log
  ```

### Short Term (Next 1-2 hours)

- [ ] Deploy test contract to L3
- [ ] Send test transactions
- [ ] Verify batching to L1
- [ ] Set up Prometheus/Grafana monitoring

### Medium Term (Next 24 hours)

- [ ] Deploy production contracts
- [ ] Set up alerting
- [ ] Configure backups
- [ ] Test bridge functionality
- [ ] Document deployment

---

## 📊 Monitoring Commands

### View Service Status
```bash
# Check if services are running
ps aux | grep -E "op-node|op-batcher|op-proposer" | grep -v grep

# View monitor log
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/monitor.log
```

### View Service Logs
```bash
# op-node logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log

# op-batcher logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-batcher.log

# op-proposer logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-proposer.log

# All logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/*.log
```

### Check Metrics
```bash
# op-node metrics
curl http://localhost:7300/metrics | grep -E "op_node|process"

# op-batcher metrics
curl http://localhost:7301/metrics | grep -E "op_batcher|process"

# op-proposer metrics
curl http://localhost:7302/metrics | grep -E "op_proposer|process"
```

---

## 🔗 Network Endpoints

### L2 (Your L3)
- **RPC**: http://localhost:8545
- **WebSocket**: http://localhost:8546
- **op-node RPC**: http://localhost:9545
- **op-proposer RPC**: http://localhost:8560

### L1 (Celo Sepolia)
- **RPC**: https://rpc.ankr.com/celo_sepolia
- **Explorer**: https://celo-sepolia.blockscout.com/
- **Chain ID**: 11142220

### Monitoring
- **Prometheus**: http://localhost:9090 (when Docker running)
- **Grafana**: http://localhost:3000 (when Docker running)
- **Node Exporter**: http://localhost:9100 (when Docker running)

---

## 📝 Test Transactions

### Send Test Transaction
```bash
export L3_RPC=http://localhost:8545
export DEPLOYER_KEY=f0071a1eef433a24b6603da004f67c6aad2513718c54ec0c70504a88de4edb88

# Send 0.1 ETH to another address
cast send \
  --rpc-url $L3_RPC \
  --private-key $DEPLOYER_KEY \
  --value 0.1ether \
  0x89a26a33747b293430D4269A59525d5D0D5BbE65
```

### Check L1 Batches
```bash
# Query batch inbox for transactions
cast logs \
  --rpc-url https://rpc.ankr.com/celo_sepolia \
  --address 0xff00000000000000000000000000000000424242 \
  --from-block latest \
  --to-block latest
```

---

## 🛑 Stopping Services

### Stop Monitor (if running)
```bash
# Press Ctrl+C in the monitor terminal
# Or from another terminal:
pkill -f "monitor-services.sh"
```

### Stop All Services
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/stop-services.sh
```

### Stop Individual Services
```bash
pkill -f "op-node"
pkill -f "op-batcher"
pkill -f "op-proposer"
```

---

## 🔄 Restart Services

### Restart All
```bash
# Stop all
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/stop-services.sh

# Wait a few seconds
sleep 5

# Start all
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/start-services-direct.sh
```

### Restart with Monitor
```bash
# Stop all
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/stop-services.sh

# Wait
sleep 5

# Start monitor (which will start all services)
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
```

---

## 📚 Documentation Files

- **QUICK_START.md** - Quick reference
- **FINAL_STATUS.md** - Complete deployment status
- **DEPLOYED_ADDRESSES.md** - All contract addresses
- **PHASE5_SERVICES.md** - Services deployment guide
- **NEXT_STEPS_IMPLEMENTATION.md** - This file

---

## ✅ Implementation Status

**Phase 1-5**: ✅ COMPLETE  
**Phase 6**: 🔄 IN PROGRESS (Monitoring)  
**Phase 7**: ⏳ PENDING (Deploy Apps)  
**Phase 8**: ⏳ PENDING (Testing)  
**Phase 9**: ⏳ PENDING (Production Setup)

---

## 🎯 Recommended Next Action

**Start the continuous monitor:**

```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
```

This will:
1. Keep all services running
2. Auto-restart on crash
3. Log all events
4. Monitor for errors
5. Run indefinitely until stopped

---

**Status**: Ready for Phase 7 (Deploy Applications) 🚀
