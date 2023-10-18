// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./IERC5643.sol";
import "solady/tokens/ERC721.sol";

error RenewalTooShort();
error RenewalTooLong();
error InsufficientPayment();
error SubscriptionNotRenewable();
error InvalidTokenId();
error CallerNotOwnerNorApproved();

abstract contract ERC5643 is ERC721, IERC5643 {
    string internal _name;
    string internal _symbol;
    uint64 internal _minimumRenewalDuration;
    uint64 internal _maximumRenewalDuration;

    mapping(uint256 => uint64) internal _expirations;
    
    /**
     * @dev See {IERC5643-renewSubscription}.
     */

    function renewSubscription(
        uint256 tokenId,
        uint64 duration
    ) public payable virtual {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert CallerNotOwnerNorApproved();
        }

        if (duration < _minimumRenewalDuration) {
            revert RenewalTooShort();
        } else if (
            _maximumRenewalDuration != 0 && duration > _maximumRenewalDuration
        ) {
            revert RenewalTooLong();
        }

        if (msg.value < _getRenewalPrice(tokenId, duration)) {
            revert InsufficientPayment();
        }

        _extendSubscription(tokenId, duration);
    }

    /**
     * @dev Extends the subscription for `tokenId` for `duration` seconds.
     * If the `tokenId` does not exist, an error will be thrown.
     * If a token is not renewable, an error will be thrown.
     * Emits a {SubscriptionUpdate} event after the subscription is extended.
     */
    function _extendSubscription(uint256 tokenId, uint64 duration) internal {
        if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }

        uint64 currentExpiration = _expirations[tokenId];
        uint64 newExpiration;
        if ((currentExpiration == 0) || (currentExpiration < block.timestamp)) {
            newExpiration = uint64(block.timestamp) + duration;
        } else {
            if (!_isRenewable(tokenId)) {
                revert SubscriptionNotRenewable();
            }
            newExpiration = currentExpiration + duration;
        }

        _expirations[tokenId] = newExpiration;

        emit SubscriptionUpdate(tokenId, newExpiration);
    }

    /**
     * @dev Gets the price to renew a subscription for `duration` seconds for
     * a given tokenId. This value is defaulted to 0, but should be overridden in
     * implementing contracts.
     */
    function _getRenewalPrice(
        uint256,
        uint64 duration
    ) internal view virtual returns (uint256);

    /**
     * @dev See {IERC5643-cancelSubscription}.
     */
    function cancelSubscription(uint256 tokenId) public payable virtual {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert CallerNotOwnerNorApproved();
        }

        delete _expirations[tokenId];

        emit SubscriptionUpdate(tokenId, 0);
    }

    /**
     * @dev See {IERC5643-expiresAt}.
     */
    function expiresAt(uint256 tokenId) external view virtual returns (uint64) {
        if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }
        return _expirations[tokenId];
    }

    /**
     * @dev See {IERC5643-isRenewable}.
     */
    function isRenewable(uint256 tokenId) external view virtual returns (bool) {
        if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }
        return _isRenewable(tokenId);
    }

    /**
     * @dev Internal function to determine renewability. Implementing contracts
     * should override this function if renewabilty should be disabled for all or
     * some tokens.
     */
    function _isRenewable(
        uint256 tokenId
    ) internal view virtual returns (bool);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC5643).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
