package main

import (
    "encoding/json"
    "fmt"
    "math/big"
    "os"
    "path/filepath"
    "strings"
    "github.com/ethereum/go-ethereum/common"
)

type ForgeAllocAccount struct {
    Balance string            `json:"balance,omitempty"`
    Nonce   string            `json:"nonce,omitempty"`
    Code    string            `json:"code,omitempty"`
    Storage map[string]string `json:"storage,omitempty"`
}
type ForgeAllocs map[string]ForgeAllocAccount

type DeployedBytecode struct {
    Object string `json:"object"`
}

type Artifact struct {
    DeployedBytecode DeployedBytecode `json:"deployedBytecode"`
}

func must(err error) { if err != nil { panic(err) } }

func readArtifactBytecode(root, subdir, contract string) string {
    p := filepath.Join(root, "forge-artifacts", subdir, contract+".json")
    b, err := os.ReadFile(p); must(err)
    var a Artifact
    must(json.Unmarshal(b, &a))
    bytecode := a.DeployedBytecode.Object
    if !strings.HasPrefix(bytecode, "0x") {
        bytecode = "0x" + bytecode
    }
    return strings.ToLower(bytecode)
}

func main() {
    bedrock := "/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/packages/contracts-bedrock"
    allocs := ForgeAllocs{}
    // Core subset of predeploys sufficient for genesis validation
    // Address map (name -> address) derived from Predeploys.sol
    pre := map[string]string{
        // All predeploys required by op-node
        "LEGACY_MESSAGE_PASSER":   "0x4200000000000000000000000000000000000000",
        "L1_MESSAGE_SENDER":       "0x4200000000000000000000000000000000000001",
        "DEPLOYER_WHITELIST":      "0x4200000000000000000000000000000000000002",
        "WETH":                    "0x4200000000000000000000000000000000000006",
        "L2_CROSS_DOMAIN_MESSENGER": "0x4200000000000000000000000000000000000007",
        "GAS_PRICE_ORACLE":        "0x420000000000000000000000000000000000000F",
        "L2_STANDARD_BRIDGE":      "0x4200000000000000000000000000000000000010",
        "SEQUENCER_FEE_VAULT":     "0x4200000000000000000000000000000000000011",
        "OPTIMISM_MINTABLE_ERC20_FACTORY": "0x4200000000000000000000000000000000000012",
        "L1_BLOCK_NUMBER":         "0x4200000000000000000000000000000000000013",
        "L2_ERC721_BRIDGE":        "0x4200000000000000000000000000000000000014",
        "L1_BLOCK_ATTRIBUTES":     "0x4200000000000000000000000000000000000015",
        "L2_TO_L1_MESSAGE_PASSER": "0x4200000000000000000000000000000000000016",
        "OPTIMISM_MINTABLE_ERC721_FACTORY": "0x4200000000000000000000000000000000000017",
        "PROXY_ADMIN":             "0x4200000000000000000000000000000000000018",
        "BASE_FEE_VAULT":          "0x4200000000000000000000000000000000000019",
        "L1_FEE_VAULT":            "0x420000000000000000000000000000000000001A",
        "OPERATOR_FEE_VAULT":      "0x420000000000000000000000000000000000001b",
        "SCHEMA_REGISTRY":         "0x4200000000000000000000000000000000000020",
        "EAS":                     "0x4200000000000000000000000000000000000021",
        "CROSS_L2_INBOX":          "0x4200000000000000000000000000000000000022",
        "L2_TO_L2_CROSS_DOMAIN_MESSENGER": "0x4200000000000000000000000000000000000023",
        "SUPERCHAIN_ETH_BRIDGE":   "0x4200000000000000000000000000000000000024",
        "ETH_LIQUIDITY":           "0x4200000000000000000000000000000000000025",
        "OPTIMISM_SUPERCHAIN_ERC20_FACTORY": "0x4200000000000000000000000000000000000026",
        "OPTIMISM_SUPERCHAIN_ERC20_BEACON": "0x4200000000000000000000000000000000000027",
        "SUPERCHAIN_TOKEN_BRIDGE": "0x4200000000000000000000000000000000000028",
        "GOVERNANCE_TOKEN":        "0x4200000000000000000000000000000000000042",
    }
    // Map predeploy names to artifact locations (sol filename, contract name)
    art := map[string][2]string{
        "LEGACY_MESSAGE_PASSER":   {"LegacyMessagePasser.sol", "LegacyMessagePasser"},
        "DEPLOYER_WHITELIST":      {"DeployerWhitelist.sol", "DeployerWhitelist"},
        "WETH":                    {"WETH.sol", "WETH"},
        "L2_CROSS_DOMAIN_MESSENGER": {"L2CrossDomainMessenger.sol", "L2CrossDomainMessenger"},
        "GAS_PRICE_ORACLE":        {"GasPriceOracle.sol", "GasPriceOracle"},
        "L2_STANDARD_BRIDGE":      {"L2StandardBridge.sol", "L2StandardBridge"},
        "SEQUENCER_FEE_VAULT":     {"SequencerFeeVault.sol", "SequencerFeeVault"},
        "OPTIMISM_MINTABLE_ERC20_FACTORY": {"OptimismMintableERC20Factory.sol", "OptimismMintableERC20Factory"},
        "L1_BLOCK_NUMBER":         {"L1BlockNumber.sol", "L1BlockNumber"},
        "L2_ERC721_BRIDGE":        {"L2ERC721Bridge.sol", "L2ERC721Bridge"},
        "L1_BLOCK_ATTRIBUTES":     {"L1Block.sol", "L1Block"},
        "L2_TO_L1_MESSAGE_PASSER": {"L2ToL1MessagePasser.sol", "L2ToL1MessagePasser"},
        "OPTIMISM_MINTABLE_ERC721_FACTORY": {"OptimismMintableERC721Factory.sol", "OptimismMintableERC721Factory"},
        "PROXY_ADMIN":             {"ProxyAdmin.sol", "ProxyAdmin"},
        "BASE_FEE_VAULT":          {"BaseFeeVault.sol", "BaseFeeVault"},
        "L1_FEE_VAULT":            {"L1FeeVault.sol", "L1FeeVault"},
        "OPERATOR_FEE_VAULT":      {"OperatorFeeVault.sol", "OperatorFeeVault"},
        "SCHEMA_REGISTRY":         {"SchemaRegistry.sol", "SchemaRegistry"},
        "EAS":                     {"EAS.sol", "EAS"},
        "GOVERNANCE_TOKEN":        {"GovernanceToken.sol", "GovernanceToken"},
        "CROSS_L2_INBOX":          {"CrossL2Inbox.sol", "CrossL2Inbox"},
        "L2_TO_L2_CROSS_DOMAIN_MESSENGER": {"L2ToL2CrossDomainMessenger.sol", "L2ToL2CrossDomainMessenger"},
        "SUPERCHAIN_ETH_BRIDGE":   {"SuperchainEthBridge.sol", "SuperchainEthBridge"},
        "ETH_LIQUIDITY":           {"EthLiquidity.sol", "EthLiquidity"},
        "OPTIMISM_SUPERCHAIN_ERC20_FACTORY": {"OptimismSuperchainERC20Factory.sol", "OptimismSuperchainERC20Factory"},
        "OPTIMISM_SUPERCHAIN_ERC20_BEACON": {"OptimismSuperchainERC20Beacon.sol", "OptimismSuperchainERC20Beacon"},
        "SUPERCHAIN_TOKEN_BRIDGE": {"SuperchainTokenBridge.sol", "SuperchainTokenBridge"},
    }
    for name, addr := range pre {
        m := ForgeAllocAccount{Balance: "0x0", Nonce: "0x0"}
        if a, ok := art[name]; ok {
            m.Code = readArtifactBytecode(bedrock, a[0], a[1])
        } else {
            // Predeploys without artifacts get minimal bytecode (contract that returns empty)
            // This is: PUSH1 0x00 PUSH1 0x00 RETURN (0x6000f3)
            m.Code = "0x6000f3"
        }
        allocs[addr] = m
    }
    // Fill in all predeploys from 0x4200000000000000000000000000000000000000 to 0x42000000000000000000000000000000000007ff
    // with minimal bytecode if not already present
    l2PredeployNamespace := new(big.Int)
    l2PredeployNamespace.SetString("4200000000000000000000000000000000000000", 16)
    for i := 0; i < 2048; i++ {
        addr := common.BigToAddress(new(big.Int).Or(l2PredeployNamespace, big.NewInt(int64(i))))
        addrStr := strings.ToLower(addr.Hex())
        if _, exists := allocs[addrStr]; !exists {
            allocs[addrStr] = ForgeAllocAccount{Balance: "0x0", Nonce: "0x0", Code: "0x6000f3"}
        }
    }
    // Merge user premints
    allocs[strings.ToLower("0xABaF59180e0209bdB8b3048bFbe64e855074C0c4")] = ForgeAllocAccount{Balance: "0x56bc75e2d630eb20000", Nonce: "0x0"}
    allocs[strings.ToLower("0x89a26a33747b293430D4269A59525d5D0D5BbE65")] = ForgeAllocAccount{Balance: "0x56bc75e2d630eb20000", Nonce: "0x0"}
    allocs[strings.ToLower("0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62")] = ForgeAllocAccount{Balance: "0x2b5e3af16b1880000", Nonce: "0x0"}
    allocs[strings.ToLower("0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47")] = ForgeAllocAccount{Balance: "0x2b5e3af16b1880000", Nonce: "0x0"}
    allocs[strings.ToLower("0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49")] = ForgeAllocAccount{Balance: "0xb1a2bc2ec50000", Nonce: "0x0"}

    out, _ := json.MarshalIndent(allocs, "", "  ")
    must(os.WriteFile("/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/l2-allocs.json", out, 0644))
    fmt.Println("Wrote l2-allocs.json with", len(allocs), "accounts")
}
