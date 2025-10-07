// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Box is Initializable {
    uint256 public value;

    // Initializable will handle situation where initialize is called more than once, so it prevents double initialization

    function initialize(uint256 initialValue) public {
        value = initialValue;
    }

    function store(uint256 newValue) public {
        value = newValue;
    }

    function increment() public {
        value += 1;
    }

    // Retrieve the last stored value
    function retrieve() public view returns (uint256) {
        return value;
    }
}