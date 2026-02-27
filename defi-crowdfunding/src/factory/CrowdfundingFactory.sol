// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Campaign} from "../campaign/Campaing.sol";
import {Treasury} from "../treasury/Treasury.sol";

contract CrowdfundingFactory {  
    address public campaignImplementation;
    address public admin;

    struct CampaignInfo {
        address campaignAddress;
        address treasuryAddress;
        address owner;
        string name;
    }

    CampaignInfo[] public campaigns;   

    constructor(address _campaignImplementation, address _admin) {
        campaignImplementation = _campaignImplementation;
        admin = _admin;
    }

    // Pseudo-code for factory
    function createCampaign(
        address creator,
        uint256 fundingGoal,
        uint256 duration,
        address[] calldata signers,
        uint256 threshold,
        address rewardToken,
        string memory name
    ) public {
        // Freshly deploy treasury
        Treasury treasury = new Treasury();

        // creates binary data to call specific function with arguments on contract. Represents bytes array to call initialize
        // This data is passed to the proxy, which uses it to call the initialize function on the implementation contract
        bytes memory data = abi.encodeWithSelector(
            Campaign.initialize.selector, // unique identifier for the initialize function
            creator,
            fundingGoal,
            duration,
            address(treasury),
            rewardToken,
            name
        );
        // Deploying a new proxy contract for each campaign.
        address proxy = address(new TransparentUpgradeableProxy(
            campaignImplementation,
            admin,
            data
        ));

        // Initialize the treasury for that campaign
        treasury.initialize(signers, threshold, proxy);

        campaigns.push(CampaignInfo(proxy, address(treasury), creator, name));
    }
}
