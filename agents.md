# Arx Protocol Agents Documentation

## Overview

This document describes the various agent roles and autonomous actors within the Arx Protocol ecosystem. The protocol enables verifiable environmental impact through a decentralized network of agents, each with specific responsibilities and incentives.

---

## Table of Contents

1. [Core Agent Roles](#core-agent-roles)
2. [Agent Workflows](#agent-workflows)
3. [Agent Incentives](#agent-incentives)
4. [Agent Requirements](#agent-requirements)
5. [Agent Reputation System](#agent-reputation-system)
6. [Advanced Agent Features](#advanced-agent-features)

---

## Core Agent Roles

### 1. Task Proposers

**Description:** Entities that create environmental project proposals seeking funding.

**Typical Actors:**
- NGOs and environmental organizations
- Local community groups
- Environmental startups
- Conservation teams

**Capabilities:**
- Create task proposals with detailed specifications
- Upload project documentation to IPFS
- Define proof requirements and success criteria
- Set estimated costs and expected CO₂ offsets
- Track funding progress

**Responsibilities:**
- Provide accurate project information
- Define clear, verifiable success criteria
- Specify realistic timelines and budgets
- Upload comprehensive project documentation

**Smart Contract Interactions:**
- `TaskRegistry.createTask()`
- Read funding status from `FundingPool`

**Example Task Creation:**
```solidity
TaskRegistry.createTask({
    description: "Plant 10,000 mangroves in Pichavaram",
    estimatedCost: 50000e18,  // 50,000 cUSD
    expectedCO2: 500,          // 500 tons
    location: "Tamil Nadu, India",
    deadline: block.timestamp + 90 days,
    proofRequirements: "GPS photos, drone imagery, local attestation",
    ipfsHash: "QmXYZ..."
})
```

---

### 2. Funders (Impact Investors)

**Description:** Individuals or organizations that provide capital for environmental projects in exchange for carbon credits.

**Typical Actors:**
- Individual climate activists
- Companies seeking ESG compliance
- Climate funds and impact investors
- DAOs focused on environmental causes

**Capabilities:**
- Browse and discover proposed tasks
- Participate in fractional funding (any amount)
- Receive proportional carbon credits upon verification
- Trade carbon credits on marketplace
- Vote in governance with credit-weighted voting power
- Withdraw funding from unfunded tasks (with penalty)

**Responsibilities:**
- Due diligence on task proposals
- Monitor task progress
- Participate in dispute resolution if needed

**Smart Contract Interactions:**
- `cUSD.approve(FundingPool, amount)`
- `FundingPool.fundTask(taskId, amount)`
- `FundingPool.withdrawFunding(taskId)` (only if task not funded)
- `CarbonMarketplace.createSellOrder()` or `buyCredits()`
- `GovernanceDAO.vote(proposalId, support)`

**Funding Share Calculation:**
```
userSharePercent = userFundingAmount / totalTaskFunding
creditAllocation = totalCreditsMinted * userSharePercent
```

---

### 3. Operators (Task Executors)

**Description:** Skilled entities that execute environmental work and provide proof of impact.

**Typical Actors:**
- Tree planting companies
- Renewable energy installers
- Conservation teams
- Environmental engineering firms
- Local community cooperatives

**Capabilities:**
- Browse available funded tasks
- Accept tasks by staking collateral (10% of task value)
- Execute environmental work off-chain
- Collect evidence (GPS data, photos, videos, sensor data)
- Submit proof of completion to IPFS
- Receive payment upon successful verification

**Responsibilities:**
- Execute work according to task specifications
- Provide comprehensive, verifiable proof
- Meet project deadlines
- Maintain high-quality work standards
- Risk losing collateral if work is fraudulent

**Smart Contract Interactions:**
- `CollateralManager.registerOperator()`
- `CollateralManager.stakeForTask(taskId)`
- `TaskRegistry.submitProofOfWork(taskId, proofHash, actualCO2)`

**Collateral Requirements:**
```
requiredStake = (task.estimatedCost * 10) / 100
// Example: 50,000 cUSD task = 5,000 cUSD collateral required
```

**Payment Distribution:**
```
operatorPayment = totalFunding * 98%  // 2% platform fee
// Example: 50,000 cUSD funded = 49,000 cUSD to operator
```

**Risk/Reward:**
- **Success:** Receive 98% of funding + stake returned + data reward
- **Failure/Fraud:** Lose entire stake + banned from platform

---

### 4. Validators

**Description:** Trusted reviewers who verify the authenticity and quality of submitted work.

**Typical Actors:**
- Environmental experts
- GIS specialists
- Independent auditors
- DAO members with expertise
- Technical verification services

**Capabilities:**
- Receive random task assignments for verification
- Download and review proof bundles from IPFS
- Cross-reference with external data sources (satellite imagery, weather data)
- Vote APPROVE or REJECT with confidence scores
- Provide detailed justification for decisions
- Earn fees for verification work

**Responsibilities:**
- Thoroughly review all submitted evidence
- Apply consistent verification standards
- Vote within deadline (typically 7 days)
- Provide clear reasoning for decisions
- Risk reputation/stake if consistently wrong

**Smart Contract Interactions:**
- `VerificationManager.submitValidatorVote(taskId, approve, justification, confidence)`

**Verification Process:**
```
1. Assigned to task (randomly selected from approved validator pool)
2. Download proof from IPFS (typically 4-8 hours of review work)
3. Cross-reference with external data:
   - Satellite imagery (before/after comparison)
   - GPS coordinate validation
   - Timestamp consistency checks
   - Scientific accuracy of CO₂ claims
4. Submit vote with confidence score (0-100%)
5. Receive payment upon task finalization
```

**Consensus Mechanism:**
```
requiredValidators = 3 (configurable via governance)
consensusThreshold = 66%

Example Outcomes:
- 3 FOR, 0 AGAINST → APPROVED (100% consensus)
- 2 FOR, 1 AGAINST → APPROVED (66.7% consensus)
- 1 FOR, 2 AGAINST → REJECTED (33.3% consensus)
- 0 FOR, 3 AGAINST → REJECTED (0% consensus)
```

**Compensation:**
```
baseValidatorFee = 50 cUSD per task
additionalRewards = based on accuracy over time
penaltyForWrongVotes = 50% stake slash if overruled by DAO
```

---

### 5. Prediction Market Participants

**Description:** Traders who speculate on task success/failure before verification completes.

**Typical Actors:**
- Market speculators
- Information-informed community members
- Risk hedgers (operators hedging failure)
- Arbitrageurs

**Capabilities:**
- Trade YES/NO shares on task outcomes
- Provide early signals on project viability
- Claim winnings when markets resolve
- Influence community sentiment

**Responsibilities:**
- Perform due diligence on task likelihood
- Provide liquidity for price discovery

**Smart Contract Interactions:**
- `PredictionMarket.buyShares(taskId, amount, isYes)`
- `PredictionMarket.sellShares(taskId, amount, isYes)`
- `PredictionMarket.claimWinnings(taskId)`

**Market Mechanics:**
```
Automated Market Maker (AMM) Model:
- Initial odds: 50% YES / 50% NO
- Odds adjust based on buy/sell pressure
- Market resolves when task verification finalizes

Example Trade:
Alice buys 1,000 cUSD of YES shares at 70% odds
Cost: ~700 cUSD for 1,000 shares

If task succeeds:
  Alice's payout = (1,000 / totalYesShares) * totalPool

If task fails:
  Alice loses 700 cUSD
```

---

### 6. Carbon Credit Traders

**Description:** Buyers and sellers of verified carbon credits in the marketplace.

**Typical Actors:**
- Companies offsetting emissions
- Carbon credit brokers
- Market makers providing liquidity
- Speculators on carbon prices

**Capabilities:**
- Create sell orders with custom pricing
- Buy credits from order book
- Retire credits for ESG compliance
- Provide liquidity via AMM pools

**Responsibilities:**
- Maintain fair market pricing
- Provide liquidity for credit holders

**Smart Contract Interactions:**
- `CarbonMarketplace.createSellOrder(tokenId, amount, pricePerCredit)`
- `CarbonMarketplace.buyCredits(orderId, amount)`
- `CarbonCreditMinter.burnCredits(tokenId, amount)` (for retirement)

**Trading Example:**
```
Seller lists 100 carbon credits at 50 cUSD/credit
Buyer purchases 25 credits
  → Pays: 25 * 50 = 1,250 cUSD
  → Receives: 25 ERC1155 tokens (credit tokenId)
  → Marketplace fee: 0.5% = 6.25 cUSD
```

---

### 7. Governance Participants (DAO Members)

**Description:** Carbon credit holders who vote on protocol parameters and disputes.

**Typical Actors:**
- Carbon credit holders (funders)
- Long-term protocol stakeholders
- Community members with voting tokens

**Capabilities:**
- Create governance proposals (with bond requirement)
- Vote on protocol parameters (weighted by credit holdings)
- Resolve verification disputes
- Allocate treasury funds
- Update validator requirements and fees

**Responsibilities:**
- Review proposals thoroughly
- Vote in protocol's best interest
- Participate in dispute resolution

**Smart Contract Interactions:**
- `GovernanceDAO.createProposal(description, targetContract, callData, bond)`
- `GovernanceDAO.vote(proposalId, support)`
- `GovernanceDAO.executeProposal(proposalId)`

**Voting Power:**
```
votingPower = numberOfCreditTokensHeld
// Example: Hold 42.5 credit tokens = 42.5 votes

Quorum requirement: 20% of total credits must vote
Passing threshold: >50% FOR votes
Voting period: 7 days (standard), 5 days (disputes)
```

**Example Proposals:**
- Change required validators from 3 to 5
- Adjust platform fee from 2% to 1.5%
- Update validator compensation
- Approve emergency contract upgrades
- Resolve verification disputes

---

### 8. Data Scientists & AI Researchers

**Description:** Researchers who use verified environmental data and stake AI models for predictions.

**Typical Actors:**
- Climate scientists
- Machine learning researchers
- Academic institutions
- Environmental data analysts

**Capabilities:**
- Access open dataset of verified tasks
- Train fraud detection models
- Register models on-chain with stake
- Earn rewards for accurate predictions
- Contribute to verification accuracy

**Responsibilities:**
- Maintain model accuracy
- Update models with new data
- Stake capital on model performance

**Smart Contract Interactions:**
- `DataRegistry.queryDataset(filters)`
- `ModelRegistry.registerModel(ipfsHash, description, stake)`
- `ModelRegistry.recordPrediction(modelId, taskId, prediction)`

**Model Performance Tracking:**
```
accuracy = correctPredictions / totalPredictions
modelReward = baseFee * (modelStake / 1000)

If accuracy drops below 70%:
  → Model flagged for review
  → Stake gradually reduced

If accuracy > 90%:
  → Increased weight in verification
  → Higher rewards
  → Featured in validator dashboards
```

---

## Agent Workflows

### Workflow 1: Complete Task Lifecycle

```
1. PROPOSER creates task
   ↓
2. FUNDERS provide capital (fractional allowed)
   ↓
3. PREDICTION MARKET TRADERS speculate on success
   ↓
4. OPERATOR accepts task & stakes collateral
   ↓
5. OPERATOR executes work (off-chain, 3 months)
   ↓
6. OPERATOR submits proof to IPFS
   ↓
7. VALIDATORS review evidence (3 validators)
   ↓
8. VALIDATORS vote APPROVE/REJECT
   ↓
9. Consensus reached → Task VERIFIED
   ↓
10. OPERATOR receives payment
11. FUNDERS receive carbon credits
12. PREDICTION MARKET resolves
13. DATA SCIENTISTS access new dataset
14. TRADERS buy/sell credits
```

---

### Workflow 2: Dispute Resolution

```
1. Task verification completes with 2-1 vote
   ↓
2. OPERATOR disputes within 48 hours
   ↓
3. OPERATOR uploads additional evidence + 500 cUSD fee
   ↓
4. DAO MEMBERS review all evidence
   ↓
5. GOVERNANCE VOTE (5 days)
   ↓
6. If DAO overrides:
   → Task approved
   → Dissenting validator penalized
   → Operator receives payment

   If DAO upholds:
   → Task rejected
   → Operator loses stake + dispute fee
   → Funders get refunds
```

---

## Agent Incentives

### Proposer Incentives
- ✅ Access to decentralized funding
- ✅ Transparent impact tracking
- ✅ No intermediary fees (only 2% platform fee)

### Funder Incentives
- ✅ Tokenized carbon credits (tradeable assets)
- ✅ Verified real-world impact
- ✅ Governance rights
- ✅ ESG compliance documentation
- ✅ Potential appreciation of credit value

### Operator Incentives
- ✅ Access to capital (up to 50k+ per task)
- ✅ Crypto payments (fast settlement)
- ✅ Reputation building
- ✅ Data contribution rewards
- ⚠️ Risk: Lose 10% stake if fraudulent

### Validator Incentives
- ✅ ~50 cUSD per task (4-8 hours work = $12.50/hr)
- ✅ Reputation score growth
- ✅ Priority assignment for future tasks
- ⚠️ Risk: 50% stake slash if proven wrong in disputes

### Trader Incentives
- ✅ Prediction market profits (43% avg ROI if correct)
- ✅ Carbon credit speculation/arbitrage
- ✅ Liquidity provision fees (0.3% AMM)

### DAO Member Incentives
- ✅ Protocol governance influence
- ✅ Treasury allocation decisions
- ✅ Dispute resolution compensation
- ✅ Long-term protocol value accrual

### Researcher Incentives
- ✅ Open dataset access (free)
- ✅ Model staking rewards
- ✅ Citation in scientific work
- ✅ Improved verification accuracy

---

## Agent Requirements

### Operator Registration Requirements
```solidity
CollateralManager.registerOperator({
    minimumStake: 10,000 cUSD equivalent,
    kycVerified: true (optional, DAO decision),
    pastExperience: recommended but not enforced,
    walletReputation: checked via on-chain history
})
```

### Validator Registration Requirements
```solidity
VerificationManager.registerValidator({
    minimumStake: 5,000 cUSD,
    expertise: environmental science / GIS / auditing,
    kycRequired: optional,
    accuracyThreshold: 75% (after first 10 tasks)
})
```

### Model Registry Requirements
```solidity
ModelRegistry.registerModel({
    minimumStake: 1,000 cUSD,
    ipfsModelHash: "QmMODEL...",
    description: "Model architecture and purpose",
    initialAccuracyTarget: 70%
})
```

---

## Agent Reputation System

### Operator Reputation Scoring
```
score = (
    completedTasks * 10 +
    averageVerificationConfidence * 2 +
    onTimeCompletion * 5 +
    dataQuality * 3
) - (
    rejectedTasks * 50 +
    missedDeadlines * 20
)

Reputation Tiers:
- Bronze (0-100): Can accept tasks up to 10k cUSD
- Silver (101-500): Can accept tasks up to 50k cUSD
- Gold (501-1000): Can accept tasks up to 100k cUSD
- Platinum (1001+): Can accept unlimited tasks
```

### Validator Reputation Scoring
```
score = (
    correctVotes / totalVotes * 100
) + consistencyBonus

Validator Tiers:
- Novice (<75% accuracy): Low priority assignment
- Verified (75-85%): Standard assignment
- Expert (85-95%): High priority + bonus pay
- Master (>95%): Premium tasks + 2x pay
```

### Funder Reputation (Social Metrics)
```
- Total funded: tracked on-chain
- Number of tasks funded
- Governance participation rate
- Average hold time of credits

Benefits:
- Early access to high-impact tasks
- Discounted marketplace fees
- Priority governance proposal review
```

---

## Advanced Agent Features

### 1. Oracle Integration

**Oracle Agents** provide automated verification data:

```
Satellite Imagery Oracles:
- Provider: Planet Labs, Sentinel, Landsat
- Data: NDVI (vegetation index), land use change
- Trigger: Task proof submitted
- Cost: 20-100 cUSD per task

IoT Sensor Oracles:
- Provider: Chainlink IoT adapters
- Data: Soil moisture, air quality, temperature
- Update frequency: Real-time during task execution
- Cost: 5-50 cUSD per task

Weather Data Oracles:
- Provider: OpenWeatherMap, NOAA
- Data: Validates planting dates, conditions
- Cost: 1-5 cUSD per query
```

**Oracle Workflow:**
```
1. Operator submits proof
2. VerificationManager requests oracle data
3. Oracle queries external APIs
4. Oracle submits result on-chain
5. Weighted combination with validator votes:
   finalScore = (validatorScore * 0.6) + (oracleScore * 0.4)
```

---

### 2. AI Model Agents

**Autonomous ML Models** assist verification:

```python
class FraudDetectionAgent:
    def __init__(self, model_id, stake_amount):
        self.model_id = model_id
        self.stake = stake_amount
        self.accuracy_history = []

    def predict_task_success(self, task_data):
        features = extract_features(task_data)
        # Features: GPS density, photo timestamps, operator history, etc.

        prediction = self.model.predict(features)
        confidence = self.model.predict_proba(features)

        return {
            'prediction': prediction,  # True/False
            'confidence': confidence,  # 0.0-1.0
            'model_id': self.model_id
        }

    def submit_prediction_onchain(self, task_id, prediction):
        ModelRegistry.recordPrediction(
            self.model_id,
            task_id,
            prediction
        )

    def claim_rewards_if_correct(self, task_id):
        if self.was_correct(task_id):
            reward = calculate_reward(self.stake, accuracy)
            ModelRegistry.claimReward(self.model_id, task_id)
```

**Model Lifecycle:**
1. Researcher trains model on historical data
2. Model uploaded to IPFS, registered on-chain with stake
3. Inference service monitors new tasks
4. Model makes predictions before human verification
5. Validators see model predictions (not binding)
6. After verification, model accuracy updated
7. Accurate models earn rewards, inaccurate models lose stake

---

### 3. Automated Market Makers (AMM) for Credits

**Liquidity Provider Agents:**

```solidity
// LP deposits credits + cUSD to create trading pool
CarbonAMM.createPool({
    creditTokenId: 1,
    creditAmount: 100,
    cUSDAmount: 5000
});

// Constant product formula: x * y = k
// Initial price: 5000 / 100 = 50 cUSD per credit

// Traders swap against pool
CarbonAMM.swapCreditForUSD({
    creditIn: 10,
    minUSDOut: 400  // slippage protection
});

// LPs earn 0.3% fee on all trades
// Can withdraw liquidity + fees anytime
```

---

### 4. Multi-Sig Operator Groups

**Collaborative Operators:**

```solidity
// Register multi-sig wallet as operator
address[] memory signers = [address1, address2, address3];
uint256 threshold = 2;  // 2-of-3 multisig

CollateralManager.registerMultiSigOperator({
    multiSigAddress: createMultiSig(signers, threshold),
    signers: signers,
    threshold: threshold
});

// All operator actions require threshold signatures
// Example: 2 team members must approve proof submission
```

**Use Cases:**
- Large environmental projects requiring team collaboration
- Added accountability (multiple people must approve submissions)
- Fraud prevention within operator teams

---

## Agent Communication Patterns

### Event-Driven Architecture

All agents listen to blockchain events:

```javascript
// Proposer monitors funding
TaskRegistry.on("FundingReceived", (taskId, funder, amount) => {
    updateFundingUI(taskId, amount);
});

// Operator discovers tasks
TaskRegistry.on("TaskStatusChanged", (taskId, newStatus) => {
    if (newStatus === "Funded") {
        notifyOperatorOfOpportunity(taskId);
    }
});

// Validators receive assignments
VerificationManager.on("ValidatorAssigned", (taskId, validator) => {
    if (validator === myAddress) {
        downloadProofAndStartReview(taskId);
    }
});

// Funders track credit minting
CarbonCreditMinter.on("CreditsMinted", (taskId, tokenId, amount) => {
    updateUserDashboard(tokenId, amount);
});

// Prediction market updates
PredictionMarket.on("SharesPurchased", (taskId, buyer, amount, isYes) => {
    updateOddsDisplay(taskId);
});
```

---

## Security Considerations for Agents

### Operator Security
- **Sybil Resistance:** Minimum stake prevents low-cost fake identities
- **Collateral at Risk:** 10% stake ensures skin in the game
- **Reputation System:** Penalizes repeated failures
- **Fraud Detection:** AI models flag suspicious patterns

### Validator Security
- **Random Assignment:** Prevents collusion
- **Stake Requirement:** 5,000 cUSD minimum prevents cheap attacks
- **Dispute Mechanism:** DAO can override incorrect votes
- **Accuracy Tracking:** Low performers demoted/removed

### Funder Protection
- **Verified Operators Only:** Registration required
- **Transparent Proof:** All evidence publicly viewable on IPFS
- **Refund Mechanism:** If task fails, funders get cUSD back
- **Governance Rights:** Vote to update protocol security

### Smart Contract Security
- **ReentrancyGuard:** All state-changing functions protected
- **Pausable:** Emergency stop for critical contracts
- **Access Control:** Role-based permissions (onlyOwner, onlyValidator)
- **Time Locks:** Governance changes have delay
- **Multi-Sig Admin:** Protocol upgrades require multiple signatures

---

## Future Agent Enhancements

### Planned Enhancements (2026 Roadmap)

1. **Autonomous Oracle Agents**
   - Fully on-chain satellite data verification
   - Real-time IoT sensor integration
   - Automated weather validation

2. **AI Validator Agents**
   - Machine learning models as primary validators
   - Human validators as oversight only
   - Faster verification (hours instead of days)

3. **Cross-Chain Agents**
   - Bridge operators for Ethereum ↔ Arx L3
   - Multi-chain credit trading
   - Unified reputation across chains

4. **Mobile Operator Apps**
   - iOS/Android apps for field operators
   - GPS auto-capture during work
   - Offline-first proof collection
   - One-tap proof submission

5. **Institutional Agent APIs**
   - Direct API for large funders
   - Automated ESG reporting
   - Bulk credit purchasing
   - Portfolio management

6. **Prediction Market Market Makers**
   - Automated bots providing liquidity
   - Arbitrage between prediction odds and credit prices
   - Risk-hedging for operators

---

## Conclusion

Arx Protocol's agent ecosystem creates a self-sustaining network of aligned incentives:

- **Proposers** gain access to decentralized funding
- **Funders** receive verified carbon credits
- **Operators** earn competitive payments for environmental work
- **Validators** get compensated for expert review
- **Traders** provide liquidity and price discovery
- **DAO Members** govern protocol evolution
- **Researchers** access open environmental datasets

Each agent is economically incentivized to act honestly, creating a robust system for verifying real-world environmental impact on-chain.

---

## Contact & Resources

- **Documentation:** https://docs.arx.eco
- **Smart Contracts:** `/arx/web3/contracts/`
- **Frontend:** `/arx/client/`
- **Community:** Discord, Twitter, Forum
- **GitHub:** https://github.com/your-org/Arx-Protocol

---

*This document is part of the Arx Protocol technical documentation. For implementation details, see the smart contract code and integration guides.*
