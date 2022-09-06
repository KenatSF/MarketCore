const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Kronofungible", function () {
  it("Test NFT", async function () {
    const minter_role = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
    // Accounts managament
    const [user0, user1, user2, user3, deployer ] = await ethers.getSigners();


    // Deploy contracts
    const KRN = await hre.ethers.getContractFactory("Kronofungible");
    const krn = await KRN.connect(deployer).deploy();
    await krn.deployed();
    const kronofungibleAddress = krn.address;

    console.log('-----------------------------------------------------------');
    console.log("First call");
    var maxSupply = await krn.maxSupply();
    var isMinter = await krn.hasRole(minter_role, deployer.address);
    var currentIndexMinted = await krn.currentIndexMinted();

    console.log('-----------------------------------------------------------');
    console.log("Show first call!");
    console.log(`Kronofungible address: ${kronofungibleAddress}`);
    expect(maxSupply).to.equal(24);
    expect(isMinter).to.equal(true);
    expect(currentIndexMinted).to.equal(0);

    console.log('-----------------------------------------------------------');
    console.log("Second call");
    await krn.connect(deployer).mint(deployer.address, 1, "0x00", "URI 0 :)");
    await krn.connect(deployer).mint(deployer.address, 1, "0x00", "URI 1 :)");
    currentIndexMinted = await krn.currentIndexMinted();

    console.log('-----------------------------------------------------------');
    console.log("Show second call!");
    expect(currentIndexMinted).to.equal(1);

    console.log('-----------------------------------------------------------');
    console.log("Third call");
    //await krn.connect(deployer).mintBatch(deployer.address, 2, [1,1], "0x00", ["URI 2","URI 3"]);
    await krn.connect(deployer).mintBatch(deployer.address, 21, [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], "0x00", ["URI 2",
                                                                                                                "URI 3",
                                                                                                                "URI 4",
                                                                                                                "URI 5",
                                                                                                                "URI 6",
                                                                                                                "URI 7",
                                                                                                                "URI 8", 
                                                                                                                "URI 9",
                                                                                                                "URI 10",
                                                                                                                "URI 11",
                                                                                                                "URI 12",
                                                                                                                "URI 13",
                                                                                                                "URI 14",
                                                                                                                "URI 15",
                                                                                                                "URI 16",
                                                                                                                "URI 17",
                                                                                                                "URI 18", 
                                                                                                                "URI 19",
                                                                                                                "URI 20",
                                                                                                                "URI 21",
                                                                                                                "URI 22"]);
    await krn.connect(deployer).mint(deployer.address, 1, "0x00", "URI 23 :)");
    currentIndexMinted = await krn.currentIndexMinted();

    console.log('-----------------------------------------------------------');
    console.log("Show third call!");
    expect(currentIndexMinted).to.equal(23);


    console.log('-----------------------------------------------------------');
    console.log("Fourth call");
    try {
        await krn.connect(deployer).mint(deployer.address, 1, "0x00", "URI 24 :)");
    } catch(e) {
        console.log("Error");
    }
    currentIndexMinted = await krn.currentIndexMinted();

    console.log('-----------------------------------------------------------');
    console.log("Show foruth call!");
    expect(currentIndexMinted).to.equal(23);

  });
});