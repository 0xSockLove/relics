// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Relics
/// @author SockLove (socklove.eth)
/// @notice Minimal ERC1155 with owner-only minting, sequential IDs, and per-token URIs
contract Relics is ERC1155, Ownable {
    uint256 private _idCounter;
    mapping(uint256 id => string uri) private _uris;

    /// @dev Thrown when mint amount is zero
    error MintAmountZero();

    /// @dev Sets deployer as owner
    constructor() ERC1155("") Ownable(msg.sender) {}

    /// @notice Mints a token with URI and amount
    /// @param uri_ Token URI
    /// @param amount Number of tokens
    /// @return id Token ID
    function mint(string calldata uri_, uint256 amount) external onlyOwner returns (uint256 id) {
        if (amount == 0) revert MintAmountZero();

        unchecked {
            id = ++_idCounter;
        }

        _uris[id] = uri_;

        emit URI(uri_, id);

        _mint(msg.sender, id, amount, "");
    }

    /// @notice Returns the URI for a token
    /// @param id Token ID
    /// @return Token URI
    function uri(uint256 id) public view override returns (string memory) {
        return _uris[id];
    }
}
