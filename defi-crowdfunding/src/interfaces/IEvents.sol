// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;


interface IEvents {

    event CampaignDeactivated(
        address indexed campaignAddress,
        address indexed ownedBy,
        string indexed name
    );
}