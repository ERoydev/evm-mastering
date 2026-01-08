// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library BitmaskLib {
    uint8 private constant ACTIVE = 1 << 0;
    uint8 private constant SUCCESSFUL = 1 << 1;
    uint8 private constant FAILED = 1 << 2;
    uint8 private constant REFUNDS_ENABLED = 1 << 3;
    uint8 private constant FUNDS_RELEASED = 1 << 4;

    function setState(uint8 state, uint8 flag) internal pure returns (uint8) {
        return state | flag;
    }

    function clearState(uint8 state, uint8 flag) internal pure returns (uint8) {
        return state & ~flag;
    }

    function hasState(uint8 state, uint8 flag) internal pure returns (bool) {
        return (state & flag) != 0;
    }
}

Active → Successful → Funds Released
       → Failed → Refunds Enabled