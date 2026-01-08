// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// Multisig - Safely control campaign funds using multiple signers.
contract Treasury {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
