// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import { Box } from "../src/Box.sol";

// forge script script/DeployBoxV1.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

contract DeployBoxV1 is Script {
    Box public box;

    function setUp() public {}

    function run() external returns (Box) {
        vm.startBroadcast();

        box = new Box();

        vm.stopBroadcast();
        return box;
    }
}
