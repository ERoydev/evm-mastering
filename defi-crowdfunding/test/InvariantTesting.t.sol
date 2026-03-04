// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Campaign} from "../src/campaign/Campaing.sol";
import {CrowdfundingFactory} from "../src/factory/CrowdfundingFactory.sol";
import {RewardToken} from "../src/token/RewardToken.sol";
import {Treasury} from "../src/treasury/Treasury.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {BitmaskLib} from "../src/libraries/BitmaskLib.sol";


/*
Difference between Fuzzing and Invariant Testing:
    - fuzzing a random input is passed into a single function and that function is tested multiple times
    - invariant, a sequence of functions are randomly called, after they are called some checks that i write are going to be executed. (So if all checks passed my test pass)
*/

contract InvariantFactoryTest is Test {
    CrowdfundingFactory public crowdfundingFactory;
    RewardToken public rewardToken;
    address public campaignImplementation;
    address public admin = address(this);
    address public creator = address(0x1234);
    address[] public donors;

    function setUp() public {
        campaignImplementation = address(new Campaign());
        crowdfundingFactory = new CrowdfundingFactory(campaignImplementation, admin);
        rewardToken = new RewardToken(address(this));

        address donor1 = address(0x5678);
        address donor2 = address(0x6789);
        vm.deal(donor1, 10 ether);
        vm.deal(donor2, 10 ether);
        donors.push(donor1);
        donors.push(donor2);

        // Here i have to make the donors to donate to campaign

        // Create a campaign
        address[] memory signers = new address[](2);
        signers[0] = creator;
        signers[1] = address(0xABCD);
        uint256 fundingGoal = 5 ether;
        uint256 duration = 7 days;
        crowdfundingFactory.createCampaign(
            creator, fundingGoal, duration, signers, 2, address(rewardToken), "Invariant Test"
        );
        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        rewardToken.transferOwnership(campaignAddr);
        Campaign campaign = Campaign(campaignAddr);
        // Each donor donates 1 ether
        for (uint256 i = 0; i < donors.length; i++) {
            vm.prank(donors[i]);
            campaign.donate{value: 1 ether}();
        }
    }

    // Invariant function only checks that the sum of all individual donations equals totalDonated.
    // It will randomly call different function on my contracts (Campaign, Treasury), and check if my `condition` is passing.
    function invariant_TotalDonatedEqualsSumOfDonations() public {
        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        Campaign campaign = Campaign(campaignAddr);

        uint256 sum = 0;
        for (uint256 i = 0; i < donors.length; i++) {
            sum += campaign.donations(donors[i]);
        }
        assertEq(sum, campaign.totalDonated(), "Sum of donations does not match totalDonated");
    }

    function invariant_TotalDonatedNeverExceedsGoal() public {
        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        Campaign campaign = Campaign(campaignAddr);
        assertLe(campaign.totalDonated(), campaign.fundingGoal());
    }

    function invariant_NoRefundsBeforeDeadline() public {
        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        Campaign campaign = Campaign(campaignAddr);
        if (block.timestamp < campaign.deadline()) {
            assertFalse(BitmaskLib.hasState(campaign.state(), BitmaskLib.REFUNDS_ENABLED));
        }
    }

    function invariant_CampaignNotSuccessfulAndFailed() public {
        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        Campaign campaign = Campaign(campaignAddr);
        bool successful = campaign.state() & BitmaskLib.SUCCESSFUL != 0;
        bool failed = campaign.state() & BitmaskLib.FAILED != 0;
        assertFalse(successful && failed, "Campaign cannot be both successful and failed");
    }
}