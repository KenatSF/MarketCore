const hre = require("hardhat");

async function main() {
    const kronosAddress = "0x19bd842C4EF5F837600f17a1949c0Ed729379Eae";
    const kronofungibleAddress = "0x4dC153127A6959aF5e85bEb0abf0186415A2b9C7";

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