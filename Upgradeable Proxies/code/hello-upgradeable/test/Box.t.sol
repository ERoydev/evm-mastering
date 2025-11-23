// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Box} from "../src/Box.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {console} from "forge-std/console.sol";

// Used for Upgradeable Proxies
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

// Interface for Beacon
import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import {Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

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

    function testBeacon() public {
        // Deploy a beacon with the `Box` Contract as the initial implementation
        address beacon = Upgrades.deployBeacon("Box.sol", msg.sender);

        // Get the initial implementation address of the beacon
        address implAddrV1 = IBeacon(beacon).implementation();

        // Deploy the first beacon proxy and initialize it
        address proxy1 = Upgrades.deployBeaconProxy(beacon, abi.encodeCall(Box.initialize, 10));
        Box instance1 = Box(proxy1);

        // Deploy the second beacon proxy and initialize it
        address proxy2 = Upgrades.deployBeaconProxy(beacon, abi.encodeCall(Box.initialize, 20));
        Box instance2 = Box(proxy2);

        // Check if both proxies point to the same beacond
        assertEq(Upgrades.getBeaconAddress(proxy1), beacon);
        assertEq(Upgrades.getBeaconAddress(proxy1), beacon);

        console.log("----------------------------------");
        console.log("Value before upgrade in Proxy 1 --> ", instance1.retrieve());
        console.log("Value before upgrade in Proxy 2 --> ", instance2.retrieve());
        console.log("----------------------------------");

        // ======= Validate the new implementation before upgrading ==========
        Options memory opts; // Lets me specify parameters for upgrade validation
        opts.referenceContract = "Box.sol"; // Compare the storage layout of BoxV2 against the `Box.sol` to ensure the upgrade is safe.
        Upgrades.validateUpgrade("BoxV2.sol", opts); // So with that i start the validation process

        // if validation fails it will revert and stop execution

        // Upgrade the beacon to use `BoxV2` as the new implementation
        Upgrades.upgradeBeacon(beacon, "BoxV2.sol", msg.sender);

        // Get the new implementation address of the beacon after upgrade
        address implAddrV2 = IBeacon(beacon).implementation();

        // Activate the increaseValue function in both proxies
        BoxV2 upgradedInstance1 = BoxV2(proxy1);
        BoxV2 upgradedInstance2 = BoxV2(proxy2);
        upgradedInstance1.increment();
        upgradedInstance2.increment();

        console.log("----------------------------------");
        (uint256 a, uint256 b) = upgradedInstance1.retrieve();
        console.log("Value after upgrade in Proxy 1 --> ", a, b);
        (uint256 a1, uint256 b1) = upgradedInstance2.retrieve();
        console.log("Value after upgrade in Proxy 2 --> ", a1, b1);
        console.log("----------------------------------");

        // Check if the values have been correctly increased (Look that we still use the old interface of `Box` implementation contract)
        assertEq(instance1.value(), 11);
        assertEq(instance2.value(), 21);

        // Check if the implementation address has changed
        assertFalse(implAddrV1 == implAddrV2);

    }

}