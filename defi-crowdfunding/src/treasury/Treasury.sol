// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ITreasury} from "../interfaces/ITreasury.sol";

// Flow:
// 1.Compaign collects donations -> sends ETH to treasury via deposit
// 2. After campaign ens, any signer calls proposeTransaction(...)
// 3. Other signers call approveTransaction
// 4. Once approvalCount >= threshold, any signer calls, executeTransaction

/// @title Treasury - Multisig wallet for campaign funds
/// @notice Each campaign deploys its own Treasury with its own signers and threshold
contract Treasury is ITreasury {

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvalCount;
    }

    // ===== State Variables =====
    address public campaign;
    address[] public signers;
    mapping(address => bool) public isSigner;
    uint256 public threshold;

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approvals; // txId => signer => approved

    bool private initialized;

    // ===== Events =====
    event Deposited(address indexed from, uint256 amount);
    event TransactionProposed(uint256 indexed txId, address indexed proposer, address to, uint256 value);
    event TransactionApproved(uint256 indexed txId, address indexed signer);
    event TransactionRevoked(uint256 indexed txId, address indexed signer);
    event TransactionExecuted(uint256 indexed txId, address indexed executor);

    // ===== Modifiers =====
    modifier onlySigner() {
        require(isSigner[msg.sender], "Not a signer");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "Transaction already executed");
        _;
    }

    /// @notice Initialize the treasury with signers and threshold
    /// @dev Called once when the treasury is deployed for a campaign
    /// @param _signers Array of signer addresses (e.g., campaign creator + trusted parties)
    /// @param _threshold Minimum number of approvals required to execute
    /// @param _campaign The campaign address that can deposit funds
    function initialize(
        address[] calldata _signers,
        uint256 _threshold,
        address _campaign
    ) external {
        require(!initialized, "Already initialized");
        require(_signers.length > 0, "Must have at least one signer");
        require(_threshold > 0 && _threshold <= _signers.length, "Invalid threshold");
        require(_campaign != address(0), "Invalid campaign address");

        for (uint256 i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            require(signer != address(0), "Invalid signer");
            require(!isSigner[signer], "Duplicate signer");
            
            signers.push(signer);
            isSigner[signer] = true;
        }

        threshold = _threshold;
        campaign = _campaign;
        initialized = true;
    }

    /// @notice Receive ETH from the campaign
    function deposit() external payable override {
        require(msg.sender == campaign, "Only campaign can deposit");
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Create a pending transaction, return txId
    /// @param to Recipient address
    /// @param value Amount of ETH to send
    /// @param data Calldata for the transaction (optional)
    function proposeTransaction(
        address to, 
        uint256 value,
        bytes calldata data
    ) external onlySigner returns (uint256) {
        require(to != address(0), "Invalid recipient");
        require(value <= address(this).balance, "Insufficient balance");

        uint256 txId = transactions.length;
        transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            approvalCount: 0
        }));

        emit TransactionProposed(txId, msg.sender, to, value);
        return txId;
    }

    /// @notice Signer votes yes, increment approval count
    function approveTransaction(uint256 txId) external onlySigner txExists(txId) notExecuted(txId) {
        require(!approvals[txId][msg.sender], "Already approved");

        approvals[txId][msg.sender] = true;
        transactions[txId].approvalCount++;

        emit TransactionApproved(txId, msg.sender);
    }

    /// @notice If approvalCount >= threshold, execute the transaction
    function executeTransaction(uint256 txId) external onlySigner txExists(txId) notExecuted(txId) {
        Transaction storage txn = transactions[txId];
        require(txn.approvalCount >= threshold, "Not enough approvals");

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Transaction failed");

        emit TransactionExecuted(txId, msg.sender);
    }

    /// @notice Signer removes their vote
    function revokeApproval(uint256 txId) external onlySigner txExists(txId) notExecuted(txId) {
        require(approvals[txId][msg.sender], "Not approved");

        approvals[txId][msg.sender] = false;
        transactions[txId].approvalCount--;

        emit TransactionRevoked(txId, msg.sender);
    }

    // ===== View Functions =====
    function getSigners() external view returns (address[] memory) {
        return signers;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 txId) external view returns (
        address to,
        uint256 value,
        bytes memory data,
        bool executed,
        uint256 approvalCount
    ) {
        Transaction storage txn = transactions[txId];
        return (txn.to, txn.value, txn.data, txn.executed, txn.approvalCount);
    }

    /// @notice Allow receiving ETH directly (for edge cases)
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }
}
