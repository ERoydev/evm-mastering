// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {CrowdfundingFactory} from "../src/factory/CrowdfundingFactory.sol";
import {Campaign} from "../src/campaign/Campaing.sol";
import {RewardToken} from "../src/token/RewardToken.sol";
import {Treasury} from "../src/treasury/Treasury.sol";

contract FactoryTest is Test {
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

    function testCreateCampaign() public {
        address creator = address(0x1234);
        uint256 fundingGoal = 1 ether;
        uint256 duration = 7 days;
        address rewardToken = address(0xCAFE);
        string memory name = "Test Campaign";

        // Setup multisig signers and threshold
        address[] memory signers = new address[](3);
        signers[0] = creator;
        signers[1] = address(0xABCD);
        signers[2] = address(0xDEAD);
        uint256 threshold = 2;

        // This should create campaign with a treasury for it
        crowdfundingFactory.createCampaign(creator, fundingGoal, duration, signers, threshold, rewardToken, name);

        (address campaignAddr, address treasuryAddr, address owner, string memory storedName) = crowdfundingFactory.campaigns(0);
        assertEq(owner, creator, "Owner mismatch");
        assertEq(storedName, name, "Campaign name mismatch");
        assertTrue(campaignAddr != address(0), "Campaign proxy not deployed");
        assertTrue(treasuryAddr != address(0), "Treasury not deployed");
    }

    function testDonateToCampaign() public {
        uint256 fundingGoal = 5 ether;
        uint256 duration = 7 days;
        string memory name = "Donation Test Campaign";

        // Setup multisig signers
        address[] memory signers = new address[](2);
        signers[0] = creator;
        signers[1] = address(0xABCD);
        uint256 threshold = 2;

        // Deploy RewardToken - initially owned by this test contract
        rewardToken = new RewardToken(address(this));

        // Create campaign
        crowdfundingFactory.createCampaign(
            creator, 
            fundingGoal, 
            duration, 
            signers, 
            threshold, 
            address(rewardToken), 
            name
        );

        // Get deployed addresses
        (address campaignAddr, address treasuryAddr, , ) = crowdfundingFactory.campaigns(0);

        // Transfer RewardToken ownership to the campaign so it can mint
        rewardToken.transferOwnership(campaignAddr);

        // Donor donates to campaign
        uint256 donationAmount = 1 ether;
        vm.prank(donor);
        Campaign(campaignAddr).donate{value: donationAmount}();

        // Verify donation was tracked
        assertEq(Campaign(campaignAddr).donations(donor), donationAmount, "Donation not tracked");
        assertEq(Campaign(campaignAddr).totalDonated(), donationAmount, "Total donated mismatch");

        // Verify ETH went to Treasury
        assertEq(address(treasuryAddr).balance, donationAmount, "Treasury did not receive ETH");

        // Verify donor received reward tokens (1 ETH = 20 RWD)
        assertEq(rewardToken.balanceOf(donor), donationAmount * 20, "Reward tokens not minted");
    }

    function testDeactivateCampaignAfterDeadline() public {
        uint256 fundingGoal = 5 ether;
        uint256 duration = 7 days;
        string memory name = "Deactivation Test";

        // Setup multisig signers
        address[] memory signers = new address[](2);
        signers[0] = creator;
        signers[1] = address(0xABCD);
        uint256 threshold = 2;

        // Deploy RewardToken
        rewardToken = new RewardToken(address(this));

        // Create campaign
        crowdfundingFactory.createCampaign(
            creator, 
            fundingGoal, 
            duration, 
            signers, 
            threshold, 
            address(rewardToken), 
            name
        );

        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        Campaign campaign = Campaign(campaignAddr);

        // Verify campaign is not deactivated yet
        assertFalse(campaign.deactivated(), "Campaign should not be deactivated yet");

        // Try to deactivate before deadline - should revert
        vm.expectRevert("Deadline of the campaign is not reached yet.");
        campaign.deactivate();

        // Warp time past the deadline
        vm.warp(block.timestamp + duration + 1);

        // Now deactivation should work
        campaign.deactivate();

        // Verify campaign is deactivated
        assertTrue(campaign.deactivated(), "Campaign should be deactivated");
    }

    function testCannotDonateAfterDeadline() public {
        uint256 fundingGoal = 5 ether;
        uint256 duration = 7 days;
        string memory name = "Deadline Test";

        // Setup multisig signers
        address[] memory signers = new address[](2);
        signers[0] = creator;
        signers[1] = address(0xABCD);
        uint256 threshold = 2;

        // Deploy RewardToken
        rewardToken = new RewardToken(address(this));

        // Create campaign
        crowdfundingFactory.createCampaign(
            creator, 
            fundingGoal, 
            duration, 
            signers, 
            threshold, 
            address(rewardToken), 
            name
        );

        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        rewardToken.transferOwnership(campaignAddr);

        // Warp time past the deadline
        vm.warp(block.timestamp + duration + 1);

        // Attempt to donate after deadline - should revert
        vm.prank(donor);
        vm.expectRevert("Campaign has ended");
        Campaign(campaignAddr).donate{value: 1 ether}();
    }
}

