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

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

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
contract DSCEngine is ReentrancyGuard {
    // Threshold to let's say 150%
    // $100 ETH -> $75 ETH
    // $50 DSC

    // Meaning if i have $50 of DSC i need to have at least $75 ETH worth of collateral, if i drop bellow i am going to be liquidated
    // So if i drop on $74, someone can pay back my minted DSC, they can have all my collateral for a discount
    // We'll say, "Hey, anybody who liquidates your position, if you're under the threshold, they can have as a reward some of your extra collateral."
    // That's why people will be incentivized to always have extra collateral, otherwise they are gonna lose way more money than they borrow.

    ///////////////////
    // Errors        //
    ///////////////////
    error DSCEngine__NotEnoughBalance();
    error DSCEngine__MustBeMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    ////////////////////////////
    // State Variables        //
    ////////////////////////////
    mapping(address token => address priceFeed) private sPriceFeeds; // tokenToPriceFeed
    mapping(address user => mapping(address token => uint256 amount)) private userCollateralDeposited; // userCollateralDeposits
    mapping(address user => uint256 amountDscMinted) private userDscMinted; // userDscMinted

    DecentralizedStableCoin private immutable I_DSC; // StableCoin contract

    ////////////////////////////
    // Events                 //
    ////////////////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    ///////////////////
    // Modifiers     //
    ///////////////////
    modifier moreThanZero(uint256 amount) {
        _moreThanZero(amount);
        _;
    }

    /// @notice Since we want the CollateralAddresses used to be from some kind of tokens list that we allow
    modifier isAllowedToken(address token) {
        _isAllowedToken(token);
        _;
    }

    ///////////////////
    // Functions     //
    ///////////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        // USD backed Price Feeds
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        // For example ETH / USD, BTC / USD, MKR / USD, etc
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            sPriceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }

        I_DSC = DecentralizedStableCoin(dscAddress);
    }

    ////////////////////////////
    // External Functions     //
    ////////////////////////////
    function depositCollateralAndMintDsc() external {}

    /// @param tokenCollateralAddress The addres of the token to deposit as collateral
    /// @param amountCollateral The amount of collateral to be deposited
    /// @notice Follows the CEI pattern (checks, effects, interactions)
    /// Modifiers are the checks, then we update the state `effects`, then we do external interactions
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        if (IERC20(tokenCollateralAddress).balanceOf(msg.sender) < amountCollateral) {
            revert DSCEngine__NotEnoughBalance();
        }

        // effects
        userCollateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);

        // interactions
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    /// @param amountDscToMint The amount of DSC to mint
    /// @notice they must have more collateral value than the minimum threshold
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        // Check if collateral value > DSC amount. Price feeds, values ,etc. Then we can mint the DSC
        userDscMinted[msg.sender] += amountDscToMint;

        // if they minted too much ($150 DSC, $100 ETH)
        revertIfHealthFactorIsBroken(msg.sender);
    }

    function redeemCollateral() external {}

    function redeemCollateralForDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    /// @notice numerical representation of the user's collateralization level relative to their oustanding stablecoin debt.
    function getHealthFactor() external view {}

    //////////////////////////////////////
    // Private & Internal Functions     //
    //////////////////////////////////////

    /// @notice Using Health Factor Formula from `aave` -> https://aave.com/help/borrowing/liquidations
    function revertIfHealthFactorIsBroken(address user) internal view {
        // if they are under the threshold, we want to revert

        // 1. Check health factor (do they have enough collateral)

        // 2. Revert if they don't

        }

    function _isAllowedToken(address token) internal view {
        if (sPriceFeeds[token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
    }

    function _moreThanZero(uint256 amount) internal pure {
        if (amount == 0) {
            revert DSCEngine__MustBeMoreThanZero();
        }
    }
}

// TODO: Continue from this lecture 9. -> https://updraft.cyfrin.io/courses/advanced-foundry/develop-defi-protocol/defi-mint-dsc
