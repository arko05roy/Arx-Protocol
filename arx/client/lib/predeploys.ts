/**
 * ARX Protocol Predeploy Addresses
 *
 * These contracts are embedded in the genesis block and available from block 0.
 * Addresses follow Optimism's predeploy pattern using the 0x4200... namespace.
 *
 * @see web3/contracts/libraries/ArxPredeploys.sol
 */

export const ARX_PREDEPLOYS = {
  // Core protocol contracts
  TASK_REGISTRY: '0x4200000000000000000000000000000000000100' as const,
  DATA_REGISTRY: '0x4200000000000000000000000000000000000101' as const,
  MODEL_REGISTRY: '0x4200000000000000000000000000000000000102' as const,
  FUNDING_POOL: '0x4200000000000000000000000000000000000103' as const,
  COLLATERAL_MANAGER: '0x4200000000000000000000000000000000000104' as const,
  VERIFICATION_MANAGER: '0x4200000000000000000000000000000000000105' as const,

  // Carbon credit system contracts
  CARBON_CREDIT_MINTER: '0x4200000000000000000000000000000000000106' as const,
  CARBON_MARKETPLACE: '0x4200000000000000000000000000000000000107' as const,

  // Market and governance contracts
  PREDICTION_MARKETPLACE: '0x4200000000000000000000000000000000000108' as const,
  GOVERNANCE_DAO: '0x4200000000000000000000000000000000000109' as const,

  // Treasury and token contracts
  TREASURY: '0x420000000000000000000000000000000000010A' as const,
  CUSD_TOKEN: '0x420000000000000000000000000000000000010B' as const,
} as const;

// ARX Dapp account (owner of all contracts)
export const ARX_DAPP_ACCOUNT = '0xABaF59180e0209bdB8b3048bFbe64e855074C0c4' as const;

// Default gas parameters for transactions (fixes MetaMask issues)
export const DEFAULT_GAS_CONFIG = {
  gas: 5000000n,
  gasPrice: 1000000000n, // 1 Gwei
  type: 'legacy' as const,
} as const;
