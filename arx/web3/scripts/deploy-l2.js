const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("========================================");
  console.log("Deploying Gaia Protocol to L2");
  console.log("========================================\n");

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);
  
  try {
    const balance = await hre.ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", hre.ethers.formatEther(balance), "ETH\n");
  } catch (e) {
    console.log("Account balance: Unable to fetch (L2 node limitation)\n");
  }

  const deployedAddresses = {};

  // Deploy cUSD mock token for L2
  console.log("1. Deploying cUSD Token...");
  const MockERC20 = await hre.ethers.getContractFactory("MockERC20");
  const cUSD = await MockERC20.deploy("Celo Dollar", "cUSD", {
    gasLimit: 5000000,
    gasPrice: 1000000000
  });
  await cUSD.waitForDeployment();
  const cUSDAddress = await cUSD.getAddress();
  console.log("   cUSD deployed to:", cUSDAddress);
  deployedAddresses.cUSD = cUSDAddress;

  // Mint 1,000,000 cUSD to ARX Dapp account for controlled distribution
  const ARX_DAPP_ACCOUNT = "0xabaf59180e0209bdb8b3048bfbe64e855074c0c4";
  console.log("\n   Minting 1,000,000 cUSD to ARX Dapp account:", ARX_DAPP_ACCOUNT);
  const mintAmount = hre.ethers.parseEther("1000000");
  const mintTx = await cUSD.mint(ARX_DAPP_ACCOUNT, mintAmount, { gasLimit: 5000000, gasPrice: 1000000000 });
  await mintTx.wait();
  const arxBalance = await cUSD.balanceOf(ARX_DAPP_ACCOUNT);
  console.log("   ✅ ARX Dapp cUSD balance:", hre.ethers.formatEther(arxBalance));

  // Deploy Treasury
  console.log("\n2. Deploying Treasury...");
  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy({ gasLimit: 5000000, gasPrice: 1000000000 });
  await treasury.waitForDeployment();
  const treasuryAddress = await treasury.getAddress();
  console.log("   Treasury deployed to:", treasuryAddress);
  deployedAddresses.Treasury = treasuryAddress;

  // Deploy TaskRegistry
  console.log("\n3. Deploying TaskRegistry...");
  const TaskRegistry = await hre.ethers.getContractFactory("TaskRegistry");
  const taskRegistry = await TaskRegistry.deploy({ gasLimit: 5000000, gasPrice: 1000000000 });
  await taskRegistry.waitForDeployment();
  const taskRegistryAddress = await taskRegistry.getAddress();
  console.log("   TaskRegistry deployed to:", taskRegistryAddress);
  deployedAddresses.TaskRegistry = taskRegistryAddress;

  // Deploy FundingPool
  console.log("\n4. Deploying FundingPool...");
  const FundingPool = await hre.ethers.getContractFactory("FundingPool");
  const fundingPool = await FundingPool.deploy(cUSDAddress, taskRegistryAddress, treasuryAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await fundingPool.waitForDeployment();
  const fundingPoolAddress = await fundingPool.getAddress();
  console.log("   FundingPool deployed to:", fundingPoolAddress);
  deployedAddresses.FundingPool = fundingPoolAddress;

  // Deploy CollateralManager
  console.log("\n5. Deploying CollateralManager...");
  const CollateralManager = await hre.ethers.getContractFactory("CollateralManager");
  const collateralManager = await CollateralManager.deploy(taskRegistryAddress, treasuryAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await collateralManager.waitForDeployment();
  const collateralManagerAddress = await collateralManager.getAddress();
  console.log("   CollateralManager deployed to:", collateralManagerAddress);
  deployedAddresses.CollateralManager = collateralManagerAddress;

  // Deploy VerificationManager
  console.log("\n6. Deploying VerificationManager...");
  const VerificationManager = await hre.ethers.getContractFactory("VerificationManager");
  const verificationManager = await VerificationManager.deploy(taskRegistryAddress, collateralManagerAddress, fundingPoolAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await verificationManager.waitForDeployment();
  const verificationManagerAddress = await verificationManager.getAddress();
  console.log("   VerificationManager deployed to:", verificationManagerAddress);
  deployedAddresses.VerificationManager = verificationManagerAddress;

  // Deploy CarbonCreditMinter
  console.log("\n7. Deploying CarbonCreditMinter...");
  const CarbonCreditMinter = await hre.ethers.getContractFactory("CarbonCreditMinter");
  const carbonCreditMinter = await CarbonCreditMinter.deploy(taskRegistryAddress, fundingPoolAddress, "https://api.arx.com/metadata/", { gasLimit: 5000000, gasPrice: 1000000000 });
  await carbonCreditMinter.waitForDeployment();
  const carbonCreditMinterAddress = await carbonCreditMinter.getAddress();
  console.log("   CarbonCreditMinter deployed to:", carbonCreditMinterAddress);
  deployedAddresses.CarbonCreditMinter = carbonCreditMinterAddress;

  // Deploy CarbonMarketplace
  console.log("\n8. Deploying CarbonMarketplace...");
  const CarbonMarketplace = await hre.ethers.getContractFactory("CarbonMarketplace");
  const carbonMarketplace = await CarbonMarketplace.deploy(carbonCreditMinterAddress, cUSDAddress, treasuryAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await carbonMarketplace.waitForDeployment();
  const carbonMarketplaceAddress = await carbonMarketplace.getAddress();
  console.log("   CarbonMarketplace deployed to:", carbonMarketplaceAddress);
  deployedAddresses.CarbonMarketplace = carbonMarketplaceAddress;

  // Deploy PredictionMarket
  console.log("\n9. Deploying PredictionMarket...");
  const PredictionMarket = await hre.ethers.getContractFactory("PredictionMarket");
  const predictionMarket = await PredictionMarket.deploy(cUSDAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await predictionMarket.waitForDeployment();
  const predictionMarketAddress = await predictionMarket.getAddress();
  console.log("   PredictionMarket deployed to:", predictionMarketAddress);
  deployedAddresses.PredictionMarket = predictionMarketAddress;

  // Deploy GovernanceDAO
  console.log("\n10. Deploying GovernanceDAO...");
  const GovernanceDAO = await hre.ethers.getContractFactory("GovernanceDAO");
  const governanceDAO = await GovernanceDAO.deploy(carbonCreditMinterAddress, cUSDAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await governanceDAO.waitForDeployment();
  const governanceDAOAddress = await governanceDAO.getAddress();
  console.log("   GovernanceDAO deployed to:", governanceDAOAddress);
  deployedAddresses.GovernanceDAO = governanceDAOAddress;

  // Deploy DataRegistry
  console.log("\n11. Deploying DataRegistry...");
  const DataRegistry = await hre.ethers.getContractFactory("DataRegistry");
  const dataRegistry = await DataRegistry.deploy(taskRegistryAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await dataRegistry.waitForDeployment();
  const dataRegistryAddress = await dataRegistry.getAddress();
  console.log("   DataRegistry deployed to:", dataRegistryAddress);
  deployedAddresses.DataRegistry = dataRegistryAddress;

  // Deploy ModelRegistry
  console.log("\n12. Deploying ModelRegistry...");
  const ModelRegistry = await hre.ethers.getContractFactory("ModelRegistry");
  const modelRegistry = await ModelRegistry.deploy(cUSDAddress, { gasLimit: 5000000, gasPrice: 1000000000 });
  await modelRegistry.waitForDeployment();
  const modelRegistryAddress = await modelRegistry.getAddress();
  console.log("   ModelRegistry deployed to:", modelRegistryAddress);
  deployedAddresses.ModelRegistry = modelRegistryAddress;

  // Save deployed addresses to l2-deployment directory for easy access
  const outputPath = path.join(__dirname, "../../l2-deployment/arx-contracts.json");
  fs.writeFileSync(outputPath, JSON.stringify(deployedAddresses, null, 2));

  // Also save to web3/deployments for backward compatibility
  const backupPath = path.join(__dirname, "../deployments/l2-addresses.json");
  fs.mkdirSync(path.dirname(backupPath), { recursive: true });
  fs.writeFileSync(backupPath, JSON.stringify(deployedAddresses, null, 2));

  console.log("\n========================================");
  console.log("✅ All ARX Protocol Contracts Deployed Successfully!");
  console.log("========================================\n");
  console.log("Contract addresses saved to:");
  console.log("  - " + outputPath);
  console.log("  - " + backupPath);
  console.log("\nContract Addresses:");
  console.log(JSON.stringify(deployedAddresses, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
