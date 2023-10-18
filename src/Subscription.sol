// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@chainlink/contracts/automation/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "solady/auth/Ownable.sol";

import "./ERC5643.sol";

contract Subscription is ERC5643, Ownable, Pausable {
    uint256 private _amount;
    uint256[] private _tokenIds;

    constructor(
        address owner_,
        string memory name_,
        string memory symbol_,
        uint256 amount_,
        uint64 minimumRenewalDuration_,
        uint64 maximumRenewalDuration_
    ) ERC5643() {
        _initializeOwner(owner_);
        _name = name_;
        _symbol = symbol_;
        _amount = amount_;
        _minimumRenewalDuration = minimumRenewalDuration_;
        _maximumRenewalDuration = maximumRenewalDuration_;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {}

    function _isRenewable(uint256 tokenId) internal view virtual override returns (bool) {
        uint64 currentExpiration = _expirations[tokenId];
        return ((currentExpiration == 0) || (currentExpiration < block.timestamp));
    }

    function _getRenewalPrice(uint256, uint64 duration) internal view virtual override returns (uint256) {
        uint64 durationUnits = duration / _minimumRenewalDuration;
        return durationUnits * _amount;
    }

    function mint(address owner, uint256 tokenId) public {
      
    }
}
