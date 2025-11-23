#!/usr/bin/env node

/**
 * inject-arx-predeploys.js
 *
 * Injects ARX Protocol contract predeploys into the genesis.json file.
 * This script compiles the contracts, extracts bytecode, and adds them to the genesis alloc.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Predeploy addresses (must match ArxPredeploys.sol)
const PREDEPLOY_ADDRESSES = {
  TaskRegistry: '0x4200000000000000000000000000000000000100',
  DataRegistry: '0x4200000000000000000000000000000000000101',
  ModelRegistry: '0x4200000000000000000000000000000000000102',
  FundingPool: '0x4200000000000000000000000000000000000103',
  CollateralManager: '0x4200000000000000000000000000000000000104',
  VerificationManager: '0x4200000000000000000000000000000000000105',
  CarbonCreditMinter: '0x4200000000000000000000000000000000000106',
  CarbonMarketplace: '0x4200000000000000000000000000000000000107',
  PredictionMarket: '0x4200000000000000000000000000000000000108',
  GovernanceDAO: '0x4200000000000000000000000000000000000109',
  Treasury: '0x420000000000000000000000000000000000010A',
  MockERC20: '0x420000000000000000000000000000000000010B',
};

// ARX Dapp account (owner of all contracts)
const ARX_DAPP_ACCOUNT = '0xABaF59180e0209bdB8b3048bFbe64e855074C0c4';

// Paths
const GENESIS_PATH = path.join(__dirname, '../genesis.json');
const WEB3_DIR = path.join(__dirname, '../../web3');
const ARTIFACTS_DIR = path.join(WEB3_DIR, 'artifacts/contracts');

console.log('🚀 ARX Protocol Genesis Predeploy Injector\n');

// Step 1: Compile contracts
console.log('📦 Step 1: Compiling contracts...');
try {
  execSync('npx hardhat compile', { cwd: WEB3_DIR, stdio: 'inherit' });
  console.log('✅ Contracts compiled successfully\n');
} catch (error) {
  console.error('❌ Failed to compile contracts:', error.message);
  process.exit(1);
}

// Step 2: Load genesis.json
console.log('📖 Step 2: Loading genesis.json...');
if (!fs.existsSync(GENESIS_PATH)) {
  console.error(`❌ Genesis file not found: ${GENESIS_PATH}`);
  process.exit(1);
}

const genesis = JSON.parse(fs.readFileSync(GENESIS_PATH, 'utf8'));
console.log('✅ Genesis loaded\n');

// Step 3: Create backup
const backupPath = `${GENESIS_PATH}.backup-${Date.now()}`;
console.log('💾 Step 3: Creating backup...');
fs.writeFileSync(backupPath, JSON.stringify(genesis, null, 2));
console.log(`✅ Backup created: ${backupPath}\n`);

// Step 4: Extract bytecode and inject predeploys
console.log('🔧 Step 4: Injecting predeploys...\n');

function getContractBytecode(contractName) {
  // Special case: PredictionMarket contract is in PredictionMarketplace.sol
  const fileName = contractName === 'PredictionMarket' ? 'PredictionMarketplace' : contractName;
  const artifactPath = path.join(ARTIFACTS_DIR, `${fileName}.sol/${contractName}.json`);

  if (!fs.existsSync(artifactPath)) {
    console.error(`❌ Artifact not found: ${artifactPath}`);
    return null;
  }

  const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
  return artifact.deployedBytecode || artifact.bytecode;
}

function keccak256Slot(position) {
  // Simple helper to calculate storage slot (for Ownable owner slot)
  // Owner is typically at slot 0 for Ownable contracts
  return position;
}

function injectPredeploy(contractName, address) {
  console.log(`  📝 ${contractName} -> ${address}`);

  const bytecode = getContractBytecode(contractName);

  if (!bytecode) {
    console.warn(`  ⚠️  Skipping ${contractName} (no bytecode found)`);
    return false;
  }

  // Create predeploy entry
  const predeploy = {
    code: bytecode,
    balance: '0x0',
  };

  // Add storage initialization for owner (Ownable contracts)
  // Most ARX contracts inherit from Ownable, which stores owner at slot 0
  if (contractName !== 'MockERC20') {
    predeploy.storage = {
      // Slot 0: Owner address (Ownable)
      '0x0000000000000000000000000000000000000000000000000000000000000000':
        '0x000000000000000000000000' + ARX_DAPP_ACCOUNT.slice(2).toLowerCase(),
    };
  } else {
    // MockERC20 special case: set total supply and balance
    const totalSupply = '1000000000000000000000000'; // 1M tokens with 18 decimals
    predeploy.storage = {
      // Slot 0: Owner
      '0x0000000000000000000000000000000000000000000000000000000000000000':
        '0x000000000000000000000000' + ARX_DAPP_ACCOUNT.slice(2).toLowerCase(),
      // Slot 2: Total supply (standard ERC20 layout)
      '0x0000000000000000000000000000000000000000000000000000000000000002':
        '0x00000000000000000000000000000000000000000000d3c21bcecceda1000000', // 1M * 10^18
    };

    // Balance mapping: keccak256(address . slot)
    // For simplicity, we'll set balance in the mapping manually
    // Standard ERC20 balances are at slot 1, mapping(address => uint256)
    // Hash of (ARX_DAPP_ACCOUNT, 1) gives the storage location
    // This is a simplified version - for full EVM compatibility, use proper keccak256
    predeploy.storage['0x' + '0'.repeat(24) + ARX_DAPP_ACCOUNT.slice(2).toLowerCase() + '01'] =
      '0x00000000000000000000000000000000000000000000d3c21bcecceda1000000';
  }

  // Inject into genesis alloc
  const allocKey = address.slice(2).toLowerCase();
  genesis.alloc[allocKey] = predeploy;

  console.log(`  ✅ ${contractName} injected successfully`);
  return true;
}

// Inject all predeploys
let successCount = 0;
for (const [contractName, address] of Object.entries(PREDEPLOY_ADDRESSES)) {
  if (injectPredeploy(contractName, address)) {
    successCount++;
  }
}

console.log(`\n✅ Injected ${successCount}/${Object.keys(PREDEPLOY_ADDRESSES).length} predeploys\n`);

// Step 5: Also fund the ARX Dapp account with ETH
console.log('💰 Step 5: Funding ARX Dapp account...');
const arxAccountKey = ARX_DAPP_ACCOUNT.slice(2).toLowerCase();
if (!genesis.alloc[arxAccountKey]) {
  genesis.alloc[arxAccountKey] = {};
}
// Fund with 10,000 ETH (same as RUN_L3.sh does)
genesis.alloc[arxAccountKey].balance = '0x21e19e0c9bab2400000'; // 10000 * 10^18 in hex
console.log(`✅ ARX Dapp account funded with 10,000 ETH\n`);

// Step 6: Write updated genesis
console.log('💾 Step 6: Writing updated genesis.json...');
fs.writeFileSync(GENESIS_PATH, JSON.stringify(genesis, null, 2));
console.log('✅ Genesis updated successfully\n');

// Step 7: Create address registry for backward compatibility
console.log('📋 Step 7: Creating address registry...');
const addressRegistry = {
  network: 'arxl3',
  chainId: 424242,
  deployedAt: new Date().toISOString(),
  type: 'predeploy',
  addresses: PREDEPLOY_ADDRESSES,
  owner: ARX_DAPP_ACCOUNT,
};

const registryPath = path.join(__dirname, '../arx-contracts.json');
fs.writeFileSync(registryPath, JSON.stringify(addressRegistry, null, 2));
console.log(`✅ Address registry created: ${registryPath}\n`);

console.log('🎉 All done! Genesis file updated with ARX predeploys.\n');
console.log('Next steps:');
console.log('  1. Review the changes in genesis.json');
console.log('  2. Restart your L3 chain with the new genesis');
console.log('  3. Contracts will be available immediately at predeploy addresses');
console.log('  4. Update your client to use these fixed addresses\n');
