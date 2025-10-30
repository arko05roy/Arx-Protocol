# Celo Sepolia L3 - Deployment Status Report

**Date**: October 30, 2025  
**Network**: Celo Sepolia (Chain ID: 11142220)  
**L2 Chain ID**: 424242  
**Status**: ✅ Phase 3 Complete | 🔄 Phase 4 In Progress

---

## Phase 1-2: ✅ COMPLETE
- Environment setup
- Wallet configuration
- Configuration files created

## Phase 3: ✅ COMPLETE - L1 Contract Deployment

### Deployment Summary
- **RPC Endpoint**: https://rpc.ankr.com/celo_sepolia
- **Deployment TX Block**: 8539727
- **Deployment File**: `/optimism/packages/contracts-bedrock/deployments/11142220-deploy.json`
- **Total Contracts Deployed**: 24

### Core Infrastructure Contracts

| Contract | Address | Purpose |
|----------|---------|---------|
| **SuperchainConfigProxy** | `0xDc82c0362A241Aa94d53546648EACe48C9773dAa` | Superchain configuration |
| **ProtocolVersionsProxy** | `0x856e75e9c0Da547F9753c17746D6cc139b668e5c` | Protocol version management |
| **ProxyAdmin** | `0x090049deD2e68E720517bAcFB264DcA336524775` | Proxy administration |
| **AddressManager** | `0xb7D614FEAC4179069246dCd452Fa1Ec21FEdaf17` | Address registry |

### L1 Bridge Contracts

| Contract | Address | Purpose |
|----------|---------|---------|
| **L1CrossDomainMessengerProxy** | `0xaF03e76b94b1dFdF2DaF8ed0ef13DC9dE5B23dD8` | Cross-domain messaging |
| **L1StandardBridgeProxy** | `0x022B27F7F11Ce7841b53E8E00735C62c10B56dB6` | Token bridging |
| **L1ERC721BridgeProxy** | `0x713C552Fa215D1a8a832d0A44461f9728A52a62E` | NFT bridging |
| **OptimismMintableERC20FactoryProxy** | `0x1D1e4324dbA06D966eA5660380A01EeaC1De723f` | Mintable token factory |
| **ETHLockboxProxy** | `0x81409206A28d264e051D87ECbad481B46631Fcc1` | ETH lockbox |

### Portal & Output Contracts

| Contract | Address | Purpose |
|----------|---------|---------|
| **OptimismPortalProxy** | `0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1` | L1 entry point |
| **OptimismPortal2Proxy** | `0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1` | Portal v2 |
| **SystemConfigProxy** | `0xC7D71BC3bF37C129fa12c81377B8566661435a96` | System configuration |

### Dispute Game Contracts

| Contract | Address | Purpose |
|----------|---------|---------|
| **DisputeGameFactoryProxy** | `0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e` | Dispute game factory |
| **PermissionedDisputeGame** | `0xB5fE4524825aAdc3a0920281Ca2B06202692b485` | Permissioned dispute game |
| **AnchorStateRegistryProxy** | `0xb5Dc34E6896f82E46F8caCBB16BF2A0CEdE4592E` | Anchor state registry |

### Utility Contracts

| Contract | Address | Purpose |
|----------|---------|---------|
| **OPContractsManager** | `0x2D165bEa6d25182780931d554766d35d83466A25` | Contracts manager |
| **MipsSingleton** | `0x6463dEE3828677F6270d83d45408044fc5eDB908` | MIPS VM |
| **PreimageOracle** | `0x1fb8cdFc6831fc866Ed9C51aF8817Da5c287aDD3` | Preimage oracle |
| **DelayedWETHProxy** | `0xB943Ec44C89595e584394A2eF5FA831A736A6a3D` | Delayed WETH |
| **DelayedWETHImpl** | `0xb86a464CC743440FddAa43900e05318ef4818b29` | WETH implementation |
| **PermissionedDelayedWETHProxy** | `0x7D4CC40e30dC152bEfdDe94574E834ee00430375` | Permissioned WETH |

---

## Phase 4: 🔄 IN PROGRESS - L2 Initialization

### Configuration Files Created
✅ `/l2-deployment/rollup.json` - op-node configuration  
✅ `/l2-deployment/addresses.json` - Contract addresses  
✅ `/l2-deployment/jwt-secret.txt` - JWT authentication  
✅ `/l2-deployment/geth-data/` - Geth data directory  

### Rollup Configuration
```json
{
  "l1_chain_id": 11142220,
  "l2_chain_id": 424242,
  "block_time": 2,
  "max_sequencer_drift": 600,
  "seq_window_size": 720,
  "channel_timeout": 60,
  "batch_inbox_address": "0xff00000000000000000000000000000000424242",
  "deposit_contract_address": "0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1",
  "l1_system_config_address": "0xC7D71BC3bF37C129fa12c81377B8566661435a96"
}
```

### Wallet Configuration
| Role | Address | Balance |
|------|---------|---------|
| **Admin** | `0x89a26a33747b293430D4269A59525d5D0D5BbE65` | 10 CELO |
| **Batcher** | `0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62` | 5 CELO |
| **Proposer** | `0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47` | 5 CELO |
| **Sequencer** | `0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49` | 1 CELO |

---

## Next Steps

### Phase 4 Continuation
1. **Build op-node** - Compile consensus layer
2. **Start op-geth** - Initialize execution layer
3. **Start op-node** - Run consensus layer
4. **Verify L2** - Test connectivity

### Phase 5: Services
1. **op-batcher** - Batch submission to L1
2. **op-proposer** - State root submission
3. **op-challenger** - Dispute monitoring

---

## File Locations

```
/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/
├── DEPLOYED_ADDRESSES.md          # All contract addresses
├── PHASE4_L2_INIT.md              # Phase 4 detailed guide
├── DEPLOYMENT_STATUS.md           # This file
├── .envrc.celo-sepolia            # Environment variables
├── celo-sepolia-config.json       # Deployment config
├── l2-deployment/
│   ├── rollup.json                # op-node config
│   ├── addresses.json             # Contract addresses
│   ├── jwt-secret.txt             # JWT secret
│   └── geth-data/                 # Geth data directory
└── optimism/optimism/
    └── packages/contracts-bedrock/
        └── deployments/
            └── 11142220-deploy.json  # Deployment artifacts
```

---

## Verification

### L1 Deployment Verification
```bash
# Check deployment artifacts
cat /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/packages/contracts-bedrock/deployments/11142220-deploy.json | jq 'keys'

# Verify on Celo Sepolia explorer
# https://celo-sepolia.blockscout.com/
```

### L2 Configuration Verification
```bash
# Verify rollup config
cat /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/rollup.json | jq '.'

# Verify JWT secret
cat /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/jwt-secret.txt
```

---

## Environment Variables

```bash
# Load environment
source /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/.envrc.celo-sepolia

# Key variables
export L1_RPC_URL=https://rpc.ankr.com/celo_sepolia
export L1_CHAIN_ID=11142220
export L2_CHAIN_ID=424242
export ADMIN_ADDRESS=0x89a26a33747b293430D4269A59525d5D0D5BbE65
export BATCHER_ADDRESS=0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62
export PROPOSER_ADDRESS=0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47
export SEQUENCER_ADDRESS=0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49
```

---

## Summary

✅ **Phase 3 Complete**: All L1 contracts successfully deployed to Celo Sepolia  
🔄 **Phase 4 In Progress**: L2 initialization configuration ready  
⏳ **Phase 5 Pending**: Service deployment (op-batcher, op-proposer)

**Total Deployment Time**: ~30 minutes  
**Status**: Ready for L2 service startup
