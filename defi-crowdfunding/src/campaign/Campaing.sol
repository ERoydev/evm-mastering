// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ITreasury} from "../interfaces/ITreasury.sol";
import {IRewardToken} from "../interfaces/IRewardToken.sol";
import {BitmaskLib} from "./BitmaskLib.sol";

// This will be an individual Campaign for every campaign created from the CrowdfundingFactory, should be Upgradeable.
// Implementation Contract
contract Campaign {
    using BitmaskLib for uint8;

    // ===== State Variables =====
    /// @dev The creator of the campaign
    address public creator;
    /// @dev The funding goal of the campaign
    uint256 public fundingGoal; 
    /// @dev The deadline of the campaign
    uint256 public deadline;
    address public treasury;
    address public rewardToken;

    /// @dev State of the campaign
    uint8 public state;
    uint8 public deactivated; // It will be deactivated once all funds are received 

    uint256 public totalDonated;
    mapping(address => uint256) public donations; // Tracks donor contributions

    constructor(
        address _creator,
        uint256 _fundingGoal,
        uint256 _duration,
        address _treasury,
        address _rewardToken
    ) {
        creator = _creator;
        fundingGoal = _fundingGoal;
        deadline = block.timestamp + _duration;
        treasury = _treasury;
        rewardToken = _rewardToken;
    }

    // ===== Modifiers =====
    modifier onlyActive() {
        require(state == BitmaskLib.ACTIVE, "Campaign finished");
        _;
    }

    // ===== Donation Function =====
    function donate() external payable {
        require(block.timestamp < deadline, "Campaign has ended");
        require(msg.value > 0, "Donation must be greater than 0");

        // Update donation records
        donations[msg.sender] += msg.value;
        totalDonated += msg.value;

        // Send ETH to Treasury
        ITreasury(treasury).deposit{value: msg.value}();

        // Mint reward tokens to donor
        // Formula is 1 ETH = 20 RWD
        IRewardToken(rewardToken).mint(msg.sender, msg.value * 20);
    }

    /// @notice start of the campaign
    function activate() {
        require(block.timestamp < deadline, "Cannot activate campaign deadline has already passed");
    }

    /// @notice end of the campaign
    function deactivate() {
        require(block.timestamp >= deadline, "Deadline of the campaign is not reached yet.");

    }

    function mark_as_failed() {

    }

    function enable_refunds() {

    }

    function mark_funds_as_released() {

    }
}
