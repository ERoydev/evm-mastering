// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


// Simple contract

// The idea is that whatever i do to interact with my implementation contract we are going to do it from here
contract MyContractProxy is ERC1967Proxy {
    /*
        - Tt takes the address of the `Implementation Contract` -> V1.sol
        - The data is actually stored within the proxy and not within the V1 Contract
    */
    constructor(address _logic, bytes memory _data) ERC1967Proxy(_logic, _data) {}
}