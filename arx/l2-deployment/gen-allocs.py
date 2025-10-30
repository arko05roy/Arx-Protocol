import json
import os

bedrock = "/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/packages/contracts-bedrock"
artifacts_dir = os.path.join(bedrock, "forge-artifacts")

# Predeploy addresses (from Predeploys.sol)
predeploys = {
    "L2ToL1MessagePasser": "0x4200000000000000000000000000000000000000",
    "L1Block": "0x4200000000000000000000000000000000000015",
    "L2StandardBridge": "0x4200000000000000000000000000000000000010",
    "L2CrossDomainMessenger": "0x4200000000000000000000000000000000000007",
    "GasPriceOracle": "0x420000000000000000000000000000000000000F",
    "SequencerFeeVault": "0x4200000000000000000000000000000000000011",
    "OptimismMintableERC20Factory": "0x4200000000000000000000000000000000000012",
    "ProxyAdmin": "0x4200000000000000000000000000000000000018",
    "Permit2": "0x4200000000000000000000000000000000000019",
}

# Map contract name to artifact file (search in forge-artifacts)
artifact_map = {
    "L2ToL1MessagePasser": "L2ToL1MessagePasser.sol/L2ToL1MessagePasser.json",
    "L1Block": "L1Block.sol/L1Block.json",
    "L2StandardBridge": "L2StandardBridge.sol/L2StandardBridge.json",
    "L2CrossDomainMessenger": "L2CrossDomainMessenger.sol/L2CrossDomainMessenger.json",
    "GasPriceOracle": "GasPriceOracle.sol/GasPriceOracle.json",
    "SequencerFeeVault": "SequencerFeeVault.sol/SequencerFeeVault.json",
    "OptimismMintableERC20Factory": "OptimismMintableERC20Factory.sol/OptimismMintableERC20Factory.json",
    "ProxyAdmin": "ProxyAdmin.sol/ProxyAdmin.json",
    "Permit2": "Permit2.sol/Permit2.json",
}

allocs = {}

for name, addr in predeploys.items():
    allocs[addr.lower()] = {
        "balance": "0x0",
        "nonce": "0x0",
        "code": "0x",
        "storage": {}
    }
    
    if name in artifact_map:
        artifact_path = os.path.join(artifacts_dir, artifact_map[name])
        if os.path.exists(artifact_path):
            try:
                with open(artifact_path) as f:
                    artifact = json.load(f)
                    deployed_bytecode = artifact.get("deployedBytecode", "0x")
                    if deployed_bytecode and deployed_bytecode != "0x":
                        allocs[addr.lower()]["code"] = deployed_bytecode.lower()
                        print(f"✓ {name}: {len(deployed_bytecode)//2} bytes")
                    else:
                        print(f"⚠ {name}: no deployedBytecode (will use empty code)")
            except Exception as e:
                print(f"✗ {name}: {e}")
        else:
            print(f"⚠ {name}: artifact not found at {artifact_path}")

# Add user premints
premints = {
    "0xABaF59180e0209bdB8b3048bFbe64e855074C0c4": "0x56bc75e2d630eb20000",
    "0x89a26a33747b293430D4269A59525d5D0D5BbE65": "0x56bc75e2d630eb20000",
    "0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62": "0x2b5e3af16b1880000",
    "0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47": "0x2b5e3af16b1880000",
    "0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49": "0xb1a2bc2ec50000",
}

for addr, bal in premints.items():
    allocs[addr.lower()] = {"balance": bal, "nonce": "0x0"}

with open("/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/l2-allocs.json", "w") as f:
    json.dump(allocs, f, indent=2)

print(f"\n✓ Wrote l2-allocs.json with {len(allocs)} accounts")
