const hre = require("hardhat");

async function main() {
    const kronosAddress = "0x51B49afF5d05e36eD50a38D0c3bA575B6F88dDF7";
    const kronofungibleAddress = "0xf9014CdB0B51E7FFE0F0Cf3d78a40a6e35B52487";

    const MARKET = await hre.ethers.getContractFactory("MarketPlace");
    const market = await MARKET.deploy(kronosAddress, kronofungibleAddress);

    await market.deployed();

    console.log("MarketPlace deployed to:", market.address);


}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });