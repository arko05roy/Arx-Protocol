const hre = require("hardhat");

async function main() {
  console.log("🚀 DEPLOYING CONTRACTS TO L3 CHAIN (424242)");
  console.log("");

  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("");

  const contracts = {};

  // Deploy Treasury first (no args)
  console.log("1️⃣ Deploying Treasury...");
  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy();
  await treasury.deployed();
  contracts.Treasury = treasury.address;
  console.log("✅ Treasury:", treasury.address);
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

  console.log("════════════════════════════════════════════");
  console.log("✅ SAMPLE CONTRACTS DEPLOYED");
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
