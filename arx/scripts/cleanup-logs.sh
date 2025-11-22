#!/bin/bash
#
# Cleanup Log Files & Build Artifacts
# Removes all runtime logs, build artifacts, and blockchain data
#

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧹 Cleaning up ARX Protocol logs and build artifacts...${NC}\n"

# Function to safely remove files/directories
safe_remove() {
    if [ -e "$1" ]; then
        echo -e "  Removing: $1"
        rm -rf "$1"
    fi
}

# =============================================================================
# L2 Deployment Logs
# =============================================================================
echo -e "${YELLOW}[1/6] Cleaning L2 deployment logs...${NC}"
safe_remove "l2-deployment/logs"
safe_remove "l2-deployment/*.log"
safe_remove "l2-deployment/*.pid"
safe_remove "l2-deployment/nohup.out"
safe_remove "l2-deployment/startup.log"

# Recreate logs directory
mkdir -p l2-deployment/logs
echo -e "${GREEN}✓ L2 deployment logs cleaned${NC}\n"

# =============================================================================
# Web3/Hardhat Build Artifacts & Logs
# =============================================================================
echo -e "${YELLOW}[2/6] Cleaning Web3 build artifacts...${NC}"
safe_remove "web3/artifacts"
safe_remove "web3/cache"
safe_remove "web3/typechain-types"
safe_remove "web3/*.log"
echo -e "${GREEN}✓ Web3 artifacts cleaned${NC}\n"

# =============================================================================
# Optimism Build Artifacts
# =============================================================================
echo -e "${YELLOW}[3/6] Cleaning Optimism build artifacts...${NC}"
find optimism -name "*.log" -type f -delete 2>/dev/null || true
safe_remove "optimism/optimism/packages/contracts-bedrock/deployments"
safe_remove "optimism/optimism/packages/contracts-bedrock/.deploy"
echo -e "${GREEN}✓ Optimism artifacts cleaned${NC}\n"

# =============================================================================
# Client/Next.js Build Artifacts
# =============================================================================
echo -e "${YELLOW}[4/6] Cleaning client build artifacts...${NC}"
safe_remove "client/.next"
safe_remove "client/out"
safe_remove "client/*.log"
echo -e "${GREEN}✓ Client artifacts cleaned${NC}\n"

# =============================================================================
# All Temporary Files
# =============================================================================
echo -e "${YELLOW}[5/6] Cleaning temporary files...${NC}"
find . -name "*.tmp" -type f -delete 2>/dev/null || true
find . -name "*.swp" -type f -delete 2>/dev/null || true
find . -name "*~" -type f -delete 2>/dev/null || true
find . -name "nohup.out" -type f -delete 2>/dev/null || true
find . -name ".DS_Store" -type f -delete 2>/dev/null || true
echo -e "${GREEN}✓ Temporary files cleaned${NC}\n"

# =============================================================================
# Optional: Blockchain Data (commented out for safety)
# =============================================================================
echo -e "${YELLOW}[6/6] Blockchain data preservation...${NC}"
if [ -d "l2-deployment/geth-data" ]; then
    echo -e "${YELLOW}⚠️  Blockchain data found at l2-deployment/geth-data${NC}"
    echo -e "${YELLOW}   To clean blockchain data, run:${NC}"
    echo -e "${YELLOW}   rm -rf l2-deployment/geth-data${NC}"
    echo -e "${GREEN}✓ Blockchain data preserved${NC}\n"
else
    echo -e "${GREEN}✓ No blockchain data found${NC}\n"
fi

echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}\n"

# Show disk space saved
echo -e "${YELLOW}💾 Disk space analysis:${NC}"
du -sh l2-deployment/logs 2>/dev/null || echo "  l2-deployment/logs: 0 B (cleaned)"
du -sh web3/artifacts 2>/dev/null || echo "  web3/artifacts: 0 B (cleaned)"
du -sh client/.next 2>/dev/null || echo "  client/.next: 0 B (cleaned)"
