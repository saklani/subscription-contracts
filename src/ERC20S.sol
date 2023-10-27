// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./IERC20.sol";
import "solady/tokens/ERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract ERC20S is ERC20 {
    struct Subscription {
        uint256 amount;
        uint256 expiration;
        uint256 duration;
    }

    error CallerNotOwnerOrApproved();

    error SubscriptionAlreadyExists();

    error SubscriptionInactive();

    /// @notice Emitted when underlying token is wrapped
    event TokenWrapped(address from, uint256 amount);

    /// @notice Emitted when underlying token is unwrapped
    event TokenUnwrapped(address to, uint256 amount);

    /// @notice Emitted when a subscription expiration changes
    event SubscriptionUpdate(address from, address to, uint256 amount, uint256 expiration, bool active);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    IERC20 private _baseToken;

    mapping(address => mapping(address => bool)) private _active;
    mapping(address => mapping(address => bool)) private _approvals;
    mapping(address => mapping(address => Subscription)) _subscriptions;

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

    function createSubscription(address from, address to, uint256 amount, uint256 duration) external {
        _callerOwnerOrApproved(from);
        if (_active[from][to]) {
            revert SubscriptionAlreadyExists();
        }
        _active[from][to] = true;
        _subscriptions[from][to] = Subscription(amount, block.timestamp + duration, duration);
        _transfer(from, to, amount);
        emit SubscriptionUpdate(from, to, amount, duration, true);
    }

    function renewSubscription(address from, address to) external {
        if (!_active[from][to]) {
            revert SubscriptionInactive();
        }
        Subscription memory subscription = _subscriptions[from][to];
        if (subscription.expiration <= block.timestamp) {
            revert SubscriptionAlreadyExists();
        }
        subscription.expiration += subscription.duration;
        _subscriptions[from][to] = subscription;
        _transfer(from, to, subscription.amount);
        emit SubscriptionUpdate(from, to, subscription.amount, subscription.expiration, true);
    }

    function cancelSubscription(address from, address to) external {
        _callerOwnerOrApproved(from);
        if (!_active[from][to]) {
            revert SubscriptionInactive();
        }
        _active[from][to] = false;
        emit SubscriptionUpdate(from, to, 0, _subscriptions[from][to].expiration, false);
    }

    function _callerOwnerOrApproved(address from) private view {
        if (msg.sender != from && !_approvals[from][msg.sender]) {
            revert CallerNotOwnerOrApproved();
        }
    }

    function approveSubscription(address owner, address spender) external {
        if (msg.sender != owner) {
            revert CallerNotOwnerOrApproved();
        }
        _approvals[owner][spender] = true;
    }
}
