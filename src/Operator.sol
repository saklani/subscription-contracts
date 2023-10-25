// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./IOperator.sol";

import "@openzeppelin/contracts/utils/Pausable.sol";
import "solady/auth/Ownable.sol";
import "./IERC20.sol";

contract Operator is Ownable, IOperator {

    address private _owner;
    uint256 private _amount;
    uint64 private _minimumRenewalDuration;
    uint64 private _maximumRenewalDuration;
    IERC20 private token;

    constructor(address owner_, uint256 amount_, uint64 minimumRenewalDuration_) {
        _initializeOwner(owner_);
        _owner = owner_;
        _amount = amount_;
        _minimumRenewalDuration = minimumRenewalDuration_;
    }
    
}
