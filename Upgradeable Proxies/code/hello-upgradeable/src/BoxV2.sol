// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


/// @custom:oz-upgrades-from Box
contract BoxV2 is Initializable {
    uint256 public value;
    uint256 public anotherValue;

    function initialize(uint256 initialValue) public {
        value = initialValue;
    }

    function initializeV2(uint256 initialAnotherValue) public {
        anotherValue = initialAnotherValue;
    }


    function storeValues(uint256 newValue, uint256 anotherNewValue) public {
        value = newValue;
        anotherValue = anotherNewValue;
    }
    
    function increment() public {
        value += 1;
        anotherValue += 1;
    }

    function decrement() public {
        value -= 1;
        anotherValue -= 1;
    }

    // Retrieve the last stored value
    function retrieve() public view returns (uint256, uint256) {
        return (value, anotherValue);
    }
}