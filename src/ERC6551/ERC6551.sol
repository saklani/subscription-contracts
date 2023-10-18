// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./IERC6551.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";

contract ERC6551 is IERC6551Account, IERC6551Executable, IERC1271, ERC165 {
    receive() external payable override {}

    function token() external view override returns (uint256 chainId, address tokenContract, uint256 tokenId) {}

    function state() external view override returns (uint256) {}

    function isValidSigner(address signer, bytes calldata context) external view override returns (bytes4 magicValue) {}

    function execute(address to, uint256 value, bytes calldata data, uint256 operation)
        external
        payable
        override
        returns (bytes memory)
    {}

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        override
        returns (bytes4 magicValue)
    {}
}
