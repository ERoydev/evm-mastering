// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// This will be an individual Campaign for every campaign created from the CrowdfundingFactory, should be Upgradeable.
// Implementation Contract
contract CampaignV2 {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
