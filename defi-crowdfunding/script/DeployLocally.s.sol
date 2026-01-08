// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {CrowdfundingFactory} from "../src/factory/CrowdfundingFactory.sol";
import {console} from "forge-std/console.sol";

contract DeployLocally is Script {
    function run() public {
        vm.startBroadcast();

        CrowdfundingFactory factory = new CrowdfundingFactory();
        console.log("Deployed CrowdfundingFactory at:", address(factory));

        vm.stopBroadcast();
    }
}
