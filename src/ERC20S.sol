// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "solady/tokens/ERC20.sol";
import "./IERC20.sol";

contract ERC20S is ERC20 {
    error CallerNotOwnerOrApproved();

    /// @notice Emitted when underlying token is wrapped
    event TokenWrapped(address from, uint256 amount);

    /// @notice Emitted when underlying token is unwrapped
    event TokenUnwrapped(address to, uint256 amount);

    /// @notice Emitted when a subscription expiration changes
    /// @dev When a subscription is canceled, the expiration value should also be 0.
    event SubscriptionUpdate(address from, address to, uint256 amount, uint64 expiration);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    IERC20 private _baseToken;

    mapping(address => mapping(address => bool)) private _active;
    mapping(address => mapping(address => uint64)) private _expirations;
    mapping(address => mapping(address => bool)) _approvals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, address baseToken_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _baseToken = IERC20(baseToken_);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function wrap(address from, uint256 amount) external {
        _baseToken.transferFrom(from, address(this), amount);
        _mint(from, amount);
        emit TokenWrapped(from, amount);
    }

    function unwrap(address to, uint256 amount) external {
        _burn(to, amount);
        _baseToken.transferFrom(address(this), to, amount);
        emit TokenUnwrapped(to, amount);
    }

    function createSubscription(address from, address to, uint256 amount, uint64 duration) external {
        _callerOwnerOrApproved(from);
        transferFrom(from, to, amount);
        _active[to][from] = true;
        _expirations[to][from] += duration;
        emit SubscriptionUpdate(from, to, amount, duration);
    }

    function renewSubscription(address from, address to, uint256 amount, uint64 duration) external {
        uint64 expiration = _expirations[to][from];
        require(expiration > block.timestamp);
        require(_active[to][from]);
        _transfer(from, to, amount);
        _expirations[to][from] += duration;
        emit SubscriptionUpdate(from, to, amount, expiration);
    }

    function cancelSubscription(address from, address to) external {
        _callerOwnerOrApproved(from);
        if (_active[to][from]) {
            _active[to][from] = false;
            emit SubscriptionUpdate(from, to, 0, 0);
        }
    }

    function _callerOwnerOrApproved(address from) private view {
        require(msg.sender == from);
        require(_approvals[from][msg.sender]);
    }

    function approveSubscription(address owner, address spender) external {
        require(msg.sender == owner);
        _approvals[owner][spender] = true;
    }
}
