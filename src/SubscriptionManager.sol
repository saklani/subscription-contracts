// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./Subscription.sol";

import "@chainlink/contracts/automation/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "solady/auth/Ownable.sol";

contract SubscriptionManager is Ownable, AutomationCompatibleInterface {
    bool[] private _tokenIds;
    Subscription private _subscription;

    constructor(address owner_) {
        _initializeOwner(owner_);
    }

    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        for (uint256 i = 0; i < _tokenIds.length; i++) {}
    }

    function performUpkeep(bytes calldata performData) external override {}

    function issueSubcriptionNFT(address to, uint256 id) external {
        _subscription.mint(to, id);
    }

    function cancel(uint256 id) public {
        _subscription.cancelSubscription(id);
    }
}
