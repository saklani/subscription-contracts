// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC20.sol";

interface IERC20S is IERC20 {
    function createSubscription(address from, address to, uint256 amount, uint64 duration) external;

    function renewSubscription(address from, address to, uint256 amount, uint64 duration) external;

    function cancelSubscription(address from, address to) external;

    function approveSubscription(address owner, address spender) external;
}
