// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Allow swapping between ETH and RewardToken using a constant product AMM.
contract SimpleAMM {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
