const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("========================================");
  console.log("Initializing L2 Contracts");
  console.log("========================================\n");

  const [deployer] = await hre.ethers.getSigners();
  console.log("Initializing with account:", deployer.address);

  // Read deployed addresses (try new path first, fall back to old path)
  let addressesPath = path.join(__dirname, "../../l2-deployment/arx-contracts.json");
  if (!fs.existsSync(addressesPath)) {
    addressesPath = path.join(__dirname, "../deployments/l2-addresses.json");
  }
  if (!fs.existsSync(addressesPath)) {
    console.error("❌ Deployed addresses file not found. Run deploy-l2.js first.");
    process.exit(1);
  }

  const addresses = JSON.parse(fs.readFileSync(addressesPath, "utf8"));
  console.log("\nLoaded addresses from:", addressesPath);
  console.log(JSON.stringify(addresses, null, 2));

  const gasConfig = { gasLimit: 5000000, gasPrice: 1000000000 };

  // Get contract instances
  const TaskRegistry = await hre.ethers.getContractFactory("TaskRegistry");
  const taskRegistry = TaskRegistry.attach(addresses.TaskRegistry);

  const FundingPool = await hre.ethers.getContractFactory("FundingPool");
  const fundingPool = FundingPool.attach(addresses.FundingPool);

  const CollateralManager = await hre.ethers.getContractFactory("CollateralManager");
  const collateralManager = CollateralManager.attach(addresses.CollateralManager);

  const VerificationManager = await hre.ethers.getContractFactory("VerificationManager");
  const verificationManager = VerificationManager.attach(addresses.VerificationManager);

  const CarbonCreditMinter = await hre.ethers.getContractFactory("CarbonCreditMinter");
  const carbonCreditMinter = CarbonCreditMinter.attach(addresses.CarbonCreditMinter);

  const DataRegistry = await hre.ethers.getContractFactory("DataRegistry");
  const dataRegistry = DataRegistry.attach(addresses.DataRegistry);

  const ModelRegistry = await hre.ethers.getContractFactory("ModelRegistry");
  const modelRegistry = ModelRegistry.attach(addresses.ModelRegistry);

  // Initialize TaskRegistry with dependent contracts
  console.log("\n1. Setting FundingPool address on TaskRegistry...");
  try {
    const tx1 = await taskRegistry.setFundingPool(addresses.FundingPool, gasConfig);
    await tx1.wait();
    console.log("   ✅ FundingPool set");
  } catch (error) {
    console.error("   ❌ Error:", error.message);
  }

  console.log("\n2. Setting CollateralManager address on TaskRegistry...");
  try {
    const tx2 = await taskRegistry.setCollateralManager(addresses.CollateralManager, gasConfig);
    await tx2.wait();
    console.log("   ✅ CollateralManager set");
  } catch (error) {
    console.error("   ❌ Error:", error.message);
  }

  console.log("\n3. Setting VerificationManager address on TaskRegistry...");
  try {
    const tx3 = await taskRegistry.setVerificationManager(addresses.VerificationManager, gasConfig);
    await tx3.wait();
    console.log("   ✅ VerificationManager set");
  } catch (error) {
    console.error("   ❌ Error:", error.message);
  }

  // Initialize VerificationManager with CarbonCreditMinter
  console.log("\n4. Setting CarbonCreditMinter on VerificationManager...");
  try {
    const tx4 = await verificationManager.setCarbonCreditMinter(addresses.CarbonCreditMinter, gasConfig);
    await tx4.wait();
    console.log("   ✅ CarbonCreditMinter set");
  } catch (error) {
    console.error("   ❌ Error:", error.message);
  }

  // Initialize DataRegistry with VerificationManager
  console.log("\n5. Setting VerificationManager on DataRegistry...");
  try {
    const tx5 = await dataRegistry.setVerificationManager(addresses.VerificationManager, gasConfig);
    await tx5.wait();
    console.log("   ✅ VerificationManager set on DataRegistry");
  } catch (error) {
    console.error("   ❌ Error:", error.message);
  }

  // Initialize ModelRegistry with VerificationManager
  console.log("\n6. Setting VerificationManager on ModelRegistry...");
  try {
    const tx6 = await modelRegistry.setVerificationManager(addresses.VerificationManager, gasConfig);
    await tx6.wait();
    console.log("   ✅ VerificationManager set on ModelRegistry");
  } catch (error) {
    console.error("   ❌ Error:", error.message);
  }

  // Initialize CollateralManager with VerificationManager
  console.log("\n7. Setting VerificationManager on CollateralManager...");
  try {
    const tx7 = await collateralManager.setVerificationManager(addresses.VerificationManager, gasConfig);
    await tx7.wait();
    console.log("   ✅ VerificationManager set on CollateralManager");
  } catch (error) {
    console.error("   ❌ Error:", error.message);
  }

  // Unpause all pausable contracts
  console.log("\n8. Unpausing all contracts...");
  const pausableContracts = [
    { name: "TaskRegistry", contract: taskRegistry },
    { name: "FundingPool", contract: fundingPool },
    { name: "CollateralManager", contract: collateralManager },
    { name: "VerificationManager", contract: verificationManager },
    { name: "CarbonCreditMinter", contract: carbonCreditMinter },
  ];

  for (const { name, contract } of pausableContracts) {
    try {
      const isPaused = await contract.paused();
      if (isPaused) {
        console.log(`   Unpausing ${name}...`);
        const tx = await contract.unpause(gasConfig);
        await tx.wait();
        console.log(`   ✅ ${name} unpaused`);
      } else {
        console.log(`   ✅ ${name} already unpaused`);
      }
    } catch (error) {
      console.error(`   ❌ Error unpausing ${name}:`, error.message);
    }
  }

  console.log("\n========================================");
  console.log("✅ All ARX Protocol Contracts Initialized!");
  console.log("========================================\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
