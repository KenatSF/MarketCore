// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Kronofungible is ERC1155, AccessControl, ERC1155Burnable {
    using Counters for Counters.Counter;
    Counters.Counter private _idTokens;
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _maxSupply = 50;

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply;
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(address account, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        uint256 newToken = _idTokens.current();
        require(newToken < maxSupply(), "Max Supply reached!");
        _mint(account, newToken, amount, data);

        _idTokens.increment();
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    function mintBatch(address to, uint256 idsNumber, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        require( ( ( 0 < idsNumber ) && ( idsNumber <= 5 ) ), "You can't mint that amount of Tokens!");
        require(idsNumber == amounts.length, "Ids number and length of amounts array must be equal!");

        uint256 newToken = _idTokens.current();
        require(newToken < maxSupply(), "Max Supply reached!");
        uint256 newBatchToken = newToken + idsNumber;
        require(newBatchToken < maxSupply(), "You can't mint that amount of tokens because you would reach the Max Supply!");

        uint256[] memory idsArray = new uint256[](idsNumber);

        for(uint i = 0; i < idsNumber; i++) {
            uint currentIndex = _idTokens.current();
            idsArray[i] = currentIndex;
            _idTokens.increment();
        }

        _mintBatch(to, idsArray, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
