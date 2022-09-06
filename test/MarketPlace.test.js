const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace", function () {
  it("Test market", async function () {
    const minter_role = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
    // Accounts managament
    const [user0, user1, user2, user3, deployer ] = await ethers.getSigners();


    // Deploy contracts
    const KRN = await hre.ethers.getContractFactory("Kronos");
    const krn = await KRN.connect(deployer).deploy();
    await krn.deployed();
    const kronosAddress = krn.address;

    const KRNFT = await hre.ethers.getContractFactory("Kronofungible");
    const krnft = await KRNFT.connect(deployer).deploy();
    await krnft.deployed();
    const kronofungibleAddress = krnft.address;


    const MARKET = await hre.ethers.getContractFactory("MarketPlace");
    const market = await MARKET.connect(deployer).deploy(kronosAddress, kronofungibleAddress);
    await market.deployed();
    const marketAddress = market.address;

    console.log('-----------------------------------------------------------');
    console.log("First call");
    var currentMarketItems = await market.getCurrentMarketItems();
    var freeTokensAmount = await market.getFreeTokensAmount();
    var depositAmount = await market.getDepositAmount();

    // Asign role of minter to market
    await krnft.connect(deployer).grantRole(minter_role, marketAddress);


    
    console.log('-----------------------------------------------------------');
    console.log("Show first call!");
    console.log(`MarketPlace address: ${marketAddress}`);
    expect(currentMarketItems).to.equal(0);
    expect(freeTokensAmount).to.equal(0);
    expect(depositAmount).to.equal(0);

    console.log('-----------------------------------------------------------');
    console.log("Second call");
    await krn.connect(deployer).mint(deployer.address, ethers.utils.parseUnits("100000", "ether"));
    await krn.connect(deployer).approve(marketAddress, ethers.utils.parseUnits("40000", "ether"));
    await market.connect(deployer).depositFreeKronos();

    currentMarketItems = await market.getCurrentMarketItems();
    freeTokensAmount = await market.getFreeTokensAmount();
    depositAmount = await market.getDepositAmount();

    console.log('-----------------------------------------------------------');
    console.log("Show second call!");
    expect(currentMarketItems).to.equal(0);
    expect(freeTokensAmount).to.equal(ethers.utils.parseUnits("40000", "ether"));
    expect(depositAmount).to.equal(0);

    console.log('-----------------------------------------------------------');
    console.log("Third call");
    // MarketPlace
    await market.connect(deployer).createItem(1, "URI 0");
    await market.connect(deployer).createItem(1, "URI 1");

    currentMarketItems = await market.getCurrentMarketItems();
    freeTokensAmount = await market.getFreeTokensAmount();
    depositAmount = await market.getDepositAmount();

    // Kronos token
    await krn.connect(deployer).transfer(user0.address, ethers.utils.parseUnits("10000", "ether"))
    await krn.connect(user0).approve(marketAddress, ethers.utils.parseUnits("10000", "ether"));
    var user0Balance = await krn.balanceOf(user0.address);


    console.log('-----------------------------------------------------------');
    console.log("Show third call!");
    expect(user0Balance).to.equal(ethers.utils.parseUnits("10000", "ether"));
    expect(currentMarketItems).to.equal(1);
    expect(freeTokensAmount).to.equal(ethers.utils.parseUnits("40000", "ether"));
    expect(depositAmount).to.equal(0);


    console.log('-----------------------------------------------------------');
    console.log("Fourth call");
    await market.connect(user0).buyItem(0);
    var user0BalanceNFT = await krnft.balanceOf(user0.address, 0);
    var uriId0 = await krnft.uri(0);
    user0Balance = await krn.balanceOf(user0.address);

    currentMarketItems = await market.getCurrentMarketItems();
    freeTokensAmount = await market.getFreeTokensAmount();
    depositAmount = await market.getDepositAmount();

    console.log('-----------------------------------------------------------');
    console.log("Show fourth call!");
    expect(user0Balance).to.equal(0);
    expect(user0BalanceNFT).to.equal(1);
    expect(uriId0).to.equal("URI 0");
    expect(currentMarketItems).to.equal(1);
    expect(freeTokensAmount).to.equal(ethers.utils.parseUnits("40000", "ether"));
    expect(depositAmount).to.equal(ethers.utils.parseUnits("10000", "ether"));



    console.log('-----------------------------------------------------------');
    console.log("Fifth call");
    await market.connect(user0).claimFreeKronos();
    user0Balance = await krn.balanceOf(user0.address);

    currentMarketItems = await market.getCurrentMarketItems();
    freeTokensAmount = await market.getFreeTokensAmount();
    depositAmount = await market.getDepositAmount();

    console.log('-----------------------------------------------------------');
    console.log("Show fifth call!");
    expect(user0Balance).to.equal(ethers.utils.parseUnits("10000", "ether"));

    expect(currentMarketItems).to.equal(1);
    expect(freeTokensAmount).to.equal(ethers.utils.parseUnits("30000", "ether"));
    expect(depositAmount).to.equal(ethers.utils.parseUnits("10000", "ether"));


    console.log('-----------------------------------------------------------');
    console.log("Sixth call");
    try {
        await market.connect(user0).claimFreeKronos();
    } catch(e) {
        console.log("Error: Double claim free tokens from same account.");
    }
  });
});