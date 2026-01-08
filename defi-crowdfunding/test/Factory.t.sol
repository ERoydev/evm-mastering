// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {CrowdfundingFactory} from "../src/factory/CrowdfundingFactory.sol";

contract FactoryTest is Test {
    CrowdfundingFactory public crowdfundingFactory;

    function setUp() public {
        crowdfundingFactory = new CrowdfundingFactory();
        crowdfundingFactory.setNumber(0);
    }

    function test_Increment() public {
        crowdfundingFactory.increment();
        assertEq(crowdfundingFactory.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        crowdfundingFactory.setNumber(x);
        assertEq(crowdfundingFactory.number(), x);
    }
}
