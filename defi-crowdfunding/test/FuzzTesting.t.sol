// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Campaign} from "../src/campaign/Campaing.sol";
import {CrowdfundingFactory} from "../src/factory/CrowdfundingFactory.sol";
import {RewardToken} from "../src/token/RewardToken.sol";
import {Treasury} from "../src/treasury/Treasury.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

// Topics
// - fuzz
// - assume and bound
// - stats

/* 
Notes
Doc: https://www.cyfrin.io/blog/smart-contract-fuzzing-and-invariants-testing-foundry

Invariant testing:
    - involves set of conditions - invariants - that must always hold, regardless of the contract's state or input.
    They need:
        - invariant definition - crucial conditions that must always remain true for proper contract functionality
        - state analysis - process that examines the contract under diverse states and input scenarios. Ensure that the defined invariants remain valid and un-breached

In other words i define some "rule" and this rule should never be broken.

Fuzz testing:
    - lifts the need to manually test every possible value a variable

    Definition:
        - enables us to systematically input random data into tests to break specific assertions. 
        By automating the randomization of the input we pass into functions inside our tests.
*/

contract FuzzTesting is Test {
    CrowdfundingFactory public crowdfundingFactory;
    RewardToken public rewardToken;

    address public campaignImplementation;
    address public admin = address(this);

    address public creator = address(0x1234);
    address public donor = address(0x5678);

    function setUp() public {
        // Deploy the Campaign implementation contract
        campaignImplementation = address(new Campaign());
        crowdfundingFactory = new CrowdfundingFactory(campaignImplementation, admin);
        
        // Give donor some ETH
        vm.deal(donor, 10 ether);
    }

    // Here i make the condition that the refund should not be possible before deadline
    // in logs i can see the stats `(runs: 256, μ: 5359949, ~: 5359949)`
    //    - `runs` - is the number of tests that ran for this fuzz
    //    - `μ` - average amount of gas that is used for this test
    //    - `~` - medium amount of gas that is used for this test
    function testStatelessFuzzTestRefundNotPossibleBeforeDeadline(
        uint256 donationAmount,
        uint256 donationTime
    ) public {
        uint256 fundingGoal = 5 ether;
        uint256 duration = 7 days;

        // Add constraint to those parameters to valid ranges 
        // Instead of `require block` i need to use `vm.assume` that tells the fuzzer to skip inputs that don't meet my criteria and try new ones
        // So i can focus the fuzzer on only the valid input space (before deadline) and explore all scenarios withing those constraints
        vm.assume(donationTime < duration);
        vm.assume(donationAmount > 0 && donationAmount < fundingGoal);
        vm.assume(donationAmount <= donor.balance);

        address[] memory signers = new address[](2);
        signers[0] = creator;
        signers[1] = address(0xABCD);

        rewardToken = new RewardToken(address(this));

        crowdfundingFactory.createCampaign(
            creator, fundingGoal, duration, signers, 2, address(rewardToken), "Refund Test"
        );

        (address campaignAddr, address treasuryAddr, , ) = crowdfundingFactory.campaigns(0);
        Campaign campaign = Campaign(campaignAddr);
        rewardToken.transferOwnership(campaignAddr);

        // Donate less than goal
        vm.prank(donor);
        campaign.donate{value: donationAmount}();

        uint256 donorBalanceBefore = donor.balance;

        // Warp past deadline, finalize, claim refund
        vm.warp(block.timestamp + duration + 1);
        campaign.finalize();

        vm.prank(donor);
        campaign.claimRefund();

        // Verify: donor got refund, donation cleared, treasury empty
        assertEq(donor.balance, donorBalanceBefore + donationAmount);
        assertEq(campaign.donations(donor), 0);
        assertEq(address(treasuryAddr).balance, 0);
    }
}