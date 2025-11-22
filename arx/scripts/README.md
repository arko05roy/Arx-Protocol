# ARX Protocol - Utility Scripts

## Available Scripts

### 1. `sync-addresses.js`
**Automatically sync contract addresses from deployment to client**

Reads the deployed contract addresses from `l2-deployment/arx-contracts.json` and updates all the hardcoded addresses in the client hook files.

**Usage:**
```bash
node scripts/sync-addresses.js
```

**When to use:**
- After redeploying contracts manually
- If client addresses get out of sync
- Note: This runs automatically in `RUN_L3.sh`

**What it updates:**
- `client/hooks/useTaskRegistry.ts`
- `client/hooks/useVerificationManager.ts`
- `client/hooks/useDataRegistry.ts`
- `client/hooks/useFundingPool.ts`
- `client/hooks/useCarbonMarketplace.ts`
- `client/hooks/useCarbonCreditMinter.ts`
- `client/hooks/useERC20Approval.ts`
- `client/hooks/useGovernanceDAO.ts`
- `client/hooks/useCollateralManager.ts`
- `client/hooks/useModelRegistry.ts`
- `client/hooks/usePredictionMarket.ts`

---

### 2. `cleanup-logs.sh`
**Clean all logs and build artifacts**

Removes all runtime logs, build artifacts, and temporary files from the project while preserving blockchain data.

**Usage:**
```bash
bash scripts/cleanup-logs.sh
```

**What it cleans:**
- L2 deployment logs (`l2-deployment/logs/`)
- Web3 build artifacts (`web3/artifacts/`, `web3/cache/`)
- Optimism build artifacts
- Client build artifacts (`client/.next/`)
- All `.log`, `.tmp`, `.swp` files
- Temporary files (`nohup.out`, `.DS_Store`, etc.)

**What it preserves:**
- Blockchain data (`l2-deployment/geth-data/`) - Must be manually deleted if needed

**When to use:**
- Before committing to git
- When disk space is running low
- After encountering build issues

---

## Important Notes

### Deterministic Contract Addresses
Contract addresses are **deterministic** and will be the same every time you restart from genesis:
- Uses deployer account: `0x89a26a33747b293430D4269A59525d5D0D5BbE65`
- Nonce resets to 0 at genesis
- Same deployment order = Same addresses always

### Git Ignore
All logs and build artifacts are automatically ignored by git via `.gitignore`:
- `**/*.log` - All log files
- `**/logs/` - All logs directories
- Build artifacts (artifacts/, cache/, .next/, etc.)
- Blockchain data (geth-data/)

No manual cleanup needed for git commits!
