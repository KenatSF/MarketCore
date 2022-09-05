// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract Kronofungible is ERC1155URIStorage, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _idTokens;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _maxSupply = 24;
    uint256 private _maxFungiblePerToken = 5;


    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function currentIndexMinted() public view virtual returns (uint256) {
        if ( _idTokens.current() == 0) {
            return 0;
        }
        return _idTokens.current() - 1;
    }

    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply;
    }

    function maxFungiblePerToken() public view virtual returns (uint256) {
        return _maxFungiblePerToken;
    }


    function mint(address account, uint256 amount, bytes memory data, string memory finalURI)
        public
        onlyRole(MINTER_ROLE)
    {
        uint256 currentToken = _idTokens.current();
        require(currentToken < maxSupply(), "Max Supply reached!");
        require( ( ( 0 < amount ) && ( amount <= maxFungiblePerToken() ) ), "You can't mint that amount per Token!");
        _mint(account, currentToken, amount, data);
        _setURI(currentToken, finalURI);

        _idTokens.increment();
    }

    function mintBatch(address to, uint256 tokensNumber, uint256[] memory amounts, bytes memory data, string[] memory finalURI)
        public
        onlyRole(MINTER_ROLE)
    {
        require( ( ( 0 < tokensNumber ) && ( tokensNumber <= maxSupply() ) ), "You can't mint that amount of Tokens in once!");
        require(( (tokensNumber == amounts.length) && (tokensNumber == finalURI.length) ), "Number of ids must be equal to length of respective arrays!");

        uint256 currentToken = _idTokens.current();
        require(currentToken < maxSupply(), "Max Supply reached!");
        uint256 newBatchToken = currentToken + tokensNumber - 1;
        require(newBatchToken < maxSupply(), "You can't mint that amount of tokens because you would reach the Max Supply!");

        uint256[] memory idsArray = new uint256[](tokensNumber);

        for(uint i = 0; i < tokensNumber; i++) {
            require( ( ( 0 < amounts[i] ) && ( amounts[i] <= maxFungiblePerToken() ) ), "You can't mint that amount per Token!");
            uint currentIndex = _idTokens.current();
            idsArray[i] = currentIndex;
            _idTokens.increment();
        }

        _mintBatch(to, idsArray, amounts, data);

        for(uint i = 0; i < tokensNumber; i++) {
            _setURI(idsArray[i], finalURI[i]);
        }
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}