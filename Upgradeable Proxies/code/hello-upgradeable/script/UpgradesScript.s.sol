// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import { Box } from "../src/Box.sol";
import { BoxV2 } from "../src/BoxV2.sol";

import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";

// forge clean && forge script script/UpgradesScript.s.sol --rpc-url sepolia --private-key $PRIVATE_KEY --broadcast --verify --sender $SENDER

contract UpgradesScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Box V1 as a transparent proxy using the Ugprades openzeppelin Plugin, it has a docs in google if you want to learn more
        // Docs used for this code: https://rareskills.io/post/openzeppelin-foundry-upgrades#supported-functionality-of-the-upgrades-plugin
        address transparentProxy = Upgrades.deployTransparentProxy(
            "Box.sol", // Contract Name for the implementation contract
            msg.sender, // Initial owner, address set as the owner of the ProxyAdmin contract, which is deployed automatically with the proxy
            abi.encodeCall(Box.initialize, (123)) // Encoded call data for the initializer function to be executed during proxy creation; leave empty if no initialization if needed
        );
    }
}
