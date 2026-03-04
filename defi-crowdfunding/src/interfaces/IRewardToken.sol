// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;
interface IRewardToken {
    function mint(address to, uint256 amount) external;
}