// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Campaign} from "../src/campaign/Campaing.sol";
import {CrowdfundingFactory} from "../src/factory/CrowdfundingFactory.sol";
import {RewardToken} from "../src/token/RewardToken.sol";
import {Treasury} from "../src/treasury/Treasury.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {BitmaskLib} from "../src/libraries/BitmaskLib.sol";

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";


/*
Difference between Fuzzing and Invariant Testing:
    - fuzzing a random input is passed into a single function and that function is tested multiple times
    - invariant, a sequence of functions are randomly called, after they are called some checks that i write are going to be executed. (So if all checks passed my test pass)
*/

// This is used for Handler based Testing
contract Handler is CommonBase, StdCheats, StdUtils {
    Campaign private campaign; 
    uint256 private fundingGoal;
    uint public wethBalance;
    address[] public allDonors;
    mapping(address => bool) public seen;

    constructor(Campaign _campaign, uint256 _fundingGoal) {
        campaign = _campaign;
        fundingGoal = _fundingGoal;
    }

    receive() external payable {}

    function sendToFallback(uint amount) public { 
        amount = bound(amount, 1, fundingGoal - 1);
        wethBalance += amount;
        (bool ok, ) = address(campaign).call{value: amount}("");
        require(ok, "sendToFallback failed");
    }

    function donate(uint amount) public {
        amount = bound(amount, 1, fundingGoal - 1);
        wethBalance += amount;
        campaign.donate{value: amount}();
        // Track the handler itself as the donor (since that's msg.sender in campaign.donate)
        if (!seen[address(this)]) {
            allDonors.push(address(this));
            seen[address(this)] = true;
        }
    }

    function claimRefund() public {
        // TODO: ... 
        // campaign.claimRefund(); 
    }

    function getAllDonors() public view returns (address[] memory) {
        return allDonors;
    }
}

contract HandlerInvariantTest is Test {
    CrowdfundingFactory public crowdfundingFactory;
    RewardToken public rewardToken;
    address public campaignImplementation;
    address public admin = address(this);
    address public creator = address(0x1234);
    address[] public donors;

    Handler public handler;

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

        // Initialize the Handler contract
        handler = new Handler(campaign, fundingGoal);
        vm.deal(address(handler), 100 * 1e18);
        targetContract(address(handler));

        // Each donor donates 1 ether
        for (uint256 i = 0; i < donors.length; i++) {
            vm.prank(donors[i]);
            handler.donate(1 ether);
        }
    }

    function invariant_TotalDonatedEqualsSumOfDonationsUsingHandler() public {
        (address campaignAddr, , , ) = crowdfundingFactory.campaigns(0);
        Campaign campaign = Campaign(campaignAddr);

        uint256 sum = 0;
        address[] memory allDonors = handler.getAllDonors();
        for (uint256 i = 0; i < allDonors.length; i++) {
            sum += campaign.donations(allDonors[i]);
        }
        assertEq(sum, campaign.totalDonated(), "Sum of donations does not match totalDonated");
    }
}