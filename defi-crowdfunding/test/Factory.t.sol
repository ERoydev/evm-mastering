// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {CrowdfundingFactory} from "../src/factory/CrowdfundingFactory.sol";
import {Campaign} from "../src/campaign/Campaing.sol";
import {CampaignV2} from "../src/campaign/CampaignV2.sol";
import {RewardToken} from "../src/token/RewardToken.sol";
import {Treasury} from "../src/treasury/Treasury.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

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
        uint256 fundingGoal = 1 ether;
        uint256 duration = 7 days;
        address rewardToken1 = address(0xCAFE);
        string memory name = "Test Campaign";

        // Setup multisig signers and threshold
        address[] memory signers = new address[](3);
        signers[0] = creator;
        signers[1] = address(0xABCD);
        signers[2] = address(0xDEAD);
        uint256 threshold = 2;

        // This should create campaign with a treasury for it
        crowdfundingFactory.createCampaign(creator, fundingGoal, duration, signers, threshold, rewardToken1, name);

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

    function testClaimRefundAfterFailedCampaign() public {
        uint256 fundingGoal = 5 ether;
        uint256 duration = 7 days;

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
        campaign.donate{value: 1 ether}();

        uint256 donorBalanceBefore = donor.balance;

        // Warp past deadline, finalize, claim refund
        vm.warp(block.timestamp + duration + 1);
        campaign.finalize();

        vm.prank(donor);
        campaign.claimRefund();

        // Verify: donor got refund, donation cleared, treasury empty
        assertEq(donor.balance, donorBalanceBefore + 1 ether);
        assertEq(campaign.donations(donor), 0);
        assertEq(address(treasuryAddr).balance, 0);
    }

    function testTreasuryMultisigFlow() public {
        uint256 fundingGoal = 1 ether;
        uint256 duration = 7 days;

        address signer1 = creator;
        address signer2 = address(0xABCD);
        address recipient = address(0xBEEF);

        address[] memory signers = new address[](2);
        signers[0] = signer1;
        signers[1] = signer2;

        rewardToken = new RewardToken(address(this));

        crowdfundingFactory.createCampaign(
            creator, fundingGoal, duration, signers, 2, address(rewardToken), "Multisig Test"
        );

        (address campaignAddr, address treasuryAddr, , ) = crowdfundingFactory.campaigns(0);
        Treasury treasury = Treasury(payable(treasuryAddr));
        rewardToken.transferOwnership(campaignAddr);

        // Donate to meet goal
        vm.prank(donor);
        Campaign(campaignAddr).donate{value: 2 ether}();

        // Verify treasury has funds
        assertEq(address(treasury).balance, 2 ether);

        // Signer1 proposes a transaction to send 1 ETH to recipient
        vm.prank(signer1);
        uint256 txId = treasury.proposeTransaction(recipient, 1 ether, "");

        // Signer1 approves
        vm.prank(signer1);
        treasury.approveTransaction(txId);

        // Signer2 approves (meets 2-of-2 threshold)
        vm.prank(signer2);
        treasury.approveTransaction(txId);

        // Execute transaction
        vm.prank(signer1);
        treasury.executeTransaction(txId);

        // Verify: recipient got 1 ETH, treasury has 1 ETH left
        assertEq(recipient.balance, 1 ether);
        assertEq(address(treasury).balance, 1 ether);
    }

    function testUpgradeChangesVersion() public {
        // Deploy V1 and V2 implementations
        Campaign campaignV1Impl = new Campaign();
        CampaignV2 campaignV2Impl = new CampaignV2();
        
        // Deploy proxy with V1. Pass address(this) as initialOwner - 
        // TransparentUpgradeableProxy will create a ProxyAdmin owned by us
        bytes memory initData = abi.encodeWithSelector(
            Campaign.initialize.selector,
            creator, 1 ether, 7 days, address(1), address(2), "Test"
        );
        // this deploys a proxy contract pointing to V1 as the admin (test contract owns ProxyAdmin)
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(campaignV1Impl),
            address(this),  // We will own the auto-created ProxyAdmin
            initData
        );
        
        // Computes the address of the ProxyAdmin contract created by the proxy, then creates a ProxyAdmin instance for upgrade calls.
        address proxyAdminAddr = vm.computeCreateAddress(address(proxy), 1);
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddr);
        
        // Verify V1
        assertEq(Campaign(address(proxy)).version(), 1);
        
        // Upgrade to V2 (we own the ProxyAdmin), now upgrade the proxy to point to V2 implementation.
        proxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(address(proxy)),
            address(campaignV2Impl),
            ""
        );   
        
        // Verify V2
        assertEq(CampaignV2(address(proxy)).version(), 2);
    }
}

