//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Kronofungible.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MarketPlace is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private marketItems;

    // Addresses Contracts
    IERC20 public kronos;
    Kronofungible public kronofungible;

    // Free tokens
    uint256 private freeTokens;
    bool private depositedFreeTokens;
    mapping(address => bool) private receivedFreeTokens;


    // Variables Contract
    uint256 private depositAmount;
    uint256 private buyingPrice = 10000*1e18;
    struct ItemCreated {
        uint256 itemId;
        uint256 tokenId;
        address buyer;
        bool sold;
    }
    mapping(uint256 => ItemCreated) private idMarketItems;
    address fundsRedeemer;

    event MarketItemCreated(uint256 itemId, uint256 tokenId);
    event MarketItemBought(uint256 itemId, uint256 tokenId, address buyer);

    constructor(address _kronosAddress, address _kronoFungibleAddress) {
        kronos = IERC20(_kronosAddress);
        kronofungible = Kronofungible(_kronoFungibleAddress);
        fundsRedeemer = msg.sender;
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


    function buyItem(uint256 itemId) public {
        // Note: itemId != tokenId

        require(!idMarketItems[itemId].sold, "Item sold");

        require(kronos.transferFrom(msg.sender, address(this), buyingPrice), "transfer failed");
        depositAmount += buyingPrice;

        uint256 nftAmount = kronofungible.balanceOf(address(this), itemId);

        kronofungible.safeTransferFrom(address(this), msg.sender, itemId, nftAmount, "");


        emit MarketItemBought(itemId, idMarketItems[itemId].tokenId, msg.sender);
    }


    function fetchMarketItems() public view returns (ItemCreated[] memory) {
        uint totalMarketItems = marketItems.current();

        ItemCreated[] memory items = new ItemCreated[](totalMarketItems);

        for(uint i = 0; i < totalMarketItems; i++) {
            ItemCreated memory currentItem = idMarketItems[i]; 
            items[i] = currentItem;
        }

        return items;
    }




    function getDepositAmount() public view returns (uint256) {
        return depositAmount;
    }

    function getPricePerToken() public view returns (uint256) {
        return buyingPrice;
    }

    function getFreeTokens() public view returns (uint256) {
        return freeTokens;
    }

    function getCurrentMarketItems() public view returns (uint256) {
        if ( marketItems.current() == 0) {
            return 0;
        }
        return marketItems.current() - 1;
    }


    function depositFreeKronos() public onlyOwner {
        require(!depositedFreeTokens, "Free deposit was already done!");

        require(kronos.transferFrom(msg.sender, address(this), buyingPrice*4),"Transfer failed");
        freeTokens = buyingPrice*4;
        depositedFreeTokens = true;
    }

    function claimFreeKronos() public {
        require(depositedFreeTokens, "Free deposit hasn't been done!");
        require(freeTokens > 0, "There is not more tokens to claim!");
        require(!receivedFreeTokens[msg.sender], "You can claime the tokens just once!");
        freeTokens -= buyingPrice;
        receivedFreeTokens[msg.sender] = true;
        require(kronos.transferFrom(address(this), msg.sender, buyingPrice), "Transfer failed");
    }

    function witdrawKronosTokens() public onlyOwner {
        require(depositAmount > 0, "Insufficient balance!");
        require(kronos.transfer(owner(), depositAmount), "Transfer failed!");
    }
}
