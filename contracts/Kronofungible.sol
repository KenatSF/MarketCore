// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";

contract Kronofungible is ERC1155URIStorage, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _idTokens;
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _maxSupply = 50;
    uint256 private _maxFungiblePerToken = 5;

    string private _baseURI;

    constructor(string memory __baseURI) ERC1155("") {
        _baseURI = __baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply;
    }

    function maxFungiblePerToken() public view virtual returns (uint256) {
        return _maxFungiblePerToken;
    }

    function getBaseURI() public view returns(string memory) {
        return _baseURI;
    }

    function setBaseURI(string memory baseURI) public virtual onlyRole(URI_SETTER_ROLE){
        _baseURI = baseURI;
    }

    function stickHash(string memory _hash) internal view returns(string memory) {
        return string(abi.encodePacked(getBaseURI(), _hash));
    }

    function codeJSON(uint256 tokenId, string memory _hash) internal view returns (string memory) {

        string memory hashImage = stickHash(_hash);
        string memory jsonURI = Base64.encode(
            abi.encodePacked(
                '{ "name": "Kronofungible AI #',
                tokenId,
                '", "description": "This image was created by an AI!", "image": "',
                hashImage,
                '"}'
            )
        );

        return
            string(abi.encodePacked("data:application/json;base64,", jsonURI));
    }

    function mint(address account, uint256 amount, bytes memory data, string memory hash)
        public
        onlyRole(MINTER_ROLE)
    {
        uint256 newToken = _idTokens.current();
        require(newToken < maxSupply(), "Max Supply reached!");
        require( ( ( 0 < amount ) && ( amount <= maxFungiblePerToken() ) ), "You can't mint that amount per Token!");
        _mint(account, newToken, amount, data);
        _setURI(newToken, codeJSON(newToken, hash));

        _idTokens.increment();
    }

    function mintBatch(address to, uint256 idsNumber, uint256[] memory amounts, bytes memory data, string[] memory hash)
        public
        onlyRole(MINTER_ROLE)
    {
        require( ( ( 1 < idsNumber ) && ( idsNumber <= 5 ) ), "You can't mint that amount of Tokens in once!");
        require(( (idsNumber == amounts.length) && (idsNumber == hash.length) ), "Number of ids must be equal to length of respective arrays!");

        uint256 newToken = _idTokens.current();
        require(newToken < maxSupply(), "Max Supply reached!");
        uint256 newBatchToken = newToken + idsNumber;
        require(newBatchToken < maxSupply(), "You can't mint that amount of tokens because you would reach the Max Supply!");

        uint256[] memory idsArray = new uint256[](idsNumber);

        for(uint i = 0; i < idsNumber; i++) {
            require( ( ( 0 < amounts[i] ) && ( amounts[i] <= maxFungiblePerToken() ) ), "You can't mint that amount per Token!");
            uint currentIndex = _idTokens.current();
            idsArray[i] = currentIndex;
            _idTokens.increment();
        }

        _mintBatch(to, idsArray, amounts, data);

        for(uint i = 0; i < idsNumber; i++) {
            _setURI(idsArray[i], codeJSON(idsArray[i], hash[i]));
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
