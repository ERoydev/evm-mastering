// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;
interface ITreasury {
    function deposit() external payable;
    function refund(address to, uint256 amount) external;
}