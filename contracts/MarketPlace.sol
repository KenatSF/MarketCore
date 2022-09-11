//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Kronofungible.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract MarketPlace is Ownable, ERC1155Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private marketItems;

    // Addresses Contracts
    IERC20 public kronos;
    Kronofungible public kronofungible;

    // Free tokens
    uint256 private freeTokensAmount;
    bool private depositedFreeTokens;
    mapping(address => bool) private receivedFreeTokens;


    // Variables Contract
    uint256 private depositAmount;
    uint256 private buyingPrice = 10000*1e18;
    mapping(address => bool) private boughtNFT;
    struct ItemCreated {
        uint256 itemId;
        uint256 tokenId;
        address buyer;
        bool sold;
    }
    mapping(uint256 => ItemCreated) private idMarketItems;

    event MarketItemCreated(uint256 itemId, uint256 tokenId);
    event MarketItemBought(uint256 itemId, uint256 tokenId, address buyer);

    constructor(address _kronosAddress, address _kronoFungibleAddress) {
        kronos = IERC20(_kronosAddress);
        kronofungible = Kronofungible(_kronoFungibleAddress);
    }

    
    function createItem(uint256 amount, string memory tokenURI) public onlyOwner {

        kronofungible.mint(address(this), amount, "", tokenURI);

        uint256 tokenId = kronofungible.currentIndexMinted();


        uint256 itemId = marketItems.current();
        

        idMarketItems[itemId] = ItemCreated(
            itemId,
            tokenId, 
            address(0),
            false
            );

        marketItems.increment();

        emit MarketItemCreated(itemId, tokenId);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public override virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    // The next function shouldn't be here but in order to prevent this contract being marked as an abstract, we must define the function.
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public override virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }


    function buyItem(uint256 itemId) public {
        // Note: itemId != tokenId

        require(!idMarketItems[itemId].sold, "Item sold");
        require(!boughtNFT[msg.sender], "You can buy only one NFT!");
        require(kronos.transferFrom(msg.sender, address(this), buyingPrice), "transfer failed");
        depositAmount += buyingPrice;

        uint256 nftAmount = kronofungible.balanceOf(address(this), itemId);

        idMarketItems[itemId].buyer = msg.sender;
        idMarketItems[itemId].sold = true;
        boughtNFT[msg.sender] = true;

        kronofungible.safeTransferFrom(address(this), msg.sender, itemId, nftAmount, "");

        emit MarketItemBought(itemId, idMarketItems[itemId].tokenId, msg.sender);
    }

    function fetchMarketItem(uint256 itemId) public view returns (ItemCreated memory) {
        return idMarketItems[itemId];
    }

    function getDepositAmount() public view returns (uint256) {
        return depositAmount;
    }

    function getPricePerToken() public view returns (uint256) {
        return buyingPrice;
    }

    function getFreeTokensAmount() public view returns (uint256) {
        return freeTokensAmount;
    }

    function getCurrentMarketItems() public view returns (uint256) {
        if ( marketItems.current() == 0) {
            return 0;
        }
        return marketItems.current() - 1;
    }


    //  Free Tokens
    function depositFreeKronos() public onlyOwner {
        require(!depositedFreeTokens, "Free deposit was already done!");

        require(kronos.transferFrom(msg.sender, address(this), buyingPrice*4),"Transfer failed");
        freeTokensAmount = buyingPrice*4;
        depositedFreeTokens = true;
    }

    //  Free Tokens
    function claimFreeKronos() public {
        require(depositedFreeTokens, "Free deposit hasn't been done!");
        require(freeTokensAmount > 0, "There is not more tokens to claim!");
        require(!receivedFreeTokens[msg.sender], "You can claime the tokens just once!");
        freeTokensAmount -= buyingPrice;
        receivedFreeTokens[msg.sender] = true;
        require(kronos.transfer(msg.sender, buyingPrice), "Transfer failed");
    }

    // Withdraw tokens deposited by NFT buyers
    function withdrawKronosTokens() public onlyOwner {
        require(depositAmount > 0, "Insufficient balance!");
        require(kronos.transfer(owner(), depositAmount), "Transfer failed!");
    }
}
