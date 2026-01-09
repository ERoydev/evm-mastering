// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


// Reward donors with tokens for participating in an crowdfunding campaign
contract RewardToken is ERC20, Ownable, ERC20Permit {
    constructor(address initialOwner)
        ERC20("RewardToken", "RWD")
        Ownable(initialOwner)
        ERC20Permit("RewardToken")
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}