# Celo Sepolia L3 - Deployed Contract Addresses

**Deployment Date**: Oct 30, 2025  
**Network**: Celo Sepolia (Chain ID: 11142220)  
**L2 Chain ID**: 424242  
**Deployment TX**: 11142220-deploy.json

## Core Contracts

| Contract | Address |
|----------|---------|
| **SuperchainConfigProxy** | `0xDc82c0362A241Aa94d53546648EACe48C9773dAa` |
| **SuperchainConfigImpl** | `0xb08Cc720F511062537ca78BdB0AE691F04F5a957` |
| **SuperchainProxyAdmin** | `0xdaE97900D4B184c5D2012dcdB658c008966466DD` |
| **ProtocolVersionsProxy** | `0x856e75e9c0Da547F9753c17746D6cc139b668e5c` |
| **ProtocolVersionsImpl** | `0x1f734B89Bb1B422B9910118fb8d44C06E33d4DdA` |

## L1 Bridge Contracts

| Contract | Address |
|----------|---------|
| **L1CrossDomainMessengerProxy** | `0xaF03e76b94b1dFdF2DaF8ed0ef13DC9dE5B23dD8` |
| **L1StandardBridgeProxy** | `0x022B27F7F11Ce7841b53E8E00735C62c10B56dB6` |
| **L1ERC721BridgeProxy** | `0x713C552Fa215D1a8a832d0A44461f9728A52a62E` |
| **OptimismMintableERC20FactoryProxy** | `0x1D1e4324dbA06D966eA5660380A01EeaC1De723f` |
| **ETHLockboxProxy** | `0x81409206A28d264e051D87ECbad481B46631Fcc1` |

## Portal & Output Contracts

| Contract | Address |
|----------|---------|
| **OptimismPortalProxy** | `0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1` |
| **OptimismPortal2Proxy** | `0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1` |
| **SystemConfigProxy** | `0xC7D71BC3bF37C129fa12c81377B8566661435a96` |

## Dispute Game Contracts

| Contract | Address |
|----------|---------|
| **DisputeGameFactoryProxy** | `0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e` |
| **PermissionedDisputeGame** | `0xB5fE4524825aAdc3a0920281Ca2B06202692b485` |
| **AnchorStateRegistryProxy** | `0xb5Dc34E6896f82E46F8caCBB16BF2A0CEdE4592E` |

## Utility Contracts

| Contract | Address |
|----------|---------|
| **AddressManager** | `0xb7D614FEAC4179069246dCd452Fa1Ec21FEdaf17` |
| **ProxyAdmin** | `0x090049deD2e68E720517bAcFB264DcA336524775` |
| **OPContractsManager** | `0x2D165bEa6d25182780931d554766d35d83466A25` |
| **MipsSingleton** | `0x6463dEE3828677F6270d83d45408044fc5eDB908` |
| **PreimageOracle** | `0x1fb8cdFc6831fc866Ed9C51aF8817Da5c287aDD3` |

## Delayed WETH Contracts

| Contract | Address |
|----------|---------|
| **DelayedWETHProxy** | `0xB943Ec44C89595e584394A2eF5FA831A736A6a3D` |
| **DelayedWETHImpl** | `0xb86a464CC743440FddAa43900e05318ef4818b29` |
| **PermissionedDelayedWETHProxy** | `0x7D4CC40e30dC152bEfdDe94574E834ee00430375` |

## Key Addresses for L2 Configuration

```json
{
  "l1ChainID": 11142220,
  "l2ChainID": 424242,
  "l1CrossDomainMessengerProxy": "0xaF03e76b94b1dFdF2DaF8ed0ef13DC9dE5B23dD8",
  "l1StandardBridgeProxy": "0x022B27F7F11Ce7841b53E8E00735C62c10B56dB6",
  "optimismPortalProxy": "0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1",
  "systemConfigProxy": "0xC7D71BC3bF37C129fa12c81377B8566661435a96",
  "addressManager": "0xb7D614FEAC4179069246dCd452Fa1Ec21FEdaf17"
}
```

## Verification

All contracts deployed and verified on:
- **Block Explorer**: https://celo-sepolia.blockscout.com/
- **Deployment File**: `/optimism/packages/contracts-bedrock/deployments/11142220-deploy.json`
