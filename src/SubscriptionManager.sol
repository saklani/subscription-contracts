// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./Subscription.sol";

import "@chainlink/contracts/automation/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "solady/auth/Ownable.sol";
import "";

contract SubscriptionManager is Ownable, AutomationCompatibleInterface {
    uint256[] private _tokenIds;
    bool[] private _isActive;
    Subscription private _subscription;
    ERC6551

    constructor(address owner_) {
        _initializeOwner(owner_);
    }

    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
      uint256[] tokenIds;
        for (uint256 i = 0; i < _tokenIds.length; i++) {

        }
    }

    function performUpkeep(bytes calldata performData) external override {}

    /**
     * This function does two things - 
     * 1. Mint the subscription NFT to the sender
     * 
     * @param id token id to be issued
     */
    function issueSubcriptionNFT(uint256 id) external {
        _subscription.mint(msg.sender, id);
        _isActive[id] = true;
    }

    function cancel(uint256 id) public {
        _subscription.cancelSubscription(id);
        _isActive[id] = false;
    }
}
