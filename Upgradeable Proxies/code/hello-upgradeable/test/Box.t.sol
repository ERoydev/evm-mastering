// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Box} from "../src/Box.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {console} from "forge-std/console.sol";

contract BoxUpgradesTest is Test {
    Box public box;

    function testTransparent() public {
        address proxy = Upgrades.deployTransparentProxy(
            "Box.sol",
            msg.sender,
            abi.encodeCall(Box.initialize, (42))
        );

        // Get the instance of the contract
        Box instance = Box(proxy);

        // Get the implementation address of the proxy
        address implAddrV1 = Upgrades.getImplementationAddress(proxy);

        // Get the admin address of the proxy
        address adminAddr = Upgrades.getAdminAddress(proxy);

        // Ensure the admin address is valid
        assertFalse(adminAddr == address(0));

        // Log the initial value
        console.log("----------------------------------");
        console.log("Value before upgrade --> ", instance.retrieve());
        console.log("----------------------------------");

        // Verify initial value is as expected
        assertEq(instance.value(), 42);

        // // Upgrade the proxy to Contract BoxV2
        Upgrades.upgradeProxy(
            proxy,
            "BoxV2.sol",
            abi.encodeCall(
                BoxV2.initializeV2,
                (50) // Initialize the new variable in BoxV2
            ),
            msg.sender
        );

        // Get the new implementation address after upgrade
        address implAddrV2 = Upgrades.getImplementationAddress(proxy);

        // Verify admin address remains unchanged
        assertEq(adminAddr, Upgrades.getAdminAddress(proxy));

        // Verify implementation address has changed
        assertFalse(implAddrV1 == implAddrV2);

        // Update the Interface wrapper to BoxV2 of the proxy
        BoxV2 upgradedInstance = BoxV2(proxy);
        assertEq(upgradedInstance.anotherValue(), 50);

        // Invoke the increaseValue function separately
        upgradedInstance.increment();


        // Log and verify the updated value
        console.log("----------------------------------");
        console.log("Value after upgrade --> ", upgradedInstance.value());
        console.log("Another Value after upgrade --> ", upgradedInstance.anotherValue());
        console.log("----------------------------------");
        assertEq(instance.value(), 43);
        assertEq(upgradedInstance.anotherValue(), 51);
    }
}
