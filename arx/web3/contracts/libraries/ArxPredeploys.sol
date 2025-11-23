// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title ArxPredeploys
 * @notice Contains constant addresses for ARX Protocol predeploy contracts.
 * @dev These contracts are deployed in the genesis block and available from block 0.
 *      Addresses follow Optimism's predeploy pattern using the 0x4200... namespace.
 *      Range: 0x4200000000000000000000000000000000000100 - 0x420000000000000000000000000000000000010B
 */
library ArxPredeploys {
    /// @notice Core protocol contracts
    address internal constant TASK_REGISTRY = 0x4200000000000000000000000000000000000100;
    address internal constant DATA_REGISTRY = 0x4200000000000000000000000000000000000101;
    address internal constant MODEL_REGISTRY = 0x4200000000000000000000000000000000000102;
    address internal constant FUNDING_POOL = 0x4200000000000000000000000000000000000103;
    address internal constant COLLATERAL_MANAGER = 0x4200000000000000000000000000000000000104;
    address internal constant VERIFICATION_MANAGER = 0x4200000000000000000000000000000000000105;

    /// @notice Carbon credit system contracts
    address internal constant CARBON_CREDIT_MINTER = 0x4200000000000000000000000000000000000106;
    address internal constant CARBON_MARKETPLACE = 0x4200000000000000000000000000000000000107;

    /// @notice Market and governance contracts
    address internal constant PREDICTION_MARKETPLACE = 0x4200000000000000000000000000000000000108;
    address internal constant GOVERNANCE_DAO = 0x4200000000000000000000000000000000000109;

    /// @notice Treasury and token contracts
    address internal constant TREASURY = 0x420000000000000000000000000000000000010A;
    address internal constant CUSD_TOKEN = 0x420000000000000000000000000000000000010B;

    /// @notice ARX Dapp account that owns and controls the predeploys
    address internal constant ARX_DAPP_ACCOUNT = 0xABaF59180e0209bdB8b3048bFbe64e855074C0c4;
}
