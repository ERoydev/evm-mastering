// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CrowdfundingFactory {  
 
    struct CampaignInfo {
        address campaignAddress;
        address owner;
        string name;
    }

    CampaignInfo[] public campaigns;   

    // Pseudo-code for factory
    // function createCampaign(string memory _name) public {
    //     // Deploy a new proxy pointing to Campaign implementation
    //     address proxy = address(new TransparentUpgradeableProxy(
    //         campaignImplementation,
    //         admin,
    //         abi.encodeWithSelector(Campaign.initialize.selector, msg.sender, _name)
    //     ));
    //     campaigns.push(proxy);
    // }
}
