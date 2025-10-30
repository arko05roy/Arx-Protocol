# 🚀 Quick Start - Celo Sepolia L3

## Start Services (One Command)

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
bash start-services.sh
```

## Verify Services Running

```bash
# Check processes
ps aux | grep -E "op-node|op-batcher|op-proposer" | grep -v grep

# Test op-node
curl -X POST http://localhost:9545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'

# Expected: {"jsonrpc":"2.0","result":"0x67a2e","id":1}
```

## View Logs

```bash
# op-node logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log

# All logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/*.log
```

## Stop Services

```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/stop-services.sh
```

## Key Endpoints

- **op-node RPC**: http://localhost:9545
- **L2 RPC**: http://localhost:8545 (when geth is running)
- **op-proposer RPC**: http://localhost:8560
- **Metrics**: http://localhost:7300, 7301, 7302

## Important Files

- **Config**: `/l2-deployment/rollup.json`
- **Addresses**: `/l2-deployment/addresses.json`
- **JWT Secret**: `/l2-deployment/jwt-secret.txt`
- **Logs**: `/l2-deployment/logs/`

## Network Details

- **L1**: Celo Sepolia (Chain ID: 11142220)
- **L2**: Your L3 (Chain ID: 424242)
- **L1 RPC**: https://rpc.ankr.com/celo_sepolia

## Deployed Contracts

- **OptimismPortalProxy**: 0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1
- **SystemConfigProxy**: 0xC7D71BC3bF37C129fa12c81377B8566661435a96
- **L1CrossDomainMessengerProxy**: 0xaF03e76b94b1dFdF2DaF8ed0ef13DC9dE5B23dD8

See `DEPLOYED_ADDRESSES.md` for all 24 contracts.

---

**Status**: ✅ Ready to Start  
**Deployment**: Complete  
**Services**: Built & Configured
