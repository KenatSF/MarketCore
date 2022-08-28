const hre = require("hardhat");

async function main() {
    const KRN = await hre.ethers.getContractFactory("Kronofungible");
    const krn = await KRN.deploy();

    await krn.deployed();

    console.log("Kronofungible deployed to:", krn.address);


}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });