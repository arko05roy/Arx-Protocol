const hre = require("hardhat");

async function main() {
  console.log("🚀 DEPLOYING CONTRACTS TO L3 CHAIN (424242)");
  console.log("");

  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("");

  const contracts = {};

  // Deploy MockERC20
  console.log("1️⃣ Deploying MockERC20...");
  const MockERC20 = await ethers.getContractFactory("MockERC20");
  const mockERC20 = await MockERC20.deploy();
  await mockERC20.deployed();
  contracts.MockERC20 = mockERC20.address;
  console.log("✅ MockERC20:", mockERC20.address);
  console.log("");

  // Deploy DataRegistry
  console.log("2️⃣ Deploying DataRegistry...");
  const DataRegistry = await ethers.getContractFactory("DataRegistry");
  const dataRegistry = await DataRegistry.deploy();
  await dataRegistry.deployed();
  contracts.DataRegistry = dataRegistry.address;
  console.log("✅ DataRegistry:", dataRegistry.address);
  console.log("");

  // Deploy ModelRegistry
  console.log("3️⃣ Deploying ModelRegistry...");
  const ModelRegistry = await ethers.getContractFactory("ModelRegistry");
  const modelRegistry = await ModelRegistry.deploy();
  await modelRegistry.deployed();
  contracts.ModelRegistry = modelRegistry.address;
  console.log("✅ ModelRegistry:", modelRegistry.address);
  console.log("");

  // Deploy TaskRegistry
  console.log("4️⃣ Deploying TaskRegistry...");
  const TaskRegistry = await ethers.getContractFactory("TaskRegistry");
  const taskRegistry = await TaskRegistry.deploy();
  await taskRegistry.deployed();
  contracts.TaskRegistry = taskRegistry.address;
  console.log("✅ TaskRegistry:", taskRegistry.address);
  console.log("");

  // Deploy VerificationManager
  console.log("5️⃣ Deploying VerificationManager...");
  const VerificationManager = await ethers.getContractFactory("VerificationManager");
  const verificationManager = await VerificationManager.deploy();
  await verificationManager.deployed();
  contracts.VerificationManager = verificationManager.address;
  console.log("✅ VerificationManager:", verificationManager.address);
  console.log("");

  // Deploy CollateralManager
  console.log("6️⃣ Deploying CollateralManager...");
  const CollateralManager = await ethers.getContractFactory("CollateralManager");
  const collateralManager = await CollateralManager.deploy();
  await collateralManager.deployed();
  contracts.CollateralManager = collateralManager.address;
  console.log("✅ CollateralManager:", collateralManager.address);
  console.log("");

  // Deploy FundingPool
  console.log("7️⃣ Deploying FundingPool...");
  const FundingPool = await ethers.getContractFactory("FundingPool");
  const fundingPool = await FundingPool.deploy();
  await fundingPool.deployed();
  contracts.FundingPool = fundingPool.address;
  console.log("✅ FundingPool:", fundingPool.address);
  console.log("");

  // Deploy CarbonCreditMinter
  console.log("8️⃣ Deploying CarbonCreditMinter...");
  const CarbonCreditMinter = await ethers.getContractFactory("CarbonCreditMinter");
  const carbonCreditMinter = await CarbonCreditMinter.deploy();
  await carbonCreditMinter.deployed();
  contracts.CarbonCreditMinter = carbonCreditMinter.address;
  console.log("✅ CarbonCreditMinter:", carbonCreditMinter.address);
  console.log("");

  // Deploy CarbonMarketplace
  console.log("9️⃣ Deploying CarbonMarketplace...");
  const CarbonMarketplace = await ethers.getContractFactory("CarbonMarketplace");
  const carbonMarketplace = await CarbonMarketplace.deploy();
  await carbonMarketplace.deployed();
  contracts.CarbonMarketplace = carbonMarketplace.address;
  console.log("✅ CarbonMarketplace:", carbonMarketplace.address);
  console.log("");

  // Deploy PredictionMarketplace
  console.log("🔟 Deploying PredictionMarketplace...");
  const PredictionMarketplace = await ethers.getContractFactory("PredictionMarketplace");
  const predictionMarketplace = await PredictionMarketplace.deploy();
  await predictionMarketplace.deployed();
  contracts.PredictionMarketplace = predictionMarketplace.address;
  console.log("✅ PredictionMarketplace:", predictionMarketplace.address);
  console.log("");

  // Deploy GovernanceDAO
  console.log("1️⃣1️⃣ Deploying GovernanceDAO...");
  const GovernanceDAO = await ethers.getContractFactory("GovernanceDAO");
  const governanceDAO = await GovernanceDAO.deploy();
  await governanceDAO.deployed();
  contracts.GovernanceDAO = governanceDAO.address;
  console.log("✅ GovernanceDAO:", governanceDAO.address);
  console.log("");

  // Deploy Treasury
  console.log("1️⃣2️⃣ Deploying Treasury...");
  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy();
  await treasury.deployed();
  contracts.Treasury = treasury.address;
  console.log("✅ Treasury:", treasury.address);
  console.log("");

  console.log("════════════════════════════════════════════");
  console.log("✅ ALL CONTRACTS DEPLOYED SUCCESSFULLY");
  console.log("════════════════════════════════════════════");
  console.log("");
  console.log("📋 DEPLOYMENT ADDRESSES:");
  console.log(JSON.stringify(contracts, null, 2));

  // Save to file
  const fs = require("fs");
  fs.writeFileSync(
    "deployed-l3-addresses.json",
    JSON.stringify(contracts, null, 2)
  );
  console.log("");
  console.log("✅ Addresses saved to deployed-l3-addresses.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
