const hre = require("hardhat");

async function main() {
    const kronosAddress = "0x51B49afF5d05e36eD50a38D0c3bA575B6F88dDF7";
    const kronofungibleAddress = "0x0A5610bc6d0C285078101a0581d0513DA9ca418b";

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