#!/usr/bin/env node
/**
 * Sync Contract Addresses from arx-contracts.json to Client Hooks
 *
 * This script automatically updates all hardcoded contract addresses in the
 * client/hooks directory with the latest deployed addresses from arx-contracts.json
 */

const fs = require('fs');
const path = require('path');

// Paths
const CONTRACTS_JSON = path.join(__dirname, '../l2-deployment/arx-contracts.json');
const HOOKS_DIR = path.join(__dirname, '../client/hooks');

// Mapping of contract names to hook file patterns
const CONTRACT_TO_HOOK = {
  'TaskRegistry': { file: 'useTaskRegistry.ts', pattern: /TASK_REGISTRY_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'VerificationManager': { file: 'useVerificationManager.ts', pattern: /VERIFICATION_MANAGER_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'DataRegistry': { file: 'useDataRegistry.ts', pattern: /DATA_REGISTRY_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'FundingPool': { file: 'useFundingPool.ts', pattern: /FUNDING_POOL_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'CarbonMarketplace': { file: 'useCarbonMarketplace.ts', pattern: /CARBON_MARKETPLACE_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'CarbonCreditMinter': { file: 'useCarbonCreditMinter.ts', pattern: /CARBON_CREDIT_MINTER_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'cUSD': { file: 'useERC20Approval.ts', pattern: /DEFAULT_CUSD_TOKEN_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'GovernanceDAO': { file: 'useGovernanceDAO.ts', pattern: /GOVERNANCE_DAO_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'CollateralManager': { file: 'useCollateralManager.ts', pattern: /COLLATERAL_MANAGER_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'ModelRegistry': { file: 'useModelRegistry.ts', pattern: /MODEL_REGISTRY_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
  'PredictionMarket': { file: 'usePredictionMarket.ts', pattern: /PREDICTION_MARKET_ADDRESS = '(0x[a-fA-F0-9]{40})'/ },
};

async function main() {
  console.log('🔄 Syncing Contract Addresses...\n');

  // Read deployed contract addresses
  if (!fs.existsSync(CONTRACTS_JSON)) {
    console.error(`❌ Contract addresses file not found: ${CONTRACTS_JSON}`);
    console.error('   Please deploy contracts first using: npm run deploy:l2');
    process.exit(1);
  }

  const deployedAddresses = JSON.parse(fs.readFileSync(CONTRACTS_JSON, 'utf8'));
  console.log('📋 Loaded contract addresses from:', CONTRACTS_JSON);

  let updatedCount = 0;
  let errorCount = 0;

  // Update each hook file
  for (const [contractName, config] of Object.entries(CONTRACT_TO_HOOK)) {
    const hookPath = path.join(HOOKS_DIR, config.file);
    const newAddress = deployedAddresses[contractName];

    if (!newAddress) {
      console.log(`⚠️  ${contractName}: No address found in deployment file`);
      continue;
    }

    if (!fs.existsSync(hookPath)) {
      console.log(`⚠️  ${contractName}: Hook file not found: ${config.file}`);
      errorCount++;
      continue;
    }

    try {
      let content = fs.readFileSync(hookPath, 'utf8');
      const match = content.match(config.pattern);

      if (!match) {
        console.log(`⚠️  ${contractName}: Pattern not found in ${config.file}`);
        errorCount++;
        continue;
      }

      const oldAddress = match[1];

      if (oldAddress === newAddress) {
        console.log(`✓  ${contractName}: Already up-to-date (${newAddress})`);
        continue;
      }

      // Replace address
      content = content.replace(config.pattern, (match, group1) => {
        return match.replace(group1, newAddress);
      });

      fs.writeFileSync(hookPath, content, 'utf8');
      console.log(`✅ ${contractName}: Updated ${oldAddress} → ${newAddress}`);
      updatedCount++;
    } catch (error) {
      console.error(`❌ ${contractName}: Error updating ${config.file}:`, error.message);
      errorCount++;
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log(`✅ Updated: ${updatedCount} contracts`);
  if (errorCount > 0) {
    console.log(`⚠️  Errors: ${errorCount} contracts`);
  }
  console.log('='.repeat(60));

  if (updatedCount > 0) {
    console.log('\n💡 Restart your development server to load the new addresses');
  }
}

main().catch((error) => {
  console.error('❌ Fatal error:', error);
  process.exit(1);
});
