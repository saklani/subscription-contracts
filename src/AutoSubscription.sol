// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./IERC5643.sol";
import "solady/src/tokens/ERC721.sol";

contract AutoSubscription is IERC5643, ERC721 {
    
    string private name_;
    string private symbol_;
    uint64 private renewalDuration;

    mapping(uint256 => uint64) private expirations;

    constructor(string memory name__, string memory symbol__) IERC5643() {
        name_ = name__;
        symbol_ = symbol__;
    }

    function name() public view virtual override returns (string memory) {
        return name_;
    }

    function symbol() public view virtual override returns (string memory) {
        return symbol_;
    }

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {}

    function renewSubscription(
        uint256 tokenId,
        uint64 duration
    ) external payable override {}

    function cancelSubscription(uint256 tokenId) external payable override {}

    function expiresAt(
        uint256 tokenId
    ) external view override returns (uint64) {}

    function isRenewable(
        uint256 tokenId
    ) external view override returns (bool) {}
}
