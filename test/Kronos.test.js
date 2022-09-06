const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20 Kronos", function () {
  it("Testing the contract", async function () {
    const maxAmount = "500000";
    // Accounts managament
    const [user0, user1, user2, user3, deployer ] = await ethers.getSigners();


    // Deploy contracts
    const KRN = await hre.ethers.getContractFactory("Kronos");
    const krn = await KRN.connect(deployer).deploy();
    await krn.deployed();
    const kronosAddress = krn.address;

    console.log('-----------------------------------------------------------');
    console.log("First call");
    const owner = await krn.owner();
    var supply = await krn.totalSupply();

    console.log('-----------------------------------------------------------');
    console.log("Show first call!");
    console.log(`Kronos address: ${kronosAddress}`);
    expect(deployer.address).to.equal(owner);
    expect(supply).to.equal(0);

    console.log('-----------------------------------------------------------');
    console.log("Second call");
    await krn.connect(deployer).mint(deployer.address, ethers.utils.parseUnits("250000", "ether"));
    supply = await krn.totalSupply();


    console.log('-----------------------------------------------------------');
    console.log("Show second call!");
    expect(supply).to.equal(ethers.utils.parseUnits("250000", "ether"));

    
    console.log('-----------------------------------------------------------');
    console.log("Third call");
    try {
        await krn.connect(user0).mint(user0.address, ethers.utils.parseUnits("250000", "ether"));
    } catch(e) {
        console.log("Error");
    }
    supply = await krn.totalSupply();

    console.log('-----------------------------------------------------------');
    console.log("Show third call!");
    expect(supply).to.equal(ethers.utils.parseUnits("250000", "ether"));


    console.log('-----------------------------------------------------------');
    console.log("Fourth call!");
    await krn.connect(deployer).mint(deployer.address, ethers.utils.parseUnits("250000", "ether"));
    supply = await krn.totalSupply();

    console.log('-----------------------------------------------------------');
    console.log("Show fourth call!");
    expect(supply).to.equal(ethers.utils.parseUnits(maxAmount, "ether"));


    console.log('-----------------------------------------------------------');
    console.log("Fifth call");
    try {
        await krn.connect(deployer).mint(deployer.address, ethers.utils.parseUnits("1", "ether"));
    } catch(e) {
        console.log("Error");
    }

  });
});