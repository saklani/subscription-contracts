// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "solady/tokens/ERC20.sol";
import "./IERC20.sol";
import "./IERC5643.sol";

contract ERC20Subscription is ERC20 {
    string private _name;
    string private _symbol;
    IERC20 private _baseToken;
    mapping(address => uint64) _expirations;

    constructor(string memory name_, string memory symbol_, address baseToken_) {
        _name = name_;
        _symbol = symbol_;
        _baseToken = IERC20(baseToken_);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function withdraw() external {}

    function wrap() external {}

    function approveSubscription(uint256 amount, uint64 duration) public {}
}
