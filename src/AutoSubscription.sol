// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "solady/tokens/ERC721.sol";
import "solady/auth/Ownable.sol";

import "./IERC5643.sol";

contract AutoSubscription is IERC5643, ERC721, Ownable, Pausable {
    string private _name;
    string private _symbol;
    uint256 private _amount;
    uint64 private _renewalDuration;
    mapping(uint256 => uint64) private _expirations;

    constructor(address owner_, string memory name_, string memory symbol_, uint256 amount_, uint64 renewalDuration_)
        IERC5643()
    {
        _initializeOwner(owner_);
        _name = name_;
        _symbol = symbol_;
        _amount = amount_;
        _renewalDuration = renewalDuration_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {}

    function renewSubscription(uint256 tokenId, uint64 duration) external payable override {}

    function cancelSubscription(uint256 tokenId) external payable override {}

    function expiresAt(uint256 tokenId) external view override returns (uint64) {}

    function isRenewable(uint256 tokenId) external view override returns (bool) {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
