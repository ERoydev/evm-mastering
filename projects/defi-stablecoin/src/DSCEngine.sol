// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.25;
 
/*
 * @title DSCEngine
 * @author Emil
 *
 * System design to be minimalistic and simple to maintain a '1 token to 1 USD' peg.
 * StableCoin properties:
 * - Exogenous Collateral
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * This is similar to DAI without governance, with no fees, and if only backed by WETH and WBTC
 *
 * Our DSC system should always be overcollateralized. Value of all collateral should never be <= $ backed value of all the DSC.
 *
 * @notice This contract is the core of the DSC system, it handles all the logic for minting and redeeming DSC, depositing & withdrawing collateral.
 * @notice This contract is very loosely based on the MakerDAO DSS (DAI) system.
 */
contract DSCEngine {
    // Threshold to let's say 150%
    // $100 ETH -> $75 ETH
    // $50 DSC

    // Meaning if i have $50 of DSC i need to have at least $75 ETH worth of collateral, if i drop bellow i am going to be liquidated
    // So if i drop on $74, someone can pay back my minted DSC, they can have all my collateral for a discount
    // We'll say, "Hey, anybody who liquidates your position, if you're under the threshold, they can have as a reward some of your extra collateral."
    // That's why people will be incentivized to always have extra collateral, otherwise they are gonna lose way more money than they borrow.

    function DepositCollateralAndMintDsc() external {}

    function depositCollateral() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function redeemCollateralForDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

}