# Gaia: Verifiable Impact Protocol on OP Stack L3

> *Bridging Real-World Environmental Action with On-Chain Verification*

Gaia is a Layer 3 blockchain built on OP Stack, settling to Celo, that transforms environmental projects into verifiable, tradeable carbon credits through decentralized validation and proof-of-impact consensus.

---

## 🌍 What is Gaia?

Gaia solves the climate finance trilemma: *verification, **transparency, and **liquidity*. We enable:

- 🌱 *Funders* to invest in verified environmental work and receive tokenized carbon credits
- 🔨 *Operators* to access capital for projects and prove their impact on-chain
- ✅ *Validators* to earn fees by verifying real-world work with collateral at stake
- 💹 *Traders* to buy/sell carbon credits in a liquid marketplace
- 🔬 *Researchers* to access open datasets for AI/ML model training

---

## 🏗 Architecture


┌─────────────────────────────────────────┐
│      Gaia L3 (OP Stack + Custom)        │
│  • 2-second blocks                      │
│  • Custom $IMPACT gas token             │
│  • Proof of Impact consensus            │
│  • Dedicated blockspace                 │
└──────────────┬──────────────────────────┘
               │ Settles to
               ↓
┌─────────────────────────────────────────┐
│         Celo L2 (Ethereum)              │
│  • Financial settlement                 │
│  • DAO governance                       │
│  • Mobile-first ReFi ecosystem          │
└──────────────┬──────────────────────────┘
               │ Settles to
               ↓
┌─────────────────────────────────────────┐
│            Ethereum L1                  │
│  • Final security layer                 │
└─────────────────────────────────────────┘


---

## ✨ Key Features

### 1. *Proof of Impact Consensus*
Validators stake collateral and review evidence (GPS photos, drone footage, IoT data) to verify real-world environmental work. Fraudulent operators lose their stake.

### 2. *Fractional Carbon Credits (ERC1155)*
Anyone can fund $10 and receive proportional carbon credits. Trade, retire, or hold for ESG compliance.

### 3. *Prediction Markets*
Every task spawns a market. Community trades YES/NO shares on project success, providing early signal on viability.

### 4. *DeSci Integration*
All verified tasks publish data to an open dataset. Train fraud detection models, stake them on-chain, and earn rewards for accuracy.

### 5. *On-Chain Governance*
Carbon credit holders vote on protocol parameters, validator disputes, and treasury allocation via Gaia DAO.

---

## 🚀 Quick Start

### Prerequisites

- Node.js v20+
- pnpm v8+
- Foundry (forge, cast, anvil)
- Go v1.21+
- 10+ CELO on Celo Alfajores testnet

### 1. Clone Repository

bash
git clone https://github.com/your-org/gaia.git
cd gaia


### 2. Setup Environment

bash
# Install dependencies
pnpm install

# Configure environment
cp .env.example .env
# Edit .env with your private keys and RPC URLs


### 3. Deploy Smart Contracts to Gaia L3

bash
cd contracts
pnpm hardhat deploy --network gaiaL3


### 4. Start Frontend

bash
cd frontend
pnpm dev
# Open http://localhost:3000


### 5. Run Local OP Stack L3 (Advanced)

See [OP_STACK_SETUP.md](./docs/OP_STACK_SETUP.md) for complete L3 deployment guide.

bash
cd op-stack-deployment
./start-all.sh


---

## 📂 Repository Structure


gaia/
├── contracts/              # Smart contracts (Hardhat)
│   ├── core/
│   │   ├── TaskRegistry.sol
│   │   ├── FundingPool.sol
│   │   ├── CollateralManager.sol
│   │   └── VerificationManager.sol
│   ├── markets/
│   │   ├── CarbonCreditMinter.sol
│   │   ├── CarbonMarketplace.sol
│   │   └── PredictionMarket.sol
│   ├── governance/
│   │   ├── GovernanceDAO.sol
│   │   └── ImpactToken.sol
│   └── data/
│       ├── DataRegistry.sol
│       └── ModelRegistry.sol
│
├── frontend/               # Next.js + React + Wagmi
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   └── config/
│   └── public/
│
├── op-stack-deployment/    # L3 infrastructure
│   ├── scripts/
│   ├── config/
│   └── docs/
│
├── subgraph/              # The Graph indexer
│   ├── schema.graphql
│   └── mappings/
│
└── docs/                  # Documentation
    ├── ARCHITECTURE.md
    ├── USER_FLOWS.md
    ├── OP_STACK_SETUP.md
    └── ECONOMIC_MODEL.md


---

## 🎯 User Flows

### Flow 1: Task Creation → Funding → Execution → Verification


1. NGO creates task: "Plant 10,000 mangroves in Tamil Nadu"
   ├─ Estimated cost: 50,000 cUSD
   ├─ Expected CO₂: 500 tons
   └─ Timeline: 3 months

2. Funders contribute cUSD (fractional funding allowed)
   └─ Track shares on FundingPool contract

3. Operator stakes 10% collateral (5,000 CELO)
   └─ Accepts task and begins work

4. Operator uploads proof (IPFS: photos, drone video, GPS logs)
   └─ Submits to VerificationManager

5. 3 validators review evidence
   ├─ Vote: APPROVE (with confidence scores)
   └─ Consensus reached (>66% threshold)

6. Carbon credits minted (ERC1155)
   ├─ Distributed proportionally to funders
   └─ Operator receives payment (49,000 cUSD)

7. Credits traded on marketplace
   └─ Price discovery via AMM or order book


### Flow 2: Prediction Markets


1. Task created → Market auto-spawns
   └─ Initial odds: 50% YES / 50% NO

2. Traders buy YES/NO shares
   ├─ Price adjusts based on demand
   └─ Provides early signal on project viability

3. Task verified → Market resolves
   ├─ YES holders win if task succeeds
   └─ NO holders win if task fails


---

## 🔧 Smart Contract Deployment

### Celo Alfajores (Testnet)

bash
cd contracts

# Deploy all contracts
npx hardhat run scripts/deploy-all.ts --network celoAlfajores

# Verify contracts
npx hardhat verify --network celoAlfajores <CONTRACT_ADDRESS>


### Gaia L3 (Local or Live)

bash
# Deploy to local L3
npx hardhat run scripts/deploy-all.ts --network gaiaL3

# Deploy to live Gaia L3
npx hardhat run scripts/deploy-all.ts --network gaiaL3Mainnet


---

## 🧪 Testing

### Smart Contract Tests

bash
cd contracts

# Run all tests
npx hardhat test

# Run specific test
npx hardhat test test/TaskRegistry.test.ts

# Coverage report
npx hardhat coverage


### Frontend Tests

bash
cd frontend

# Run unit tests
pnpm test

# Run e2e tests (Playwright)
pnpm test:e2e


---

## 📊 Contract Addresses

### Celo Alfajores Testnet

| Contract | Address |
|----------|---------|
| TaskRegistry | 0x... |
| FundingPool | 0x... |
| CollateralManager | 0x... |
| VerificationManager | 0x... |
| CarbonCreditMinter | 0x... |
| CarbonMarketplace | 0x... |
| PredictionMarket | 0x... |
| GovernanceDAO | 0x... |
| ImpactToken | 0x... |
| DataRegistry | 0x... |

### Gaia L3 (Live)

| Contract | Address |
|----------|---------|
| TaskRegistry | 0x... |
| FundingPool | 0x... |
| ... | ... |

---

## 🎨 Frontend

### Tech Stack

- *Framework:* Next.js 14 (App Router)
- *Blockchain:* Wagmi v2 + Viem
- *Wallet:* RainbowKit
- *Styling:* Tailwind CSS + shadcn/ui
- *State:* Zustand
- *Data:* The Graph (Subgraph queries)

### Key Pages

- / - Landing page
- /tasks - Browse all tasks
- /tasks/create - Create new task
- /tasks/[id] - Task detail page
- /marketplace - Carbon credit marketplace
- /bridge - L1 ↔ L3 bridge
- /governance - DAO proposals
- /dashboard - User dashboard

---

## 🔐 Security

### Audits

- ✅ *OpenZeppelin Contracts* used for battle-tested primitives
- 🔄 *Audit in progress* by [Audit Firm Name]
- 🐛 *Bug Bounty:* Contact security@gaia.eco

### Key Security Features

1. *ReentrancyGuard* on all state-changing functions
2. *Pausable* emergency stop on critical contracts
3. *Collateral slashing* for malicious operators
4. *Timelock governance* for parameter changes
5. *Multisig admin* for protocol upgrades

---

## 🌐 Deployed Applications

### Testnet

- *Frontend:* https://testnet.gaia.eco
- *Block Explorer:* https://explorer.gaial3.network
- *Bridge:* https://bridge.gaia.eco
- *Subgraph:* https://thegraph.com/hosted-service/subgraph/gaia/testnet

### Mainnet (Coming Soon)

- TBA

---

## 📖 Documentation

- *[Architecture Overview](./docs/ARCHITECTURE.md)* - System design and contract interactions
- *[User Flows](./docs/USER_FLOWS.md)* - Step-by-step user journeys
- *[OP Stack Setup](./docs/OP_STACK_SETUP.md)* - Deploy your own L3
- *[Economic Model](./docs/ECONOMIC_MODEL.md)* - Tokenomics and value flow
- *[API Reference](./docs/API.md)* - Smart contract interfaces

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

### Development Workflow

bash
# 1. Fork the repository
# 2. Create a feature branch
git checkout -b feature/amazing-feature

# 3. Make changes and test
pnpm test

# 4. Commit with conventional commits
git commit -m "feat: add amazing feature"

# 5. Push and create PR
git push origin feature/amazing-feature


---

## 🏆 Hackathon Wins

- 🥇 *ETHGlobal 2024* - Best ReFi Project
- 🥈 *Celo Hackathon* - Most Innovative Use of Celo
- 🥉 *OP Stack Builders* - Best L3 Application

---

## 🗺 Roadmap

### Q4 2025
- ✅ Core contracts deployed to Celo Alfajores
- ✅ MVP frontend live
- ✅ Local OP Stack L3 running
- 🔄 Security audit ongoing

### Q1 2026
- 🎯 Deploy Gaia L3 mainnet
- 🎯 Onboard first 100 tasks
- 🎯 Launch $IMPACT token
- 🎯 Mobile app (iOS/Android)

### Q2 2026
- 🎯 Oracle integrations (Chainlink, Pyth)
- 🎯 AI model marketplace
- 🎯 Cross-chain bridges (Ethereum, Polygon)

### Q3 2026
- 🎯 Institutional partnerships
- 🎯 1M+ tons CO₂ verified
- 🎯 DAO treasury >$1M

---

## 👥 Team

- *Founder:* [Your Name] - [@twitter](https://twitter.com/you)
- *CTO:* [Co-founder] - [@github](https://github.com/cofounder)
- *Advisors:* Climate experts, Blockchain devs, ReFi veterans

---

## 💬 Community

- *Discord:* https://discord.gg/gaia
- *Twitter:* https://twitter.com/GaiaProtocol
- *Telegram:* https://t.me/gaiaprotocol
- *Forum:* https://forum.gaia.eco

---

## 📄 License

This project is licensed under MIT License - see [LICENSE](./LICENSE) file for details.

---

## 🙏 Acknowledgments

- *Optimism* - OP Stack framework
- *Celo* - Mobile-first blockchain infrastructure  
- *OpenZeppelin* - Secure smart contract libraries
- *The Graph* - Decentralized indexing
- *IPFS/Filecoin* - Decentralized storage

---

## 💡 Why OP Stack L3?

| Feature | Gaia L3 | Celo L2 | Ethereum L1 |
|---------|---------|---------|-------------|
| Block Time | 2s | 5s | 12s |
| Gas Cost | $0.0001 | $0.01 | $5-50 |
| TPS | 1000+ | 100+ | 15-30 |
| Custom Gas Token | ✅ $IMPACT | ❌ | ❌ |
| Dedicated Blockspace | ✅ | ❌ | ❌ |
| Proof of Impact | ✅ | ❌ | ❌ |

*Bottom Line:* We need speed, low cost, and custom consensus. L3 gives us all three while inheriting Ethereum's security.

---

## 🚨 Disclaimer

Gaia is experimental software in active development. Use at your own risk. Carbon credits are NOT financial securities. This is NOT investment advice. Always DYOR.

---

<div align="center">

*Built with 💚 for the planet*

[Website](https://gaia.eco) • [Docs](https://docs.gaia.eco) • [Twitter](https://twitter.com/GaiaProtocol) • [Discord](https://discord.gg/gaia)

</div>
